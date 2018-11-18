import 'package:photo_view/src/photo_view_scale_boundaries.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/photo_view_utils.dart';
import 'package:test/test.dart';

void main() {
  test("nextScaleType", () {
    expect(nextScaleState(PhotoViewScaleState.initial),
        PhotoViewScaleState.covering);
    expect(nextScaleState(PhotoViewScaleState.covering),
        PhotoViewScaleState.originalSize);
    expect(nextScaleState(PhotoViewScaleState.originalSize),
        PhotoViewScaleState.initial);
    expect(nextScaleState(PhotoViewScaleState.zooming),
        PhotoViewScaleState.initial);
    expect(nextScaleState(null), PhotoViewScaleState.initial);
  });

  test("getScaleForScaleType", () {
    expect(
        getScaleForScaleState(null, PhotoViewScaleState.originalSize, null,
            ScaleBoundaries(0.0, double.infinity, 1.0)),
        1.0);
  });
}
