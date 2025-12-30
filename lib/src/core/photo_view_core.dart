import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart'
    show
        PhotoViewScaleState,
        PhotoViewHeroAttributes,
        PhotoViewImageTapDownCallback,
        PhotoViewImageTapUpCallback,
        PhotoViewImageScaleEndCallback,
        ScaleStateCycle;
import 'package:photo_view/src/controller/photo_view_controller_base.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/core/photo_view_animation_engine.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/core/photo_view_hit_corners.dart';
import 'package:photo_view/src/core/photo_view_mouse_region.dart';
import 'package:photo_view/src/core/photo_view_scroll_handler.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

const _defaultDecoration = const BoxDecoration(
  color: const Color.fromRGBO(0, 0, 0, 1.0),
);

/// Internal widget in which controls all animations lifecycle, core responses
/// to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
class PhotoViewCore extends StatefulWidget {
  const PhotoViewCore({
    Key? key,
    required this.imageProvider,
    required this.backgroundDecoration,
    required this.semanticLabel,
    required this.gaplessPlayback,
    required this.heroAttributes,
    required this.enableRotation,
    required this.onTapUp,
    required this.onTapDown,
    required this.onScaleEnd,
    required this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.scaleStateCycle,
    required this.scaleStateController,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  })  : customChild = null,
        super(key: key);

  const PhotoViewCore.customChild({
    Key? key,
    required this.customChild,
    required this.backgroundDecoration,
    this.heroAttributes,
    required this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    required this.controller,
    required this.scaleBoundaries,
    required this.scaleStateCycle,
    required this.scaleStateController,
    required this.basePosition,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  })  : imageProvider = null,
        semanticLabel = null,
        gaplessPlayback = false,
        super(key: key);

  final Decoration? backgroundDecoration;
  final ImageProvider? imageProvider;
  final String? semanticLabel;
  final bool? gaplessPlayback;
  final PhotoViewHeroAttributes? heroAttributes;
  final bool enableRotation;
  final Widget? customChild;

  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final ScaleBoundaries scaleBoundaries;
  final ScaleStateCycle scaleStateCycle;
  final Alignment basePosition;

  final PhotoViewImageTapUpCallback? onTapUp;
  final PhotoViewImageTapDownCallback? onTapDown;
  final PhotoViewImageScaleEndCallback? onScaleEnd;

  final HitTestBehavior? gestureDetectorBehavior;
  final bool tightMode;
  final bool disableGestures;
  final bool enablePanAlways;
  final bool strictScale;

  final FilterQuality filterQuality;

  @override
  State<StatefulWidget> createState() {
    return PhotoViewCoreState();
  }

  bool get hasCustomChild => customChild != null;
}

