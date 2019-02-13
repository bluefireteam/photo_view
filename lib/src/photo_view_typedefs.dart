import 'package:photo_view/photo_view.dart';

/// A type definition for a [Function] that receives a [PhotoViewScaleState]
typedef PhotoViewScaleStateChangedCallback = void Function(
    PhotoViewScaleState scaleState);

/// A type definition for a [Function] that receives the actual [PhotoViewScaleState] and returns the next one
/// It is used internally to walk in the "doubletap gesture cycle".
/// It is passed to [PhotoView.scaleStateCycle]
typedef ScaleStateCycle = PhotoViewScaleState Function(
    PhotoViewScaleState actual);
