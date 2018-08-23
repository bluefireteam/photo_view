import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_scale_boundary.dart';
import 'package:photo_view/photo_view_utils.dart';

class ScaleBoundaries {
  final dynamic _minScale;
  final dynamic _maxScale;
  Size size;
  ImageInfo imageInfo;

  ScaleBoundaries(this._minScale, this._maxScale, { @required this.size, @required this.imageInfo}) :
        assert(_minScale is double || _minScale is PhotoViewScaleBoundary),
        assert(_maxScale is double || _maxScale is PhotoViewScaleBoundary) ;

  double computeMinScale(){
    if(_minScale == PhotoViewScaleBoundary.contained){
      return scaleForContained(
        size: size,
        imageInfo: imageInfo
      // ignore: avoid_as
      ) * (_minScale as PhotoViewScaleBoundary).multiplier;
    }
    if(_minScale == PhotoViewScaleBoundary.covered){
      return scaleForCovering(
          size: size,
          imageInfo: imageInfo
      // ignore: avoid_as
      ) * (_minScale as PhotoViewScaleBoundary).multiplier;
    }
    return _minScale;
  }

  double computeMaxScale(){
    if(_maxScale == PhotoViewScaleBoundary.contained){
      return (scaleForContained(
          size: size,
          imageInfo: imageInfo
      // ignore: avoid_as
      ) * (_maxScale as PhotoViewScaleBoundary).multiplier).clamp(computeMinScale(), double.infinity);
    }
    if(_maxScale == PhotoViewScaleBoundary.covered){
      return (scaleForCovering(
          size: size,
          imageInfo: imageInfo
      // ignore: avoid_as
      ) * (_maxScale as PhotoViewScaleBoundary).multiplier).clamp(computeMinScale(), double.infinity);
    }
    return _maxScale.clamp(computeMinScale(), double.infinity);
  }

}