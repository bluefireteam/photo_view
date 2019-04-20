import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_view/photo_view.dart';

double getScaleForScaleState(
    PhotoViewScaleState scaleState, ScaleBoundaries scaleBoundaries) {
  switch (scaleState) {
    case PhotoViewScaleState.initial:
    case PhotoViewScaleState.zoomedIn:
    case PhotoViewScaleState.zoomedOut:
      return _clampSize(scaleBoundaries.initialScale, scaleBoundaries);
    case PhotoViewScaleState.covering:
      return _clampSize(
          _scaleForCovering(
              scaleBoundaries.outerSize, scaleBoundaries.childSize),
          scaleBoundaries);
    case PhotoViewScaleState.originalSize:
      return _clampSize(1.0, scaleBoundaries);
    default:
      return null;
  }
}

class ScaleBoundaries {
  const ScaleBoundaries(this._minScale, this._maxScale, this._initialScale,
      this.outerSize, this.childSize);

  final dynamic _minScale;
  final dynamic _maxScale;
  final dynamic _initialScale;
  final Size outerSize;
  final Size childSize;

  double get minScale {
    assert(_minScale is double || _minScale is PhotoViewComputedScale);
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

  double get maxScale {
    assert(_maxScale is double || _maxScale is PhotoViewComputedScale);
    if (_maxScale == PhotoViewComputedScale.contained) {
      return (_scaleForContained(outerSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    if (_maxScale == PhotoViewComputedScale.covered) {
      return (_scaleForCovering(outerSize, childSize) *
              (_maxScale as PhotoViewComputedScale) // ignore: avoid_as
                  .multiplier)
          .clamp(minScale, double.infinity);
    }
    return _maxScale.clamp(minScale, double.infinity);
  }

  double get initialScale {
    assert(_initialScale is double || _initialScale is PhotoViewComputedScale);
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

double _clampSize(double size, ScaleBoundaries scaleBoundaries) {
  return size.clamp(scaleBoundaries.minScale, scaleBoundaries.maxScale);
}


class BlindeableChangeNotifier extends ChangeNotifier{
  ObserverList<VoidCallback> _blindListeners = ObserverList<VoidCallback>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_blindListeners == null) {
        throw FlutterError(
            'A $runtimeType was used after being disposed.\n'
                'Once you have called dispose() on a $runtimeType, it can no longer be used.'
        );
      }
      return true;
    }());
    return true;
  }

  @override
  bool get hasListeners {
    return super.hasListeners || _blindListeners.isNotEmpty;
  }
  
  
  void addBlindListener(listener) {
    assert(_debugAssertNotDisposed());
    _blindListeners.add(listener);
  }
  
  void removeBlindListener(listener) {
    assert(_debugAssertNotDisposed());
    _blindListeners.remove(listener);
  }

  @override
  void dispose() {
    _blindListeners = null;
    super.dispose();
  }

  @protected
  @override
  @visibleForTesting
  void notifyListeners() {
    super.notifyListeners();

    if (_blindListeners != null) {
      final List<VoidCallback> localListeners = List<VoidCallback>.from(_blindListeners);
      for (VoidCallback listener in localListeners) {
        try {
          if (_blindListeners.contains(listener))
            listener();
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'Photoview library',
            context: 'while dispatching notifications for $runtimeType',
            informationCollector: (StringBuffer information) {
              information.writeln('The $runtimeType sending notification was:');
              information.write('  $this');
            },
          ));
        }
      }
    }
  }

  @protected
  void notifySightedListeners() {
    super.notifyListeners();
  }
}

class BlindeableValueNotifier<T> extends BlindeableChangeNotifier implements ValueListenable<T> {
  BlindeableValueNotifier(this._value);

  @override
  T get value => _value;
  T _value;
  set value(T newValue) {
    if (_value == newValue)
      return;
    _value = newValue;
    notifyListeners();
  }
  
  void updateInvisibly(T newValue){
    if (_value == newValue)
      return;
    _value = newValue;
    notifySightedListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}