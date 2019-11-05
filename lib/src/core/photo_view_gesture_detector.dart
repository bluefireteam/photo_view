import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'photo_view_hit_corners.dart';

class PhotoViewGestureDetector extends StatelessWidget {
  const PhotoViewGestureDetector({
    Key key,
    this.hitDetector,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onDoubleTap,
    this.child,
  }) : super(key: key);

  final GestureDoubleTapCallback onDoubleTap;
  final HitCornersDetector hitDetector;

  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      child: child,
      gestures: <Type, GestureRecognizerFactory>{
        PhotoViewGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PhotoViewGestureRecognizer>(
          () => PhotoViewGestureRecognizer(hitDetector, this),
          (PhotoViewGestureRecognizer instance) {
            instance
              ..onStart = onScaleStart
              ..onUpdate = onScaleUpdate
              ..onEnd = onScaleEnd;
          },
        ),
        DoubleTapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
          () => DoubleTapGestureRecognizer(debugOwner: this),
          (DoubleTapGestureRecognizer instance) {
            instance..onDoubleTap = onDoubleTap;
          },
        )
      },
    );
  }
}

class PhotoViewGestureRecognizer extends ScaleGestureRecognizer {
  PhotoViewGestureRecognizer(
    this.hitDetector,
    Object debugOwner,
  ) : super(debugOwner: debugOwner);
  final HitCornersDetector hitDetector;

  Map<int, Offset> _pointerLocations = <int, Offset>{};

  Offset _initialFocalPoint;
  Offset _currentFocalPoint;

  bool ready = true;

  @override
  void addAllowedPointer(PointerEvent event) {
    if (ready) {
      ready = false;
      _pointerLocations = <int, Offset>{};
    }
    super.addAllowedPointer(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    ready = true;
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _computeEvent(event);
    _updateDistances();
    _decideIfWeAcceptEvent(event);

    super.handleEvent(event);
  }

  void _computeEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (!event.synthesized) _pointerLocations[event.pointer] = event.position;
    } else if (event is PointerDownEvent) {
      _pointerLocations[event.pointer] = event.position;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerLocations.remove(event.pointer);
    }

    _initialFocalPoint = _currentFocalPoint;
  }

  void _updateDistances() {
    final int count = _pointerLocations.keys.length;
    Offset focalPoint = Offset.zero;
    for (int pointer in _pointerLocations.keys)
      focalPoint += _pointerLocations[pointer];
    _currentFocalPoint =
        count > 0 ? focalPoint / count.toDouble() : Offset.zero;
  }

  void _decideIfWeAcceptEvent(PointerEvent event) {
    if (!(event is PointerMoveEvent)) {
      return;
    }
    if (hitDetector.shouldMoveX(_initialFocalPoint - _currentFocalPoint) ||
        _pointerLocations.keys.length > 1) {
      resolve(GestureDisposition.accepted);
    }
  }
}
