import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

typedef ScaleStateListener = void Function(double prevScale, double nextScale);

abstract class PhotoViewControllerBase<T extends PhotoViewControllerValue> {
  Stream<T> get outputStateStream;

  T prevValue;

  void reset();
  void dispose();

  double get scaleStateAwareScale;
  Size childSize;
  Size outerSize;

  Offset position;
  double scale;
  double rotation;
  Offset rotationFocusPoint;
  PhotoViewScaleState scaleState;

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  dynamic maxScale;

  // Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  dynamic minScale;

  /// Defines the initial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  dynamic initialScale;

  void onStartZooming();

  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    PhotoViewScaleState scaleState,
    Offset rotationFocusPoint,
  });

  void nextScaleState();

  double getScaleForScaleState(PhotoViewScaleState scaleState);
}

@immutable
class PhotoViewControllerValue {
  const PhotoViewControllerValue({
    @required this.position,
    @required this.scale,
    @required this.rotation,
    @required this.rotationFocusPoint,
    @required this.scaleState,
    @required this.outerSize,
    @required this.childSize,
  });

  final Offset position;
  final double scale;
  final double rotation;
  final Offset rotationFocusPoint;
  final PhotoViewScaleState scaleState;

  final Size outerSize;
  final Size childSize;
}

class PhotoViewController extends ValueNotifier<PhotoViewControllerValue>
    implements PhotoViewControllerBase<PhotoViewControllerValue> {
  PhotoViewController(
      {final dynamic minScale,
      final dynamic maxScale,
      final dynamic initialScale,
      Offset initialPosition = Offset.zero,
      double initialRotation = 0.0})
      : _scaleBoundaries = _ScaleBoundaries(
          minScale ?? 0.0,
          maxScale ?? double.infinity,
          initialScale ?? PhotoViewComputedScale.contained,
        ),
        super(PhotoViewControllerValue(
          position: initialPosition,
          rotation: initialRotation,
          scale:
              null, // initial  scale is obtained via PhotoViewScaleState, therefore will compute via scaleStateAwareScale
          scaleState: PhotoViewScaleState.initial,
          rotationFocusPoint: null,
          childSize: Size.zero,
          outerSize: Size.zero,
        )) {
    initial = value;
    prevValue = initial;
    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);
    super.addListener(_changeListener);
  }

  PhotoViewControllerValue initial;
  _ScaleBoundaries _scaleBoundaries;

  StreamController<PhotoViewControllerValue> _outputCtrl;

  @override
  Stream<PhotoViewControllerValue> get outputStateStream => _outputCtrl.stream;

  @override
  PhotoViewControllerValue prevValue;

  @override
  void reset() {
    value = initial;
  }

  @override
  double get scaleStateAwareScale {
    return value.scale ?? getScaleForScaleState(value.scaleState);
  }

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }

  @override
  void dispose() {
    _outputCtrl.close();
    super.dispose();
  }

  @override
  set position(Offset position) {
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
  }

  @override
  Offset get position => value.position;

  @override
  set scale(double scale) {
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
  }

  @override
  double get scale => value.scale;

  @override
  set rotation(double rotation) {
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
  }

  @override
  double get rotation => value.rotation;

  @override
  set scaleState(PhotoViewScaleState scaleState) {
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
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
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
  }

  @override
  Offset get rotationFocusPoint => value.rotationFocusPoint;

  @override
  set childSize(Size childSize) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
  }

  @override
  Size get childSize => value.childSize;

  @override
  set outerSize(Size outerSize) {
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint,
        outerSize: outerSize,
        childSize: childSize);
  }

  @override
  Size get outerSize => value.outerSize;

  @override
  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    PhotoViewScaleState scaleState,
    Offset rotationFocusPoint,
    Size outerSize,
    Size childSize,
  }) {
    value = PhotoViewControllerValue(
      position: position ?? value.position,
      scale: scale ?? value.scale,
      rotation: rotation ?? value.rotation,
      scaleState: scaleState ?? value.scaleState,
      rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint,
      outerSize: outerSize ?? value.outerSize,
      childSize: childSize ?? value.childSize,
    );
  }

  @override
  void onStartZooming() {
    scaleState = PhotoViewScaleState.zooming;
  }

  @override
  set initialScale(_initialScale) {
    _scaleBoundaries._initialScale = initialScale;
  }

  @override
  dynamic get initialScale =>
      _scaleBoundaries.getInitialScale(outerSize, childSize);

  @override
  set maxScale(_maxScale) {
    _scaleBoundaries._maxScale = _maxScale;
  }

  @override
  dynamic get maxScale => _scaleBoundaries.getMaxScale(outerSize, childSize);

  @override
  set minScale(_minScale) {
    _scaleBoundaries._minScale = _minScale;
  }

  @override
  dynamic get minScale => _scaleBoundaries.getMinScale(outerSize, childSize);

  @override
  void nextScaleState() {
    if (scaleState == PhotoViewScaleState.zooming) {
      scaleState = _scaleStateSelector(scaleState);
      return;
    }

    final double originalScale = getScaleForScaleState(scaleState);

    double prevScale = originalScale;
    PhotoViewScaleState prevScaleState = scaleState;
    double nextScale = originalScale;
    PhotoViewScaleState nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = _scaleStateSelector(prevScaleState);
      nextScale = getScaleForScaleState(nextScaleState);
    } while (prevScale == nextScale && scaleState != nextScaleState);

    if (originalScale == nextScale) {
      return;
    }

    scaleState = nextScaleState;
  }

  PhotoViewScaleState _scaleStateSelector(PhotoViewScaleState actual) {
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

  @override
  double getScaleForScaleState(PhotoViewScaleState scaleState) {
    switch (scaleState) {
      case PhotoViewScaleState.initial:
      case PhotoViewScaleState.zooming:
        return _clampSize(
            _scaleBoundaries.getInitialScale(outerSize, childSize),
            _scaleBoundaries,
            outerSize,
            childSize);
      case PhotoViewScaleState.covering:
        return _clampSize(_scaleForCovering(outerSize, childSize),
            _scaleBoundaries, outerSize, childSize);
      case PhotoViewScaleState.originalSize:
        return _clampSize(1.0, _scaleBoundaries, outerSize, childSize);
      default:
        return null;
    }
  }
}

