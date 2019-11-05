import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/core/photo_view_image_core.dart';
import 'package:photo_view/src/utils/photo_view_utils.dart';

/// A  class to hold internal layout logic to sync both controller states
mixin PhotoViewControllerDelegate on State<PhotoViewCore> implements HitCornersDetector {
  PhotoViewControllerBase get controller => widget.controller;

  PhotoViewScaleStateController get scaleStateController =>
      widget.scaleStateController;

  ScaleBoundaries get scaleBoundaries => widget.scaleBoundaries;

  ScaleStateCycle get scaleStateCycle => widget.scaleStateCycle;

  Alignment get basePosition => widget.basePosition;
  Function(double prevScale, double nextScale) _animateScale;

  void startListeners() {
    controller.addIgnorableListener(_blindScaleListener);
    scaleStateController.addIgnorableListener(_blindScaleStateListener);
  }

  void _blindScaleStateListener() {
    if (!scaleStateController.hasChanged) {
      return;
    }
    if (_animateScale == null || scaleStateController.isZooming) {
      controller.setScaleInvisibly(scale);
      return;
    }
    final double prevScale = controller.scale ??
        getScaleForScaleState(
          scaleStateController.prevScaleState,
          scaleBoundaries,
        );

    final double nextScale = getScaleForScaleState(
      scaleStateController.scaleState,
      scaleBoundaries,
    );

    _animateScale(prevScale, nextScale);
  }

  void addAnimateOnScaleStateUpdate(
      void animateScale(double prevScale, double nextScale)) {
    _animateScale = animateScale;
  }

  void _blindScaleListener() {
    if (controller.scale == controller.prevValue.scale) {
      return;
    }
    final PhotoViewScaleState newScaleState =
        (scale > scaleBoundaries.initialScale)
            ? PhotoViewScaleState.zoomedIn
            : PhotoViewScaleState.zoomedOut;

    scaleStateController.setInvisibly(newScaleState);
    controller.position = clampPosition();
  }

  Offset get position => controller.position;

  double get scale =>
      controller.scale ??
      getScaleForScaleState(
        scaleStateController.scaleState,
        scaleBoundaries,
      );

  set scale(double scale) => controller.setScaleInvisibly(scale);

  void updateMultiple({
    Offset position,
    double scale,
    double rotation,
    Offset rotationFocusPoint,
  }) {
    controller.updateMultiple(
        position: position,
        scale: scale,
        rotation: rotation,
        rotationFocusPoint: rotationFocusPoint);
  }

  void updateScaleStateFromNewScale(double newScale) {

    final PhotoViewScaleState newScaleState =
        (newScale > scaleBoundaries.initialScale)
            ? PhotoViewScaleState.zoomedIn
            : PhotoViewScaleState.zoomedOut;

    scaleStateController.setInvisibly(newScaleState);
  }

  void checkAndSetToInitialScaleState() {
    if (scaleStateController.scaleState != PhotoViewScaleState.initial &&
        scale == scaleBoundaries.initialScale) {
      scaleStateController.setInvisibly(PhotoViewScaleState.initial);
    }
  }

  void nextScaleState() {
    final PhotoViewScaleState scaleState = scaleStateController.scaleState;
    if (scaleState == PhotoViewScaleState.zoomedIn ||
        scaleState == PhotoViewScaleState.zoomedOut) {
      scaleStateController.scaleState = scaleStateCycle(scaleState);
      return;
    }
    final double originalScale = getScaleForScaleState(
      scaleState,
      scaleBoundaries,
    );

    double prevScale = originalScale;
    PhotoViewScaleState prevScaleState = scaleState;
    double nextScale = originalScale;
    PhotoViewScaleState nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = scaleStateCycle(prevScaleState);
      nextScale = getScaleForScaleState(nextScaleState, scaleBoundaries);
    } while (prevScale == nextScale && scaleState != nextScaleState);

    if (originalScale == nextScale) {
      return;
    }
    scaleStateController.scaleState = nextScaleState;
  }

  CornersRange _cornersX({double scale}) {
    final double _scale = scale ?? this.scale;

    final double computedWidth = scaleBoundaries.childSize.width * _scale;
    final double screenWidth = scaleBoundaries.outerSize.width;

    final double positionX = basePosition.x;
    final double widthDiff = computedWidth - screenWidth;

    final double minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final double maxX = ((positionX + 1).abs() / 2) * widthDiff;
    return CornersRange(minX, maxX);
  }

  CornersRange _cornersY({double scale}) {
    final double _scale = scale ?? this.scale;

    final double computedHeight = scaleBoundaries.childSize.height * _scale;
    final double screenHeight = scaleBoundaries.outerSize.height;

    final double positionY = basePosition.y;
    final double heightDiff = computedHeight - screenHeight;

    final double minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final double maxY = ((positionY + 1).abs() / 2) * heightDiff;
    return CornersRange(minY, maxY);
  }

  Offset clampPosition({Offset position, double scale}) {
    final double _scale = scale ?? this.scale;
    final Offset _position = position ?? this.position;

    final double computedWidth = scaleBoundaries.childSize.width * _scale;
    final double computedHeight = scaleBoundaries.childSize.height * _scale;

    final double screenWidth = scaleBoundaries.outerSize.width;
    final double screenHeight = scaleBoundaries.outerSize.height;

    double finalX = 0.0;
    if (screenWidth < computedWidth) {
      final cornersX = _cornersX(scale: _scale);
      finalX = _position.dx.clamp(cornersX.min, cornersX.max);
    }

    double finalY = 0.0;
    if (screenHeight < computedHeight) {
      final cornersY = _cornersY(scale: _scale);
      finalY = _position.dy.clamp(cornersY.min, cornersY.max);
    }

    return Offset(finalX, finalY);
  }

  @override
  HitCorners get hasHitCorners => HitCorners(hasHitCornersX, hasHitCornersY);

  @override
  AxisHitCorners get hasHitCornersX {
    final double childWidth = scaleBoundaries.childSize.width * scale;
    final double screenWidth = scaleBoundaries.outerSize.width;
    if (screenWidth >= childWidth) {
      return const AxisHitCorners(true, true);
    }
    final x = position.dx;
    final cornersX = _cornersX();
    return AxisHitCorners(x <= cornersX.min, x >= cornersX.max);
  }

  @override
  AxisHitCorners get hasHitCornersY {
    final double childHeight = scaleBoundaries.childSize.height * scale;
    final double screenHeight = scaleBoundaries.outerSize.height;
    if (screenHeight >= childHeight) {
      return const AxisHitCorners(true, true);
    }
    final y = position.dy;
    final cornersY = _cornersY();
    return AxisHitCorners(y <= cornersY.min, y >= cornersY.max);
  }

  @override
  bool shouldMoveX(Offset move) {
    if(!hasHitCorners.hasHitAny || move == Offset.zero) {
      return true;
    }
    if(hasHitCornersX.hasHitAny) {
      if(hasHitCornersX.hasHitMax) {
        return move.dx > 0;
      }
      return move.dx < 0;
    }
    return true;
  }

  @override
  bool shouldMoveY(Offset move) {
    if(!hasHitCorners.hasHitAny || move == Offset.zero) {
      return true;
    }
    if(hasHitCornersY.hasHitAny) {
      if(hasHitCornersY.hasHitMax) {
        return move.dy > 0;
      }
      return move.dy < 0;
    }
    return true;
  }

  @override
  void dispose() {
    _animateScale = null;
    controller.removeIgnorableListener(_blindScaleListener);
    scaleStateController.removeIgnorableListener(_blindScaleStateListener);
    super.dispose();
  }
}

abstract class HitCornersDetector {
  HitCorners get hasHitCorners;
  AxisHitCorners get hasHitCornersX;
  AxisHitCorners get hasHitCornersY;
  bool shouldMoveX(Offset move);
  bool shouldMoveY(Offset move);
}
class HitCorners {
  HitCorners(this.hasHitX, this.hasHitY);

  final AxisHitCorners hasHitX;
  final AxisHitCorners hasHitY;

  bool get hasHitAny => hasHitX.hasHitAny || hasHitY.hasHitAny;
}
class AxisHitCorners {
  const AxisHitCorners(this.hasHitMin, this.hasHitMax);
  final bool hasHitMin;
  final bool hasHitMax;
  bool get hasHitAny => hasHitMin || hasHitMax;
}


class CornersRange {
  const CornersRange(this.min, this.max);
  final double min;
  final double max;
}
