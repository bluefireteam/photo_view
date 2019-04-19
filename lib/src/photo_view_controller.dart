import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/photo_view_utils.dart';

typedef ScaleStateListener = void Function(double prevScale, double nextScale);

/// The interface in which controllers will be implemented.
///
/// It concerns storing the state ([PhotoViewControllerValue]) and streaming its updates.
/// [PhotoViewImageWrapper] will respond to user gestures setting thew fields in the instance of a controller.
///
/// Any instance of a controller must be disposed after unmount. So if you instantiate a [PhotoViewController] or your custom implementation, do not forget to dispose it when not using it anymore.
///
/// The controller exposes value fields like [scale] or [rotationFocus]. Usually those fields will be only getters and setters serving as hooks to the internal [PhotoViewControllerValue].
///
/// The default implementation used by [PhotoView] is [PhotoViewController].
///
/// This was created to allow customization (you can create your own controller class)
abstract class PhotoViewControllerBase<T extends PhotoViewControllerValue> {
  /// The output for state/value updates. Usually a broadcast [Stream]
  Stream<T> get outputStateStream;

  /// The state value before the last change or the initial state if trhe state has not been changed.
  T prevValue;

  /// The actual state value
  T value;

  /// Resets the state to the initial value;
  void reset();

  /// Closes initial streams and remove eventual listeners.
  void dispose();

  /// The position of the image in the screen given its offset after pan gestures.
  Offset position;

  /// The scale factor to transform the child (image or a customChild).
  ///
  /// **Important**: Avoid setting this field without setting [scaleState] to [PhotoViewScaleState.zoomedIn] or [PhotoViewScaleState.zoomedOut].  <- this has to be chnaged in the future
  double scale;

  /// The rotation factor to transform the child (image or a customChild).
  double rotation;

  /// The center of the rotation transformation. It is a coordinate referring to the absolute dimensions of the image.
  Offset rotationFocusPoint;

  /// Update multiple fields of the state with only one update streamed.
  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    Offset rotationFocusPoint,
  });
}

/// The state value stored and streamed by [PhotoViewController].
@immutable
class PhotoViewControllerValue {
  const PhotoViewControllerValue({
    @required this.position,
    @required this.scale,
    @required this.rotation,
    @required this.rotationFocusPoint,
  });

  final Offset position;
  final double scale;
  final double rotation;
  final Offset rotationFocusPoint;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoViewControllerValue &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          scale == other.scale &&
          rotation == other.rotation &&
          rotationFocusPoint == other.rotationFocusPoint;

  @override
  int get hashCode =>
      position.hashCode ^
      scale.hashCode ^
      rotation.hashCode ^
      rotationFocusPoint.hashCode;
}

/// The default implementation of [PhotoViewControllerBase].
///
/// Containing a [ValueNotifier] it stores the state in the [value] field and streams updates via [outputStateStream].
///
/// For details of fields and methods, check [PhotoViewControllerBase].
///
class PhotoViewController
    implements PhotoViewControllerBase<PhotoViewControllerValue> {
  PhotoViewController(
      {Offset initialPosition = Offset.zero, double initialRotation = 0.0})
      : _valueNotifier = ValueNotifier(PhotoViewControllerValue(
            position: initialPosition,
            rotation: initialRotation,
            scale: null, // initial  scale is obtained via PhotoViewScaleState, therefore will be computed via scaleStateAwareScale
            rotationFocusPoint: null)),
  // Todo: when user set a scale, we should update to zooming in or out
        super() {
    initial = value;
    prevValue = initial;

    _valueNotifier.addListener(_changeListener);
    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);


  }

  ValueNotifier<PhotoViewControllerValue> _valueNotifier;


  PhotoViewControllerValue initial;

  StreamController<PhotoViewControllerValue> _outputCtrl;


  @override
  Stream<PhotoViewControllerValue> get outputStateStream => _outputCtrl.stream;

  @override
  PhotoViewControllerValue prevValue;

  @override
  void reset() {
    value = initial;
    _outputScaleStateCtrl.sink.add(PhotoViewScaleState.initial);
  }

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }



  @override
  void dispose() {
    _outputCtrl.close();
    _outputScaleStateCtrl.close();
    _valueNotifier.dispose();
  }

  @override
  set position(Offset position) {
    if (value.position == position) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  Offset get position => value.position;

  @override
  set scale(double scale) {
    if (value.scale == scale) {
      return;
    }

    /// Todo: update scalestate

    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  double get scale => value.scale;

  @override
  set rotation(double rotation) {
    if (value.rotation == rotation) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  double get rotation => value.rotation;

  @override
  set rotationFocusPoint(Offset rotationFocusPoint) {
    if (value.rotationFocusPoint == rotationFocusPoint) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  Offset get rotationFocusPoint => value.rotationFocusPoint;

  @override
  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    Offset rotationFocusPoint,
  }) {

    /// Todo: update scalestate
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position ?? value.position,
        scale: scale ?? value.scale,
        rotation: rotation ?? value.rotation,
        rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint);
  }

  @override
  PhotoViewControllerValue get value => _valueNotifier.value;

  @override
  set value(PhotoViewControllerValue newValue) {
    if (_valueNotifier.value == newValue) return;
    _valueNotifier.value = newValue;
  }
}


class PhotoViewScaleStateController{
  PhotoViewScaleStateController(){
    _scaleStateNotifier = ValueNotifier(PhotoViewScaleState.initial);

    _scaleStateNotifier.addListener(_scaleStateChangeListener);
    _outputScaleStateCtrl = StreamController<PhotoViewScaleState>.broadcast();
    _outputScaleStateCtrl.sink.add(PhotoViewScaleState.initial);
  }

  ValueNotifier<PhotoViewScaleState> _scaleStateNotifier;
  StreamController<PhotoViewScaleState> _outputScaleStateCtrl;

  Stream<PhotoViewScaleState> get outputScaleStateStream =>
      _outputScaleStateCtrl.stream;

  PhotoViewScaleState get scaleState => _scaleStateNotifier.value;

  set scaleState(PhotoViewScaleState newValue) {
    if (_scaleStateNotifier.value == newValue){
      return;
    }
    _scaleStateNotifier.value = newValue;
  }

  void _scaleStateChangeListener() {
    _outputScaleStateCtrl.sink.add(scaleState);
  }

  void reset() {
    scaleState = PhotoViewScaleState.initial;
  }
}
