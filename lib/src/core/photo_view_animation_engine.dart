import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

/// Manages the temporal transitions (animations) for [PhotoView].
///
/// This engine acts as the "Brain" for movement logic, ensuring that conflicting
/// animations (e.g., a user scrolling while a double-tap animation is active)
/// are handled gracefully by stopping one before starting the other.
///
/// It supports two distinct animation models:
///
/// 1. **Standard Tweens (Time-based):**
///    Used for discrete, finite transitions like Double-Tap to zoom,
///    Rebound (rubber-band effect), and Fling (momentum).
///    Driven by [AnimationController].
///
/// 2. **Physics/decay (Frame-based):**
///    Used for continuous inputs like Mouse Wheel, Trackpad, or Zoom Buttons.
///    This allows for "Additive Animation", where new inputs modify the target
///    of an ongoing animation without stopping it, resulting in butter-smooth
///    scrolling and zooming. Driven by [Ticker] and exponential decay math.
class PhotoViewAnimationEngine {
  PhotoViewAnimationEngine({
    required this.controller,
    required this.vsync,
    required this.onBoundaries,
    required this.onScaleAnimationStatus,
  }) {
    // Initialize standard controller for time-based tweens
    _standardCtrl = AnimationController(vsync: vsync)
      ..addListener(_onStandardAnimationTick)
      ..addStatusListener(_onStandardAnimationStatus);
  }

  final PhotoViewControllerBase controller;
  final TickerProvider vsync;

  /// Provider for the current layout boundaries (Viewport & Child Size).
  final ValueGetter<ScaleBoundaries> onBoundaries;

  /// Callback to notify Core when a standard animation starts/stops.
  final ValueChanged<AnimationStatus> onScaleAnimationStatus;

  /// A safety floor to prevent scale from hitting true zero, which breaks matrix math.
  static const double _kMinScaleSafety = 0.0001;

  // --------------------------------------------------------------------------
  // STATE: Standard Animations (Double Tap, Fling, Rebound)
  // --------------------------------------------------------------------------
  late final AnimationController _standardCtrl;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _positionAnimation;
  Animation<double>? _rotationAnimation;

  // --------------------------------------------------------------------------
  // STATE: Smooth Panning (Physics)
  // --------------------------------------------------------------------------
  Ticker? _panTicker;
  Offset? _panTarget;
  Duration? _lastPanFrameTime;

  // --------------------------------------------------------------------------
  // STATE: Smooth Zooming (Physics)
  // --------------------------------------------------------------------------
  Ticker? _zoomTicker;
  double? _zoomTarget;
  Duration? _lastZoomFrameTime;

  /// The scale value at the moment the zoom sequence started.
  /// Used as a baseline for vector math to ensure stability.
  late double _refScale;

  /// The vector from the Image Center to the Focal Point (Mouse Position)
  /// calculated at [_refScale].
  late Offset _refVector;

  /// The screen position of the mouse/focal point. Used to detect if the user
  /// moved the mouse, requiring a recalculation of the reference vector.
  Offset? _lastFocalPoint;

  void dispose() {
    _standardCtrl.dispose();
    _panTicker?.dispose();
    _zoomTicker?.dispose();
  }

  /// Stops ALL active animations immediately.
  /// Should be called whenever the user physically touches the screen to
  /// prevent the animation engine from fighting with gesture recognition.
  void stop() {
    _standardCtrl.stop();

    _panTicker?.stop();
    _panTarget = null;

    _zoomTicker?.stop();
    _zoomTarget = null;
  }

  // ==========================================================================
  // SECTION A: Standard Animations (Time-based Tweens)
  // Used for: Double-Tap, Fling, Rebound
  // ==========================================================================