class _ScaleBoundaries {
  _ScaleBoundaries(this._minScale, this._maxScale, this._initialScale)
      : assert(_minScale is double || _minScale is PhotoViewComputedScale),
        assert(_maxScale is double || _maxScale is PhotoViewComputedScale),
        assert(
            _initialScale is double || _initialScale is PhotoViewComputedScale);

  dynamic _minScale;
  dynamic _maxScale;
  dynamic _initialScale;

  double getMinScale(Size outerSize, Size childSize) {
    if (_minScale == PhotoViewComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    if (_minScale == PhotoViewComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_minScale as PhotoViewComputedScale).multiplier; // ignore: avoid_as
    }
    assert(_minScale >= 0.0);
    return _minScale;
  }

  double getMaxScale(Size outerSize, Size childSize) {
    if (_maxScale == PhotoViewComputedScale.contained) {
      return (_scaleForContained(outerSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(getMinScale(outerSize, childSize), double.infinity);
    }
    if (_maxScale == PhotoViewComputedScale.covered) {
      return (_scaleForCovering(outerSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(getMinScale(outerSize, childSize), double.infinity);
    }
    return _maxScale.clamp(getMinScale(outerSize, childSize), double.infinity);
  }

  double getInitialScale(Size outerSize, Size childSize) {
    if (_initialScale == PhotoViewComputedScale.contained) {
      return _scaleForContained(outerSize, childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    if (_initialScale == PhotoViewComputedScale.covered) {
      return _scaleForCovering(outerSize, childSize) *
          (_initialScale as PhotoViewComputedScale) // ignore: avoid_as
              .multiplier;
    }
    return _initialScale.clamp(
        getMinScale(outerSize, childSize), getMaxScale(outerSize, childSize));
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

double _clampSize(double size, _ScaleBoundaries scaleBoundaries, Size outerSize,
    Size childSize) {
  return size.clamp(scaleBoundaries.getMinScale(outerSize, childSize),
      scaleBoundaries.getMaxScale(outerSize, childSize));
}
