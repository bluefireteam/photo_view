import 'dart:async';
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

  PhotoViewScaleState scaleStateSelector(PhotoViewScaleState actual);
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
    implements PhotoViewControllerBase<PhotoViewControllerValue> {
  PhotoViewController(
      {Offset initialPosition = Offset.zero, double initialRotation = 0.0})
      : super(PhotoViewControllerValue(
            position: initialPosition,
            rotation: initialRotation,
            scale:
                null, // initial  scale is obtained via PhotoViewScaleState, therefore will compute via scaleStateAwareScale
            scaleState: PhotoViewScaleState.initial,
            rotationFocusPoint: null)) {
    initial = value;
    prevValue = initial;
    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);
    super.addListener(_changeListener);
  }

  PhotoViewControllerValue initial;

  StreamController<PhotoViewControllerValue> _outputCtrl;

  @override
  Stream<PhotoViewControllerValue> get outputStateStream => _outputCtrl.stream;

  @override
  PhotoViewControllerValue prevValue;

  @override
  void reset() {
    value = initial;
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
        rotationFocusPoint: rotationFocusPoint);
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
        rotationFocusPoint: rotationFocusPoint);
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
        rotationFocusPoint: rotationFocusPoint);
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
  void onStartZooming() {
    scaleState = PhotoViewScaleState.zooming;
  }

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
        rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint);
  }

  @override
  PhotoViewScaleState scaleStateSelector(PhotoViewScaleState actual) {
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
