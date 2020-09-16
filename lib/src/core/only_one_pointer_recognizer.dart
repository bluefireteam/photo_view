import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class OnlyOnePointerRecognizer extends ScaleGestureRecognizer {
  OnlyOnePointerRecognizer({
    Object debugOwner,
    PointerDeviceKind kind,
  }) : super(debugOwner: debugOwner, kind: kind);

  int _p = 0;
  @override
  void addPointer(PointerDownEvent event) {
    // startTrackingPointer(event.pointer);

    if (_p == 0) {
      resolve(GestureDisposition.accepted);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.rejected);
    }
  }

  // @override
  // String get debugDescription => 'only one pointer recognizer';

  // @override
  // void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }

    super.handleEvent(event);
  }
}

class OnlyOnePointerRecognizerWidget extends StatelessWidget {
  final Widget child;
  OnlyOnePointerRecognizerWidget({this.child});
  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        OnlyOnePointerRecognizer:
            GestureRecognizerFactoryWithHandlers<OnlyOnePointerRecognizer>(
          () => OnlyOnePointerRecognizer(),
          (OnlyOnePointerRecognizer instance) {},
        ),
      },
      child: child,
    );
  }
}
