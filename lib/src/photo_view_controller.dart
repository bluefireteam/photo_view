import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

/// callbacks?
/// DONE eset?
/// double tap response (contraints)
/// clamp position
/// DONE store state: scalestate, scale, positionoffset, subjectsize, size
/// callbacks: ondoubletap, onscalestart, onscalegesturefinish, onscalefinish
/// doubletap gesture cycle
/// initiascalel comparizon after animatioons
/// animation curvesn and dureation
/// scaleto
/// baseposition #79
/// clamping behavior (position and scale): animated, strict, not clamp
/// evaluatiom after clamp

abstract class PhotoViewControllerBase {
  _ScaleBoundaries scaleBoundaries;

  void reset();

  double get scaleStateAwareScale;
  Offset position;
  double scale;
  double rotation;
  Offset rotationFocusPoint;
  PhotoViewScaleState scaleState;

  void onStartZooming();

  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    PhotoViewScaleState scaleState,
    Offset rotationFocusPoint,
  });
}

@immutable
class PhotoViewControllerValue {
  const PhotoViewControllerValue({
    @required this.position,
    @required this.scale,
    @required this.rotation,
    @required this.rotationFocusPoint,
    @required this.scaleState,
  });

  final Offset position;
  final double scale;
  final double rotation;
  final Offset rotationFocusPoint;
  final PhotoViewScaleState scaleState;
}

class PhotoViewController extends ValueNotifier<PhotoViewControllerValue>
    implements PhotoViewControllerBase {
  PhotoViewController(
      {final double minScale,
      final double maxScale,
      final double initialScale,
      Size customSize,
      Size childSize,
      Offset initialPosition = Offset.zero,
      double initialRotation = 0.0})
      : scaleBoundaries = _ScaleBoundaries(
          minScale ?? 0.0,
          maxScale ?? double.infinity,
          initialScale ?? PhotoViewComputedScale.contained,
          childSize: childSize,
          customSize: customSize,
        ),
        super(PhotoViewControllerValue(
          position: initialPosition,
          rotation: initialRotation,
          scale:
              null, // initial  scale is obtained via PhotoViewScaleState, therefore will compute via scaleStateAwareScale
          scaleState: PhotoViewScaleState.initial,
        )) {
    initial = value;
  }

  PhotoViewControllerValue initial;

  @override
  _ScaleBoundaries scaleBoundaries;

  set childSize(Size newChildSize) {
    scaleBoundaries.childSize = newChildSize;
  }

  set customSize(Size newCustomSize) {
    scaleBoundaries.customSize = newCustomSize;
  }

  @override
  void reset() {
    value = initial;
  }

  @override
  double get scaleStateAwareScale {
    return value.scale != null ||
            value.scaleState == PhotoViewScaleState.zooming
        ? value.scale
        : _getScaleForScaleState(value.scaleState, scaleBoundaries);
  }

  @override
  set position(Offset position) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  Offset get position => value.position;

  @override
  set scale(double scale) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  double get scale => value.scale;

  @override
  set rotation(double rotation) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  double get rotation => value.rotation;

  @override
  set scaleState(PhotoViewScaleState scaleState) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  PhotoViewScaleState get scaleState => value.scaleState;

  @override
  set rotationFocusPoint(Offset rotationFocusPoint) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  Offset get rotationFocusPoint => value.rotationFocusPoint;

  @override
  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    PhotoViewScaleState scaleState,
    Offset rotationFocusPoint,
  }) {
    value = PhotoViewControllerValue(
        position: position ?? value.position,
        scale: scale ?? value.scale,
        rotation: rotation ?? value.rotation,
        scaleState: scaleState ?? value.scaleState,
        rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint);
  }

  @override
  void onStartZooming() {
    scaleState = PhotoViewScaleState.zooming;
  }
}

class _ScaleBoundaries {
  _ScaleBoundaries(this._minScale, this._maxScale, this._initialScale,
      {@required this.customSize, @required this.childSize})
      : assert(_minScale is double || _minScale is PhotoViewComputedScale),
        assert(_maxScale is double || _maxScale is PhotoViewComputedScale),
        assert(
            _initialScale is double || _initialScale is PhotoViewComputedScale);

  final dynamic _minScale;
  final dynamic _maxScale;
  final dynamic _initialScale;
  Size customSize;
  Size childSize;

  double get minScale {
    if (_minScale == PhotoViewComputedScale.contained) {
      return _scaleForContained(customSize, childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    if (_minScale == PhotoViewComputedScale.covered) {
      return _scaleForCovering(customSize, childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    assert(_minScale >= 0.0);
    return _minScale;
  }

  double get maxScale {
    if (_maxScale == PhotoViewComputedScale.contained) {
      return (_scaleForContained(customSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    if (_maxScale == PhotoViewComputedScale.covered) {
      return (_scaleForCovering(customSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    return _maxScale.clamp(minScale, double.infinity);
  }

  double get initialScale {
    if (_initialScale == PhotoViewComputedScale.contained) {
      return _scaleForContained(customSize, childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    if (_initialScale == PhotoViewComputedScale.covered) {
      return _scaleForCovering(customSize, childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    return _initialScale.clamp(minScale, maxScale);
  }
}

double _scaleForContained(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.min(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _scaleForCovering(Size size, Size childSize) {
  final double imageWidth = childSize.width;
  final double imageHeight = childSize.height;

  final double screenWidth = size.width;
  final double screenHeight = size.height;

  return math.max(screenWidth / imageWidth, screenHeight / imageHeight);
}

double _getScaleForScaleState(
    PhotoViewScaleState scaleState, _ScaleBoundaries scaleBoundaries) {
  switch (scaleState) {
    case PhotoViewScaleState.initial:
      return _clampSize(scaleBoundaries.initialScale, scaleBoundaries);
    case PhotoViewScaleState.covering:
      return _clampSize(
          _scaleForCovering(
              scaleBoundaries.customSize, scaleBoundaries.childSize),
          scaleBoundaries);
    case PhotoViewScaleState.originalSize:
      return _clampSize(1.0, scaleBoundaries);
    default:
      return null;
  }
}

double _clampSize(double size, _ScaleBoundaries scaleBoundaries) {
  return size.clamp(scaleBoundaries.minScale, scaleBoundaries.maxScale);
}
