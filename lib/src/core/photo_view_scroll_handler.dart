import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart';
import 'package:photo_view/src/utils/pointer_event_extensions.dart';

/// A wrapper widget responsible for handling desktop-style pointer events for [PhotoView].
///
/// This widget acts as an input adapter. It captures hardware events (Mouse Wheel,
/// Trackpad gestures, Browser scale events) and translates them into semantic
/// animation commands for the [PhotoViewAnimationDelegate].
///
/// **Key Features:**
///
/// * **Event Normalization:**
///   Different input devices report scroll and zoom interactions differently.
///   This widget unifies them into consistent calls:
///   - [PointerScrollEvent]: Standard mouse wheel. Mapped to Panning.
///   - [PointerScaleEvent]: Pinch-to-zoom signals (common in browsers). Mapped to Zooming.
///   - [PointerPanZoomUpdateEvent]: Continuous trackpad gestures. Mapped to Zooming.
///
/// * **Modifier Keys Support:**
///   - **Ctrl + Scroll:** Intercepts standard scrolling to perform "Zoom-to-Cursor".
///   - **Shift + Scroll:** Intercepts vertical scrolling to perform horizontal panning.
///
/// * **Delegation:**
///   This widget calculates the user's *intent* (e.g., "Zoom in by 5% at this pixel")
///   and forwards it to the [animationDelegate], which handles the physics,
///   clamping, and rendering updates.
class PhotoViewScrollHandler extends StatefulWidget {
  const PhotoViewScrollHandler({
    Key? key,
    required this.child,
    required this.animationDelegate,
  }) : super(key: key);

  /// The widget subtree.
  final Widget child;

  /// The delegate capable of executing smooth, additive animations.
  final PhotoViewAnimationDelegate animationDelegate;

  @override
  State<PhotoViewScrollHandler> createState() => _PhotoViewScrollHandlerState();
}

class _PhotoViewScrollHandlerState extends State<PhotoViewScrollHandler> {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
      child: widget.child,
    );
  }

  /// Handles continuous trackpad gestures (e.g. Mac trackpads).
  /// These events often contain both scale (pinch) and pan (scroll) data.
  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (!event.isMouseEvent) {
      return;
    }

    // Handle Trackpad Pinch
    if (event.scale != 1.0) {
      widget.animationDelegate.animateScaleBy(
        factor: event.scale,
        focalPoint: event.localPosition,
      );
    }
  }

  /// Handles discrete mouse events (Wheel) and browser scale events.
  void _onPointerSignal(PointerSignalEvent event) {
    if (!event.isMouseEvent) {
      return;
    }

    if (event is PointerScrollEvent) {
      _handleScrollEvent(event);
    } else if (event is PointerScaleEvent) {
      widget.animationDelegate.animateScaleBy(
        /// The regular mouse zoom event (PointerScaleEvent) is often quite aggressive.
        /// We dampen it by 50% to feel more natural compared to touch gestures.
        factor: (event.scale - 1.0) * 0.5 + 1.0,
        focalPoint: event.localPosition,
      );
    }
  }

  void _handleScrollEvent(PointerScrollEvent event) {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final ctrlPressed = keys.contains(LogicalKeyboardKey.controlLeft) ||
        keys.contains(LogicalKeyboardKey.controlRight);

    // --- ZOOM (Ctrl + Scroll) ---
    if (ctrlPressed) {
      final double scrollDelta = event.scrollDelta.dy;
      if (scrollDelta == 0) {
        return;
      }

      // Map scroll direction to a consistent zoom factor (approx 5% per tick)
      final double zoomFactor = scrollDelta > 0 ? 0.95 : 1.05;

      widget.animationDelegate.animateScaleBy(
        factor: zoomFactor,
        focalPoint: event.localPosition,
      );
    }
    // --- PAN (Standard Scroll) ---
    else {
      final bool shift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
          keys.contains(LogicalKeyboardKey.shiftRight);

      double deltaX = -event.scrollDelta.dx;
      double deltaY = -event.scrollDelta.dy;

      // Shift + Vertical Scroll = Horizontal Scroll
      if (shift && deltaX == 0) {
        deltaX = deltaY;
        deltaY = 0;
      }

      // We negate the inputs because standard scrolling moves "content up" (negative delta),
      // but in PhotoView's coordinate system, moving the position "up" (negative offset)
      // actually reveals lower content.
      final Offset scrollDelta = Offset(deltaX, deltaY);

      widget.animationDelegate.animatePositionBy(delta: scrollDelta);
    }
  }
}
