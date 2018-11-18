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

double getScaleForScaleState(Size size, PhotoViewScaleState scaleState, ImageInfo imageInfo, ScaleBoundaries scaleBoundaries) {
  switch (scaleState) {
    case PhotoViewScaleState.initial:
      return scaleBoundaries.computeInitialScale();
    case PhotoViewScaleState.covering:
      return scaleForCovering(size: size, imageInfo: imageInfo);
    case PhotoViewScaleState.originalSize:
      return 1.0;
    default:
      return null;
  }
}

double scaleForContained({@required Size size, @required ImageInfo imageInfo}) {
  final int imageWidth = imageInfo.image.width;
  final int imageHeight = imageInfo.image.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.min(screenWidth / imageWidth, screenHeight / imageHeight);
}

double scaleForCovering({@required Size size, @required ImageInfo imageInfo}) {
  final int imageWidth = imageInfo.image.width;
  final int imageHeight = imageInfo.image.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.max(screenWidth / imageWidth, screenHeight / imageHeight);
}
