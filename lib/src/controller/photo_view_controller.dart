import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:photo_view/src/controller/photo_view_controller_base.dart';
import 'package:photo_view/src/controller/photo_view_controller_delegate.dart';
import 'package:photo_view/src/utils/ignorable_change_notifier.dart';

/// The default implementation of [PhotoViewControllerBase].
///
/// Containing a [ValueNotifier] it stores the state in the [value] field and streams
/// updates via [outputStateStream].
///
/// For details of fields and methods, check [PhotoViewControllerBase].
///
class PhotoViewController
    implements PhotoViewControllerBase<PhotoViewControllerValue> {
  PhotoViewController({
    Offset initialPosition = Offset.zero,
    double initialRotation = 0.0,
    double? initialScale,
  })  : _valueNotifier = IgnorableValueNotifier(
          PhotoViewControllerValue(
            position: initialPosition,
            rotation: initialRotation,
            scale: initialScale,
            rotationFocusPoint: null,
          ),
        ),
        super() {
    initial = value;
    prevValue = initial;

    _valueNotifier.addListener(_changeListener);
    _outputCtrl = StreamController<PhotoViewControllerValue>.broadcast();
    _outputCtrl.sink.add(initial);
  }

  final IgnorableValueNotifier<PhotoViewControllerValue> _valueNotifier;

  late PhotoViewControllerValue initial;

  late StreamController<PhotoViewControllerValue> _outputCtrl;

  PhotoViewAnimationDelegate? _delegate;

  /// Queue for commands triggered before the controller is attached
  final List<_ControllerCommand> _pendingCommands = [];

  @override
  Stream<PhotoViewControllerValue> get outputStateStream => _outputCtrl.stream;

  @override
  late PhotoViewControllerValue prevValue;

  @override
  void reset() {
    value = initial;
    _pendingCommands.clear();
  }

  void _changeListener() {
    _outputCtrl.sink.add(value);
  }

  @override
  void addIgnorableListener(VoidCallback callback) {
    _valueNotifier.addIgnorableListener(callback);
  }

  @override
  void removeIgnorableListener(VoidCallback callback) {
    _valueNotifier.removeIgnorableListener(callback);
  }

  @override
  void dispose() {
    _outputCtrl.close();
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
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  @override
  Offset get position => value.position;

  @override
  set scale(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  @override
  double? get scale => value.scale;

  @override
  void setScaleInvisibly(double? scale) {
    if (value.scale == scale) {
      return;
    }
    prevValue = value;
    _valueNotifier.updateIgnoring(
      PhotoViewControllerValue(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint,
      ),
    );
  }

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
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  @override
  double get rotation => value.rotation;

  @override
  set rotationFocusPoint(Offset? rotationFocusPoint) {
    if (value.rotationFocusPoint == rotationFocusPoint) {
      return;
    }
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position,
      scale: scale,
      rotation: rotation,
      rotationFocusPoint: rotationFocusPoint,
    );
  }

  @override
  Offset? get rotationFocusPoint => value.rotationFocusPoint;

  @override
  void updateMultiple({
    Offset? position,
    double? scale,
    double? rotation,
    Offset? rotationFocusPoint,
  }) {
    prevValue = value;
    value = PhotoViewControllerValue(
      position: position ?? value.position,
      scale: scale ?? value.scale,
      rotation: rotation ?? value.rotation,
      rotationFocusPoint: rotationFocusPoint ?? value.rotationFocusPoint,
    );
  }

  @override
  PhotoViewControllerValue get value => _valueNotifier.value;

  @override
  set value(PhotoViewControllerValue newValue) {
    if (_valueNotifier.value == newValue) {
      return;
    }
    _valueNotifier.value = newValue;
  }

  @override
  void attach(PhotoViewAnimationDelegate delegate) {
    _delegate = delegate;
    // Execute any pending commands now that we are attached
    for (final command in _pendingCommands) {
      command.execute(delegate);
    }
    _pendingCommands.clear();
  }

  @override
  void detach() {
    _delegate = null;
  }

  /// Triggers a smooth, physics-based zoom by the given [factor].
  ///
  /// If the controller is not yet attached to a [PhotoView], the command
  /// is queued and executed immediately upon attachment.
  void animateScaleBy({required double factor, Offset? focalPoint}) {
    final delegate = _delegate;
    if (delegate != null) {
      delegate.animateScaleBy(factor: factor, focalPoint: focalPoint);
    } else {
      _pendingCommands.add(_ScaleByCommand(factor, focalPoint));
    }
  }

  /// Triggers a smooth, physics-based pan by the given [delta].
  ///
  /// If the controller is not yet attached to a [PhotoView], the command
  /// is queued and executed immediately upon attachment.
  void animatePositionBy({required Offset delta}) {
    final delegate = _delegate;
    if (delegate != null) {
      delegate.animatePositionBy(delta: delta);
    } else {
      _pendingCommands.add(_PositionByCommand(delta));
    }
  }
}

/// A command object to store pending animation requests
abstract class _ControllerCommand {
  void execute(PhotoViewAnimationDelegate delegate);
}

class _ScaleByCommand implements _ControllerCommand {
  const _ScaleByCommand(this.factor, this.focalPoint);

  final double factor;
  final Offset? focalPoint;

  @override
  void execute(PhotoViewAnimationDelegate delegate) {
    delegate.animateScaleBy(factor: factor, focalPoint: focalPoint);
  }
}

class _PositionByCommand implements _ControllerCommand {
  const _PositionByCommand(this.delta);

  final Offset delta;

  @override
  void execute(PhotoViewAnimationDelegate delegate) {
    delegate.animatePositionBy(delta: delta);
  }
}
