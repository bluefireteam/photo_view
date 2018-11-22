import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_utils.dart';

class ScaleBoundaries {
  ScaleBoundaries(this._minScale, this._maxScale, this._initialScale,
      {@required this.size, @required this.childSize})
      : assert(_minScale is double || _minScale is PhotoViewComputedScale),
        assert(_maxScale is double || _maxScale is PhotoViewComputedScale),
        assert(
            _initialScale is double || _initialScale is PhotoViewComputedScale);

  final dynamic _minScale;
  final dynamic _maxScale;
  final dynamic _initialScale;
  Size size;
  Size childSize;

  double computeMinScale() {
    if (_minScale == PhotoViewComputedScale.contained) {
      return scaleForContained(size: size, childSize: childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    if (_minScale == PhotoViewComputedScale.covered) {
      return scaleForCovering(size: size, childSize: childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    assert(_minScale >= 0.0);
    return _minScale;
  }

  double computeMaxScale() {
    if (_maxScale == PhotoViewComputedScale.contained) {
      return (scaleForContained(size: size, childSize: childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(computeMinScale(), double.infinity);
    }
    if (_maxScale == PhotoViewComputedScale.covered) {
      return (scaleForCovering(size: size, childSize: childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(computeMinScale(), double.infinity);
    }
    return _maxScale.clamp(computeMinScale(), double.infinity);
  }

  double computeInitialScale() {
    if (_initialScale == PhotoViewComputedScale.contained) {
      return scaleForContained(size: size, childSize: childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    if (_initialScale == PhotoViewComputedScale.covered) {
      return scaleForCovering(size: size, childSize: childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    return _initialScale.clamp(computeMinScale(), computeMaxScale());
  }
}