class PhotoViewCoreState extends State<PhotoViewCore>
    with
        TickerProviderStateMixin,
        PhotoViewControllerDelegate,
        HitCornersDetector
    implements PhotoViewAnimationDelegate {
  late final PhotoViewAnimationEngine _animationEngine;
  PhotoViewControllerBase? _attachedController;

  // -- Scaling Calculation Helper State --
  Offset? _normalizedPosition;
  double? _scaleBefore;
  double? _rotationBefore;

  PhotoViewHeroAttributes? get heroAttributes => widget.heroAttributes;

  late ScaleBoundaries cachedScaleBoundaries = widget.scaleBoundaries;

  @override
  void animateScaleBy({required double factor, Offset? focalPoint}) {
    _animationEngine.animateScaleBy(factor: factor, focalPoint: focalPoint);
  }

  @override
  void animatePositionBy({required Offset delta}) {
    _animationEngine.animatePositionBy(delta: delta);
  }

  void onScaleStart(ScaleStartDetails details) {
    _animationEngine.stop(); // Stop any running animations when user touches

    _rotationBefore = controller.rotation;
    _scaleBefore = scale;
    _normalizedPosition = details.focalPoint - controller.position;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore! * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition!;

    if (widget.strictScale &&
        (newScale > widget.scaleBoundaries.maxScale ||
            newScale < widget.scaleBoundaries.minScale)) {
      return;
    }

    updateScaleStateFromNewScale(newScale);

    updateMultiple(
      scale: newScale,
      position: widget.enablePanAlways
          ? delta
          : clampPosition(position: delta * details.scale),
      rotation:
          widget.enableRotation ? _rotationBefore! + details.rotation : null,
      rotationFocusPoint: widget.enableRotation ? details.focalPoint : null,
    );
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = scale;
    final Offset _position = controller.position;
    final double maxScale = scaleBoundaries.maxScale;
    final double minScale = scaleBoundaries.minScale;

    widget.onScaleEnd?.call(context, details, controller.value);

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      _animationEngine.animateScale(_scale, maxScale);
      final Offset clampedPosition = clampPosition(
        position: _position * scaleComebackRatio,
        scale: maxScale,
      );
      _animationEngine.animatePosition(_position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      _animationEngine.animateScale(_scale, minScale);
      final Offset clampedPosition = clampPosition(
        position: _position * scaleComebackRatio,
        scale: minScale,
      );
      _animationEngine.animatePosition(_position, clampedPosition);
      return;
    }

    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore! / _scale == 1.0 && magnitude >= 400.0) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      _animationEngine.animatePosition(
        _position,
        clampPosition(position: _position + direction * 100.0),
      );
    }
  }

  void onDoubleTap() {
    nextScaleState();
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      onAnimationStatusCompleted();
    }
  }

  /// Check if scale is equal to initial after scale animation update
  void onAnimationStatusCompleted() {
    if (scaleStateController.scaleState != PhotoViewScaleState.initial &&
        scale == scaleBoundaries.initialScale) {
      scaleStateController.setInvisibly(PhotoViewScaleState.initial);
    }
  }

  @override
  void initState() {
    super.initState();

    //  Initialize Engine
    _animationEngine = PhotoViewAnimationEngine(
      controller: widget.controller,
      vsync: this,
      onBoundaries: () => widget.scaleBoundaries,
      onScaleAnimationStatus: onAnimationStatus,
    );

    // Attach Controller
    final attachedController = widget.controller;
    attachedController.attach(this);
    _attachedController = attachedController;

    // Delegate Init
    initDelegate();
    addAnimateOnScaleStateUpdate(animateOnScaleStateUpdate);

    cachedScaleBoundaries = widget.scaleBoundaries;
  }

  @override
  void didUpdateWidget(covariant PhotoViewCore oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newAttachedController = widget.controller;
    if (newAttachedController != _attachedController) {
      _attachedController?.detach();
      newAttachedController.attach(this);
      _attachedController = newAttachedController;
    }

    if (widget.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.scaleBoundaries;
    }
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale) {
    _animationEngine.animateStateChange(
      scaleFrom: prevScale,
      scaleTo: nextScale,
      positionFrom: controller.position,
      positionTo: Offset.zero,
      rotationFrom: controller.rotation,
      rotationTo: 0.0,
    );
  }

  @override
  void dispose() {
    _attachedController?.detach();
    _animationEngine.dispose();
    super.dispose();
  }

  void onTapUp(TapUpDetails details) {
    widget.onTapUp?.call(context, details, controller.value);
  }

  void onTapDown(TapDownDetails details) {
    widget.onTapDown?.call(context, details, controller.value);
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need a recalc on the scale
    if (widget.scaleBoundaries != cachedScaleBoundaries) {
      markNeedsScaleRecalc = true;
      cachedScaleBoundaries = widget.scaleBoundaries;
    }

    return StreamBuilder(
        stream: controller.outputStateStream,
        initialData: controller.prevValue,
        builder: (
          BuildContext context,
          AsyncSnapshot<PhotoViewControllerValue> snapshot,
        ) {
          if (snapshot.hasData) {
            // We need to grab the latest value here, otherwise we're one frame behind.
            // This is especially important with AnimationControllers setting the scale/position/rotation.
            // (But we still have to consider if the value is available, otherwise we crash with late initialization)
            final PhotoViewControllerValue value = controller.value;

            final useImageScale = widget.filterQuality != FilterQuality.none;

            final computedScale = useImageScale ? 1.0 : scale;

            final matrix = Matrix4.identity()
              ..translateByDouble(
                  value.position.dx, value.position.dy, 0.0, 1.0)
              ..scaleByDouble(computedScale, computedScale, computedScale, 1.0)
              ..rotateZ(value.rotation);

            final Widget customChildLayout = CustomSingleChildLayout(
              delegate: _CenterWithOriginalSizeDelegate(
                scaleBoundaries.childSize,
                basePosition,
                useImageScale,
              ),
              child: _buildHero(),
            );

            Widget child = Container(
              constraints: widget.tightMode
                  ? BoxConstraints.tight(scaleBoundaries.childSize * scale)
                  : null,
              child: Center(
                child: Transform(
                  child: customChildLayout,
                  transform: matrix,
                  alignment: basePosition,
                ),
              ),
              decoration: widget.backgroundDecoration ?? _defaultDecoration,
            );

            if (widget.disableGestures) {
              return child;
            }

            child = PhotoViewGestureDetector(
              child: child,
              onDoubleTap: nextScaleState,
              onScaleStart: onScaleStart,
              onScaleUpdate: onScaleUpdate,
              onScaleEnd: onScaleEnd,
              hitDetector: this,
              onTapUp: widget.onTapUp != null
                  ? (details) => widget.onTapUp!(context, details, value)
                  : null,
              onTapDown: widget.onTapDown != null
                  ? (details) => widget.onTapDown!(context, details, value)
                  : null,
            );

            child = PhotoViewScrollHandler(
              animationDelegate: this,
              child: child,
            );

            child = PhotoViewMouseRegion(
              controllerScale: scale,
              controllerPosition: value.position,
              controllerRotation: value.rotation,
              basePosition: basePosition,
              childSize: scaleBoundaries.childSize,
              viewportSize: scaleBoundaries.outerSize,
              child: child,
            );

            return child;
          } else {
            return Container();
          }
        });
  }

  Widget _buildHero() {
    return heroAttributes != null
        ? Hero(
            tag: heroAttributes!.tag,
            createRectTween: heroAttributes!.createRectTween,
            flightShuttleBuilder: heroAttributes!.flightShuttleBuilder,
            placeholderBuilder: heroAttributes!.placeholderBuilder,
            transitionOnUserGestures: heroAttributes!.transitionOnUserGestures,
            child: _buildChild(),
          )
        : _buildChild();
  }

  Widget _buildChild() {
    return widget.hasCustomChild
        ? widget.customChild!
        : Image(
            image: widget.imageProvider!,
            semanticLabel: widget.semanticLabel,
            gaplessPlayback: widget.gaplessPlayback ?? false,
            filterQuality: widget.filterQuality,
            width: scaleBoundaries.childSize.width * scale,
            fit: BoxFit.contain,
          );
  }
}

class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(
    this.subjectSize,
    this.basePosition,
    this.useImageScale,
  );

  final Size subjectSize;
  final Alignment basePosition;
  final bool useImageScale;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final childWidth = useImageScale ? childSize.width : subjectSize.width;
    final childHeight = useImageScale ? childSize.height : subjectSize.height;

    final halfWidth = (size.width - childWidth) / 2;
    final halfHeight = (size.height - childHeight) / 2;

    final double offsetX = halfWidth * (basePosition.x + 1);
    final double offsetY = halfHeight * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return useImageScale
        ? const BoxConstraints()
        : BoxConstraints.tight(subjectSize);
  }

  @override
  bool shouldRelayout(_CenterWithOriginalSizeDelegate oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CenterWithOriginalSizeDelegate &&
          runtimeType == other.runtimeType &&
          subjectSize == other.subjectSize &&
          basePosition == other.basePosition &&
          useImageScale == other.useImageScale;

  @override
  int get hashCode =>
      subjectSize.hashCode ^ basePosition.hashCode ^ useImageScale.hashCode;
}
