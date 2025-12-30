import 'package:flutter/widgets.dart';

abstract class PhotoViewAnimationDelegate {
  void animateScaleBy({required double factor, Offset? focalPoint});
}
