import 'package:photo_view/photo_view_scale_state.dart';
import 'package:photo_view/photo_view_utils.dart';
import 'package:test/test.dart';

void main() {
  test("nextScaleType", () {
    expect(nextScaleState(PhotoViewScaleState.contained),
        PhotoViewScaleState.covering);
    expect(nextScaleState(PhotoViewScaleState.covering),
        PhotoViewScaleState.originalSize);
    expect(nextScaleState(PhotoViewScaleState.originalSize),
        PhotoViewScaleState.contained);
    expect(nextScaleState(PhotoViewScaleState.zooming),
        PhotoViewScaleState.contained);
    expect(nextScaleState(null), PhotoViewScaleState.contained);
  });

  test("getScaleForScaleType", () {
    expect(
        getScaleForScaleState(
            size: null,
            scaleState: PhotoViewScaleState.originalSize,
            imageInfo: null),
        1.0);
  });
}
