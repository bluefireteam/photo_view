import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

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
abstract class PhotoViewControllerBase<T extends PhotoViewControllerValue> {
  /// The output for state updates. Usually a broadcast [Stream]
  Stream<T> get outputStateStream;

  /// The state value before the last change or the initial state if trhe state has not been changed.
  T prevValue;

  /// The actual state value=l
  T value;

  /// Resets the state to the initial value;
  void reset();

  /// Closes initial streams and remove eventual listeners.
  void dispose();

  /// The position of the image in the screen given its offset after pan gestures.
  Offset position;

  /// The scale factor to transform the child (image or a customChild).
  ///
  /// **Important**: Avoid setting this field without setting [scaleState] to [PhotoViewScaleState.zooming].
  double scale;

  /// The rotation factor to transform the child (image or a customChild).
  double rotation;

  /// The center of the rotation transformation. It is a coordinate referring to the absolute dimensions of the image.
  Offset rotationFocusPoint;

  /// A way to represent the step of the "doubletap gesture cycle" in which PhotoView is.
  ///
  /// **Important**: This fields is rarely externally set to a value different than [PhotoViewScaleState.zooming] after setting a [scale].
  PhotoViewScaleState scaleState;

  /// Update multiple fields of the state with only one update streamed.
  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    PhotoViewScaleState scaleState,
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
    @required this.scaleState,
  });

  final Offset position;
  final double scale;
  final double rotation;
  final Offset rotationFocusPoint;
  final PhotoViewScaleState scaleState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoViewControllerValue &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          scale == other.scale &&
          rotation == other.rotation &&
          rotationFocusPoint == other.rotationFocusPoint &&
          scaleState == other.scaleState;

  @override
  int get hashCode =>
      position.hashCode ^
      scale.hashCode ^
      rotation.hashCode ^
      rotationFocusPoint.hashCode ^
      scaleState.hashCode;
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
      : _notifier = ValueNotifier(PhotoViewControllerValue(
            position: initialPosition,
            rotation: initialRotation,
            scale:
                null, // initial  scale is obtained via PhotoViewScaleState, therefore will be computed via scaleStateAwareScale
            scaleState: PhotoViewScaleState.initial,
            rotationFocusPoint: null)),
        super() {
    initial = value;
    prevValue = initial;
    _notifier.addListener(_changeListener);
    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);
  }

  ValueNotifier<PhotoViewControllerValue> _notifier;
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
    _notifier.dispose();
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
        scaleState: scaleState,
        rotationFocusPoint: rotationFocusPoint);
  }

  @override
  Offset get position => value.position;

  @override
  set scale(double scale) {
    if (value.scale == scale) {
      return;
    }
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
    if (value.rotation == rotation) {
      return;
    }
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
    if (value.scaleState == scaleState) {
      return;
    }
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
    if (value.rotationFocusPoint == rotationFocusPoint) {
      return;
    }
    prevValue = value;
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
    Size outerSize,
    Size childSize,
  }) {
    prevValue = value;
    value = PhotoViewControllerValue(
        position: position ?? value.position,
        scale: scale ?? value.scale,
        rotation: rotation ?? value.rotation,
        scaleState: scaleState ?? value.scaleState,
        rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint);
  }

  @override
  PhotoViewControllerValue get value => _notifier.value;

  @override
  set value(PhotoViewControllerValue newValue) {
    if (_notifier.value == newValue) return;
    _notifier.value = newValue;
  }
}
