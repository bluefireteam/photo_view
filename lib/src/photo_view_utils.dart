import 'package:photo_view/src/photo_view_scale_state.dart';

PhotoViewScaleState nextScaleState(PhotoViewScaleState actual) {
  switch (actual) {
    case PhotoViewScaleState.initial:
      return PhotoViewScaleState.covering;
    case PhotoViewScaleState.covering:
      return PhotoViewScaleState.originalSize;
    case PhotoViewScaleState.originalSize:
      return PhotoViewScaleState.initial;
    case PhotoViewScaleState.zooming:
      return PhotoViewScaleState.initial;
    default:
      return PhotoViewScaleState.initial;
  }
}
