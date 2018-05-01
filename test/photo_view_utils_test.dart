import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_scale_type.dart';
import 'package:photo_view/photo_view_utils.dart';
import 'package:test/test.dart';


void main(){
  test("nextScaleType", (){
    expect(
      nextScaleType(PhotoViewScaleType.contained),
      PhotoViewScaleType.covering
    );
    expect(
      nextScaleType(PhotoViewScaleType.covering),
      PhotoViewScaleType.originalSize
    );
    expect(
      nextScaleType(PhotoViewScaleType.originalSize),
      PhotoViewScaleType.contained
    );
    expect(
      nextScaleType(PhotoViewScaleType.zooming),
      PhotoViewScaleType.contained
    );
    expect(
      nextScaleType(null),
      PhotoViewScaleType.contained
    );
  });
  
  test("getScaleForScaleType", (){
    expect(getScaleForScaleType(
      size: null, 
      scaleType: PhotoViewScaleType.originalSize, 
      imageInfo: null
    ), 1.0);
  });
}