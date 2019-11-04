import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart';

class PhotoViewGestureDetector extends StatelessWidget {
  const PhotoViewGestureDetector({
    Key key,
    this.hitDetector,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onDoubleTap,
  }) : super(key: key);

  final GestureDoubleTapCallback onDoubleTap;
  final HitCornersDetector hitDetector;

  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        PhotoViewGestureRecognizer: GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
          () => ScaleGestureRecognizer(debugOwner: this),
          (ScaleGestureRecognizer instance) {
            instance
              ..onStart = onScaleStart
              ..onUpdate = onScaleUpdate
              ..onEnd = onScaleEnd;
          },
        ),
        DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
              () => DoubleTapGestureRecognizer(debugOwner: this),
              (DoubleTapGestureRecognizer instance) {
            instance
              ..onDoubleTap = onDoubleTap;
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
}
