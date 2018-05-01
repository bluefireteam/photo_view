import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:photo_view/photo_view_scale_type.dart';


PhotoViewScaleType nextScaleType(PhotoViewScaleType actual){
  switch (actual) {
    case PhotoViewScaleType.contained:
      return PhotoViewScaleType.covering;
    case PhotoViewScaleType.covering:
      return PhotoViewScaleType.originalSize;
    case PhotoViewScaleType.originalSize:
      return PhotoViewScaleType.contained;
    case PhotoViewScaleType.zooming:
      return PhotoViewScaleType.contained;
    default:
      return PhotoViewScaleType.contained;
  }
}


double getScaleForScaleType({
  @required Size size,
  @required PhotoViewScaleType scaleType,
  @required ImageInfo imageInfo
}){
  switch (scaleType){
    case PhotoViewScaleType.contained:
      return scaleForContained(
          size: size,
          imageInfo: imageInfo
      );
    case PhotoViewScaleType.covering:
      return scaleForCovering(
          size: size,
          imageInfo: imageInfo
      );
    case PhotoViewScaleType.originalSize:
      return 1.0;
    default:
      return null;
  }
}

double scaleForContained({
  @required Size size,
  @required ImageInfo imageInfo
}){
  final int imageWidth = imageInfo.image.width;
  final int imageHeight = imageInfo.image.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return Math.min(screenWidth/imageWidth, screenHeight/imageHeight);
}


double scaleForCovering({
  @required Size size,
  @required ImageInfo imageInfo
}){
  final int imageWidth = imageInfo.image.width;
  final int imageHeight = imageInfo.image.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return Math.max(screenWidth/imageWidth, screenHeight/imageHeight);
}
