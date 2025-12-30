import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../utils/pointer_event_extensions.dart';

/// An immutable state class representing the current interaction mode of the cursor.
///
/// It implements `operator==` and `hashCode` to ensure that the [ValueNotifier]
/// only notifies listeners when the state *actually* changes (e.g., switching from
/// 'grab' to 'grabbing'), preventing unnecessary rebuilds of the [MouseRegion].
class _CursorState {
  const _CursorState({required this.grabbing, required this.hovering});

  final bool grabbing;
  final bool hovering;

  @override
  bool operator ==(Object other) {
    return other is _CursorState &&
        grabbing == other.grabbing &&
        hovering == other.hovering;
  }

  @override
  int get hashCode => grabbing.hashCode ^ hovering.hashCode;
}

/// A wrapper widget responsible for handling mouse interactions, specifically
/// cursor styling ("dressing") and scroll/signal events, for [PhotoView].
///
/// **The Challenge:**
/// Ideally, a [MouseRegion] would simply wrap the internal image widget. However,
/// [PhotoViewCore] uses a [CustomSingleChildLayout] to position the image. This layout
/// often clips the child to the viewport bounds. If the image is zoomed in or naturally
/// larger than the screen, a simple child-wrapper would cause the "hand" cursor to
/// disappear the moment the mouse moves outside the viewport bounds, even if the
/// image continues visually.
///
/// **The Approach:**
/// This widget wraps the entire [PhotoView] content area (at the root of the core).
/// It tracks the mouse position globally within the widget bounds and performs a
/// manual "Algebraic Hit Test" to determine if the cursor is currently hovering over
/// the image or the empty background.
///
/// It effectively implements an "Inverse Transform": taking the screen coordinate,
/// un-applying the [PhotoViewController]'s translation, scale, and rotation, and checking
/// if the resulting point lands within the original, unscaled image rectangle.
///
/// Based on this hit-test and the mouse button state, it switches the cursor:
/// * **Hovering Image:** [SystemMouseCursors.grab]
/// * **Dragging (Button Down):** [SystemMouseCursors.grabbing]
/// * **Background:** [MouseCursor.defer] (Default arrow)
///
/// **Performance:**
/// Since [onHover] events fire at a high frequency (potentially 120Hz+), minimizing
/// math in the hit-test loop seems useful. This widget uses [_recalculateLayout]
/// to cache static geometry (such as the pivot point and the unscaled image [Rect])
/// whenever the layout constraints change, leaving only the dynamic controller
/// values (scale/pan) to be calculated during the event loop.
class PhotoViewMouseRegion extends StatefulWidget {
  const PhotoViewMouseRegion({
    Key? key,
    required this.child,
    required this.controllerScale,
    required this.controllerPosition,
    required this.controllerRotation,
    required this.basePosition,
    required this.childSize,
    required this.viewportSize,
  }) : super(key: key);

  final Widget child;

  /// The current scale factor from the [PhotoViewController].
  /// Used to "un-scale" the mouse position during the hit test.
  final double controllerScale;

  /// The current translation offset from the [PhotoViewController].
  /// Used to "un-translate" the mouse position during the hit test.
  final Offset controllerPosition;

  /// The current rotation (in radians) from the [PhotoViewController].
  /// Used to "un-rotate" the mouse position during the hit test.
  final double controllerRotation;

  /// The alignment used as the origin (pivot) for transformations.
  /// Typically [Alignment.center]. This determines the point around which
  /// scaling and rotation occur.
  final Alignment basePosition;

  /// The intrinsic size of the image or custom child *before* scaling.
  /// Used to calculate the bounds of the [_cachedBaseRect].
  final Size childSize;

  /// The size of the visible area (viewport) available to the widget.
  /// Used to resolve the [basePosition] into a concrete pixel coordinate.
  final Size viewportSize;

  @override
  _PhotoViewMouseRegionState createState() => _PhotoViewMouseRegionState();
}

class _PhotoViewMouseRegionState extends State<PhotoViewMouseRegion> {
  /// Tracks the current visual state of the cursor (grabbing vs hovering).
  /// A [ValueNotifier] is used here to allow the [MouseRegion] to update its cursor
  /// without triggering a rebuild of the entire [PhotoViewMouseRegion] subtree.
  late final _cursorState =
      ValueNotifier(const _CursorState(grabbing: false, hovering: false));

  /// A cached rectangle representing the image's position and size in "layout space"
  /// (before any controller transforms are applied). Calculated in [_recalculateLayout].
  late Rect _cachedBaseRect;

  /// The cached pixel offset representing the [basePosition] within the [viewportSize].
  /// Serves as the origin/pivot point for all matrix transformations.
  late Offset _cachedPivot;

  /// Stores the last known local mouse position.
  /// This is required for [didUpdateWidget] to re-evaluate the hit test when the
  /// layout or controller values change (e.g. zooming via buttons) while the
  /// mouse remains stationary.
  Offset? _lastLocalPosition;

