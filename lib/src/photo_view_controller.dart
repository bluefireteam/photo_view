import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

mixin PhotoViewControllerBase on ValueNotifier<PhotoViewControllerValue> {
  void reset();

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

  void addScaleStateListener(Function listener);
  void removeScaleStateListener(Function listener);

  void nextScaleState();
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
    with PhotoViewControllerBase {
  PhotoViewController(
      {final double minScale,
      final double maxScale,
      final double initialScale,
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
          childSize: null,
          outerSize: null,
        )) {
    initial = value;
  }

  PhotoViewControllerValue initial;

  _ScaleBoundaries _scaleBoundaries;

  PhotoViewScaleState _prevScaleState;

  @override
  void reset() {
    value = initial;
  }

  @override
  double get scaleStateAwareScale {
    return value.scale != null ||
            value.scaleState == PhotoViewScaleState.zooming
        ? value.scale
        : _getScaleForScaleState(
            value.scaleState, _scaleBoundaries, outerSize, childSize);
  }

  @override
  set position(Offset position) {
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
    _prevScaleState = this.scaleState;
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

  HashMap<VoidCallback, Function> scaleStateListeners =
      HashMap<VoidCallback, Function>();

  @override
  void addScaleStateListener(Function listener) {
    scaleStateListeners[listener] = _scaleStateListener(listener);
    super.addListener(scaleStateListeners[listener]);
  }

  @override
  void removeScaleStateListener(Function listener) {
    super.removeListener(scaleStateListeners[listener]);
  }

  Function _scaleStateListener(Function listener) => () {
        if (_prevScaleState != scaleState &&
            scaleState != PhotoViewScaleState.zooming) {
          final double prevScale = scale == null
              ? _getScaleForScaleState(PhotoViewScaleState.initial,
                  _scaleBoundaries, outerSize, childSize)
              : scale;

          final double nextScale = _getScaleForScaleState(
              scaleState, _scaleBoundaries, outerSize, childSize);
          listener(prevScale, nextScale);
        }
      };

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

    final double originalScale = _getScaleForScaleState(
        scaleState, _scaleBoundaries, outerSize, childSize);

    double prevScale = originalScale;
    PhotoViewScaleState prevScaleState = scaleState;
    double nextScale = originalScale;
    PhotoViewScaleState nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = _scaleStateSelector(prevScaleState);
      nextScale = _getScaleForScaleState(
          nextScaleState, _scaleBoundaries, outerSize, childSize);
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

double _getScaleForScaleState(PhotoViewScaleState scaleState,
    _ScaleBoundaries scaleBoundaries, Size outerSize, Size childSize) {
  switch (scaleState) {
    case PhotoViewScaleState.initial:
      return _clampSize(scaleBoundaries.getInitialScale(outerSize, childSize),
          scaleBoundaries, outerSize, childSize);
    case PhotoViewScaleState.covering:
      return _clampSize(_scaleForCovering(outerSize, childSize),
          scaleBoundaries, outerSize, childSize);
    case PhotoViewScaleState.originalSize:
      return _clampSize(1.0, scaleBoundaries, outerSize, childSize);
    default:
      return null;
  }
}

double _clampSize(double size, _ScaleBoundaries scaleBoundaries, Size outerSize,
    Size childSize) {
  return size.clamp(scaleBoundaries.getMinScale(outerSize, childSize),
      scaleBoundaries.getMaxScale(outerSize, childSize));
}
