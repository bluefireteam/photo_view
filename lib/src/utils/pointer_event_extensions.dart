import 'package:flutter/gestures.dart';

extension PointerEventExtensions on PointerEvent {
  bool get isMouseEvent => kind == PointerDeviceKind.mouse;
  bool get isPrimaryMouseButton => buttons & kPrimaryMouseButton != 0;
}