  @override
  void initState() {
    super.initState();
    _recalculateLayout();
  }

  @override
  void didUpdateWidget(covariant PhotoViewMouseRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recalculate if the layout changes (Resize, Image change).
    // We ignore controller changes (Zoom/Pan) here as they are applied dynamically in _hitTestImage.
    if (widget.childSize != oldWidget.childSize ||
        widget.viewportSize != oldWidget.viewportSize ||
        widget.basePosition != oldWidget.basePosition) {
      _recalculateLayout();
    }

    // Re-evaluate Cursor State
    final lastLocalPosition = _lastLocalPosition;
    if (lastLocalPosition != null && !_cursorState.value.grabbing) {
      final hit = _hitTestImage(lastLocalPosition);
      if (hit != _cursorState.value.hovering) {
        _cursorState.value = _CursorState(grabbing: false, hovering: hit);
      }
    }
  }

  void _recalculateLayout() {
    // 1. Calculate Pivot (The point around which scale/rotation occurs)
    _cachedPivot = widget.basePosition.alongSize(widget.viewportSize);

    // 2. Calculate Unscaled Image Rect
    final double childWidth = widget.childSize.width;
    final double childHeight = widget.childSize.height;

    // Logic to center/align the image within the viewport
    final double left = (widget.viewportSize.width - childWidth) / 2 +
        ((widget.viewportSize.width - childWidth) / 2 * widget.basePosition.x);
    final double top = (widget.viewportSize.height - childHeight) / 2 +
        ((widget.viewportSize.height - childHeight) /
            2 *
            widget.basePosition.y);

    _cachedBaseRect = Rect.fromLTWH(left, top, childWidth, childHeight);
  }

  bool _hitTestImage(Offset screenPoint) {
    // Un-apply Pivot
    double dx = screenPoint.dx - _cachedPivot.dx;
    double dy = screenPoint.dy - _cachedPivot.dy;

    // Un-apply Translation
    dx -= widget.controllerPosition.dx;
    dy -= widget.controllerPosition.dy;

    // Un-apply Scale
    dx /= widget.controllerScale;
    dy /= widget.controllerScale;

    // Un-apply Rotation
    if (widget.controllerRotation != 0) {
      final double c = math.cos(-widget.controllerRotation);
      final double s = math.sin(-widget.controllerRotation);
      final double tx = dx * c - dy * s;
      final double ty = dx * s + dy * c;
      dx = tx;
      dy = ty;
    }

    // Re-apply Pivot to get back to local coordinates
    final double localX = dx + _cachedPivot.dx;
    final double localY = dy + _cachedPivot.dy;

    // Check against cached Rect
    return _cachedBaseRect.contains(Offset(localX, localY));
  }

  @override
  void dispose() {
    _cursorState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: ValueListenableBuilder<_CursorState>(
        valueListenable: _cursorState,
        builder: (context, cursorState, child) {
          return MouseRegion(
            hitTestBehavior: HitTestBehavior.translucent,
            opaque: true,
            onEnter: _onMouseEnter,
            onExit: _onMouseExit,
            onHover: _onMouseHover,
            cursor: cursorState.grabbing
                ? SystemMouseCursors.grabbing
                : cursorState.hovering
                    ? SystemMouseCursors.grab
                    : MouseCursor.defer,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!event.isMouseEvent ||
        !event.isPrimaryMouseButton ||
        !_hitTestImage(event.localPosition)) {
      return;
    }

    _cursorState.value = const _CursorState(grabbing: true, hovering: true);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!event.isMouseEvent || !_cursorState.value.grabbing) {
      return;
    }

    _cursorState.value =
        _CursorState(grabbing: false, hovering: _cursorState.value.hovering);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!event.isMouseEvent || !_cursorState.value.grabbing) {
      return;
    }

    _cursorState.value =
        _CursorState(grabbing: false, hovering: _cursorState.value.hovering);
  }

  void _onMouseEnter(PointerEnterEvent event) {
    _lastLocalPosition = event.localPosition;

    if (!event.isMouseEvent || _cursorState.value.grabbing) {
      return;
    }

    final hit = _hitTestImage(event.localPosition);
    _cursorState.value = _CursorState(grabbing: false, hovering: hit);
  }

  void _onMouseExit(PointerExitEvent event) {
    _lastLocalPosition = null;

    if (!event.isMouseEvent || !_cursorState.value.hovering) {
      return;
    }
    _cursorState.value = const _CursorState(grabbing: false, hovering: false);
  }

  void _onMouseHover(PointerHoverEvent event) {
    _lastLocalPosition = event.localPosition;

    if (!event.isMouseEvent || _cursorState.value.grabbing) {
      return;
    }

    final hovering = _cursorState.value.hovering;
    final hit = _hitTestImage(event.localPosition);
    if (hit != hovering) {
      _cursorState.value =
          _CursorState(grabbing: _cursorState.value.grabbing, hovering: hit);
    }
  }
}