  /// Performs an atomic state transition for Scale, Position, and Rotation.
  /// This ensures all three properties animate in perfect sync, driven by a
  /// single controller.
  void animateStateChange({
    required double scaleFrom,
    required double scaleTo,
    required Offset positionFrom,
    required Offset positionTo,
    required double rotationFrom,
    required double rotationTo,
  }) {
    stop(); // Ensure no physics animations are interfering

    _scaleAnimation =
        Tween<double>(begin: scaleFrom, end: scaleTo).animate(_standardCtrl);
    _positionAnimation = Tween<Offset>(begin: positionFrom, end: positionTo)
        .animate(_standardCtrl);
    _rotationAnimation = Tween<double>(begin: rotationFrom, end: rotationTo)
        .animate(_standardCtrl);

    _standardCtrl
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateScale(double from, double to) {
    stop();
    _scaleAnimation =
        Tween<double>(begin: from, end: to).animate(_standardCtrl);
    _standardCtrl
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    stop();
    _positionAnimation =
        Tween<Offset>(begin: from, end: to).animate(_standardCtrl);
    _standardCtrl
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateRotation(double from, double to) {
    stop();
    _rotationAnimation =
        Tween<double>(begin: from, end: to).animate(_standardCtrl);
    _standardCtrl
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void _onStandardAnimationTick() {
    // We use setScaleInvisibly to prevent the PhotoViewCore delegate from
    // seeing this specific scale change during the animation frame.
    // This prevents the delegate's "Blind Listeners" from prematurely
    // switching the ScaleState (e.g. from 'covering' to 'zoomedIn').
    if (_scaleAnimation != null) {
      controller.setScaleInvisibly(_scaleAnimation!.value);
    }
    if (_positionAnimation != null) {
      controller.position = _positionAnimation!.value;
    }
    if (_rotationAnimation != null) {
      controller.rotation = _rotationAnimation!.value;
    }
  }

  void _onStandardAnimationStatus(AnimationStatus status) {
    onScaleAnimationStatus(status);
  }

  // ==========================================================================
  // SECTION B: Smooth Zooming (Physics / Exponential Decay)
  // Used for: Mouse Wheel, Zoom Buttons, Trackpad Pinch
  // ==========================================================================

  /// smoothly zooms the image by a specific [factor] (e.g. 1.1 for +10%).
  ///
  /// This method uses additive targeting: if an animation is already running,
  /// the new factor is applied to the *existing target* rather than the current
  /// scale, preserving momentum.
  void animateScaleBy({required double factor, Offset? focalPoint}) {
    // 1. Stop conflicting animations
    _standardCtrl.stop();
    _panTicker?.stop();
    _panTarget = null;

    final boundaries = onBoundaries();
    final double currentScale = controller.scale ?? boundaries.initialScale;
    final Offset currentPos = controller.position;

    // 2. Determine Focal Point (Mouse Position or Screen Center)
    final effectiveFocalPoint =
        focalPoint ?? Alignment.center.alongSize(boundaries.outerSize);

    // 3. Initialize/Reset Math Basis
    // If the focal point has moved significantly (user moved mouse), or if
    // we are starting a new sequence, we must reset the reference vector
    // to ensure the math remains stable relative to the new pivot.
    final bool isRunning = _zoomTicker != null && _zoomTicker!.isActive;
    final bool focalPointChanged = _lastFocalPoint != null &&
        (effectiveFocalPoint - _lastFocalPoint!).distance > 1.0;

    if (!isRunning || focalPointChanged || _zoomTarget == null) {
      _refScale = currentScale;
      _lastFocalPoint = effectiveFocalPoint;

      // Calculate Vector: Distance from Image Origin (Pivot + Pos) to Focal Point
      final Offset pivotNode = Alignment.center.alongSize(boundaries.outerSize);
      _refVector = effectiveFocalPoint - (pivotNode + currentPos);

      // Start target from current reality
      _zoomTarget ??= currentScale;
    }

    // 4. Update Target
    final double rawTarget = _zoomTarget! * factor;

    // Apply limits
    final effectiveMin =
        math.max<double>(boundaries.minScale, _kMinScaleSafety);
    final effectiveMax = math.max<double>(boundaries.maxScale, effectiveMin);

    _zoomTarget = rawTarget.clamp(effectiveMin, effectiveMax);

    // Optimization: Don't run ticker if we are already at the target
    if ((_zoomTarget! - currentScale).abs() < _kMinScaleSafety) {
      return;
    }

    // 5. Start Physics Loop
    if (_zoomTicker == null || !_zoomTicker!.isActive) {
      _lastZoomFrameTime = null;
      _zoomTicker = vsync.createTicker(_onZoomTick)..start();
    }
  }

  void _onZoomTick(Duration elapsed) {
    if (_zoomTarget == null) {
      _zoomTicker?.stop();
      return;
    }

    // Calculate Delta Time (dt) in seconds
    final double dt = _lastZoomFrameTime == null
        ? (1.0 / 60.0) // Assume 60fps for first frame
        : (elapsed - _lastZoomFrameTime!).inMicroseconds / 1000000.0;
    _lastZoomFrameTime = elapsed;

    final double currentScale = controller.scale!;
    final double diff = _zoomTarget! - currentScale;

    // Stop if close enough
    if (diff.abs() < _kMinScaleSafety) {
      // Snap to exact target to avoid micro-drifting
      final double ratio = _zoomTarget! / _refScale;
      final Offset pivotNode =
          Alignment.center.alongSize(onBoundaries().outerSize);

      // Calculate final exact position
      final Offset idealPos =
          _lastFocalPoint! - (_refVector * ratio) - pivotNode;

      controller.updateMultiple(scale: _zoomTarget!, position: idealPos);

      _zoomTicker?.stop();
      _zoomTarget = null;
      return;
    }

    // Exponential Decay: Moves a percentage of the remaining distance every frame.
    // Friction 12.0 provides a snappy but smooth "mechanical" feel.
    const double friction = 12.0;
    final double alpha = 1.0 - math.exp(-friction * dt);

    final double newScale = currentScale + diff * alpha;

    // Vector Math: Calculate new position to keep focal point stationary
    final double scaleRatio = newScale / _refScale;
    final Offset pivotNode =
        Alignment.center.alongSize(onBoundaries().outerSize);

    final Offset newPos =
        _lastFocalPoint! - (_refVector * scaleRatio) - pivotNode;

    controller.updateMultiple(scale: newScale, position: newPos);
  }

  // ==========================================================================
  // SECTION C: Smooth Panning (Physics / Exponential Decay)
  // Used for: Mouse Wheel Scrolling, Shift-Scrolling
  // ==========================================================================

  /// Smoothly pans the image by the given [delta] offset.
  ///
  /// This uses additive targeting: if the image is already moving, the [delta]
  /// is added to the *destination* (_panTarget), not the current position.
  /// This ensures that rapid scroll events stack up velocity rather than
  /// resetting the momentum.
  void animatePositionBy({required Offset delta}) {
    // 1. Stop conflicting animations
    _standardCtrl.stop();
    _zoomTicker?.stop(); // Zoom takes precedence over Pan
    _zoomTarget = null;

    // 2. Initialize Target
    _panTarget ??= controller.position;

    // 3. Accumulate Delta
    final Offset rawTarget = _panTarget! + delta;

    // 4. Clamp Target immediately
    // We clamp the destination to prevent animating into void space.
    final boundaries = onBoundaries();
    final double currentScale = controller.scale ?? boundaries.initialScale;

    _panTarget = _clampPosition(rawTarget, currentScale, boundaries);

    // Optimization: Don't run ticker if target is negligible
    if ((_panTarget! - controller.position).distance < 0.5) {
      return;
    }

    // 5. Start Physics Loop
    if (_panTicker == null || !_panTicker!.isActive) {
      _lastPanFrameTime = null;
      _panTicker = vsync.createTicker(_onPanTick)..start();
    }
  }

  void _onPanTick(Duration elapsed) {
    if (_panTarget == null) {
      _panTicker?.stop();
      return;
    }

    final double dt = _lastPanFrameTime == null
        ? 0.016
        : (elapsed - _lastPanFrameTime!).inMicroseconds / 1000000.0;
    _lastPanFrameTime = elapsed;

    final Offset currentPos = controller.position;
    final Offset diff = _panTarget! - currentPos;

    // Stop if close enough
    if (diff.distance < 0.5) {
      controller.position = _panTarget!;
      _panTicker?.stop();
      _panTarget = null;
      return;
    }

    // Exponential Decay
    const double friction = 12.0;
    final double alpha = 1.0 - math.exp(-friction * dt);

    final Offset newPos = Offset(
      currentPos.dx + diff.dx * alpha,
      currentPos.dy + diff.dy * alpha,
    );

    controller.position = newPos;
  }

  /// Helper to clamp a potential position vector against the layout boundaries
  Offset _clampPosition(
      Offset position, double scale, ScaleBoundaries boundaries) {
    final computedWidth = boundaries.childSize.width * scale;
    final computedHeight = boundaries.childSize.height * scale;
    final screenWidth = boundaries.outerSize.width;
    final screenHeight = boundaries.outerSize.height;

    double clampAxis(
        double currentPos, double computedSize, double screenSize) {
      if (screenSize >= computedSize) {
        return 0.0; // Center if smaller than screen
      } else {
        final double boundary = (computedSize - screenSize) / 2;
        return currentPos.clamp(-boundary, boundary);
      }
    }

    return Offset(
      clampAxis(position.dx, computedWidth, screenWidth),
      clampAxis(position.dy, computedHeight, screenHeight),
    );
  }
}
