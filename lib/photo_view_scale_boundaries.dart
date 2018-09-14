import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_computed_scale.dart';
import 'package:photo_view/photo_view_utils.dart';

class ScaleBoundaries {
  final dynamic _minScale;
  final dynamic _maxScale;
  Size size;
  ImageInfo imageInfo;

  ScaleBoundaries(this._minScale, this._maxScale,
      {@required this.size, @required this.imageInfo})
      : assert(_minScale is double || _minScale is PhotoViewComputedScale),
        assert(_maxScale is double || _maxScale is PhotoViewComputedScale);

  double computeMinScale() {
    if (_minScale == PhotoViewComputedScale.contained) {
      return scaleForContained(size: size, imageInfo: imageInfo
              // ignore: avoid_as
              ) *
          (_minScale as PhotoViewComputedScale).multiplier;
    }
    if (_minScale == PhotoViewComputedScale.covered) {
      return scaleForCovering(size: size, imageInfo: imageInfo
              // ignore: avoid_as
              ) *
          (_minScale as PhotoViewComputedScale).multiplier;
    }
    return _minScale;
  }

  double computeMaxScale() {
    if (_maxScale == PhotoViewComputedScale.contained) {
      return (scaleForContained(size: size, imageInfo: imageInfo
                  // ignore: avoid_as
                  ) *
              (_maxScale as PhotoViewComputedScale).multiplier)
          .clamp(computeMinScale(), double.infinity);
    }
    if (_maxScale == PhotoViewComputedScale.covered) {
      return (scaleForCovering(size: size, imageInfo: imageInfo
                  // ignore: avoid_as
                  ) *
              (_maxScale as PhotoViewComputedScale).multiplier)
          .clamp(computeMinScale(), double.infinity);
    }
    return _maxScale.clamp(computeMinScale(), double.infinity);
  }
}
