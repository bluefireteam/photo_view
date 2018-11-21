import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_scale_boundaries.dart';
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

double _clampIt(double size, ScaleBoundaries scaleBoundaries) {
  return size.clamp(
      scaleBoundaries.computeMinScale(), scaleBoundaries.computeMaxScale());
}

double getScaleForScaleState(Size size, PhotoViewScaleState scaleState,
    Size childSize, ScaleBoundaries scaleBoundaries) {
  switch (scaleState) {
    case PhotoViewScaleState.initial:
      return _clampIt(scaleBoundaries.computeInitialScale(), scaleBoundaries);
    case PhotoViewScaleState.covering:
      return _clampIt(
          scaleForCovering(size: size, childSize: childSize), scaleBoundaries);
    case PhotoViewScaleState.originalSize:
      return _clampIt(1.0, scaleBoundaries);
    default:
      return null;
  }
}

double scaleForContained({@required Size size, @required Size childSize}) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.min(screenWidth / imageWidth, screenHeight / imageHeight);
}

double scaleForCovering({@required Size size, @required Size childSize}) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.max(screenWidth / imageWidth, screenHeight / imageHeight);
}
