
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_utils.dart';

import '../photo_view.dart';

/// A  class to hold internal layout logics
class PhotoViewControllerDelegate {



  const PhotoViewControllerDelegate({
    this.controller,
    this.scaleBoundaries,
    this.scaleStateCycle,
    this.scaleStateController
  });


  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final ScaleBoundaries scaleBoundaries;
  final ScaleStateCycle scaleStateCycle;


  double get scale {
    return controller.scale ?? getScaleForScaleState(
        scaleStateController.scaleState,
        scaleBoundaries
    );
  }
  set scale(double scale) {
    // Todo: silently update scale to prevent futher reaction in scalestate
    controller.scale = scale;
  }


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
      rotationFocusPoint: rotationFocusPoint
    );
  }

  void animateOnScaleStateUpdate(void listener(double prevScale, double nextScale)){ // todo: put this to listen silently
    if (scaleStateController.prevScaleState !=
        scaleStateController.scaleState &&
        (scaleStateController.scaleState != PhotoViewScaleState.zoomedIn &&
            scaleStateController.scaleState != PhotoViewScaleState.zoomedOut)) {
      final double prevScale = controller.scale ??
          getScaleForScaleState(PhotoViewScaleState.initial, scaleBoundaries);

      final double nextScale = getScaleForScaleState(scaleStateController.scaleState, scaleBoundaries);

      listener(prevScale, nextScale);
    }
  }



  void updateScaleStateFromNewScale(double scaleFactor, double newScale){

    if(scaleFactor == 1.0) return;

    final PhotoViewScaleState newScaleState = (newScale > scaleBoundaries.initialScale)
        ? PhotoViewScaleState.zoomedIn
        : PhotoViewScaleState.zoomedOut;

    scaleStateController.scaleState = newScaleState; // Todo: update it silently
  }

  void checkAndSetToInitialScaleState() {
    if (scaleStateController.scaleState != PhotoViewScaleState.initial &&
        scale == scaleBoundaries.initialScale) {
      scaleStateController.scaleState = PhotoViewScaleState.initial; // Todo: update silently
    }
  }

  void nextScaleState() {
    final PhotoViewScaleState scaleState = scaleStateController.scaleState;
    if (scaleState == PhotoViewScaleState.zoomedIn ||
        scaleState == PhotoViewScaleState.zoomedOut) {
      scaleStateController.scaleState =
          scaleStateCycle(scaleState);
      return;
    }
    final double originalScale =
    getScaleForScaleState(scaleState, scaleBoundaries);

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

  Offset clampPosition(Offset offset, Alignment basePosition, { double scale }) {
    final double _scale = scale ?? this.scale;
    final double x = offset.dx;
    final double y = offset.dy;

    final double computedWidth =
        scaleBoundaries.childSize.width * _scale;
    final double computedHeight = scaleBoundaries.childSize.height * _scale;

    final double screenWidth = scaleBoundaries.outerSize.width;
    final double screenHeight = scaleBoundaries.outerSize.height;

    final double positionX = basePosition.x;
    final double positionY = basePosition.y;

    final double widthDiff = computedWidth - screenWidth;
    final double heightDiff = computedHeight - screenHeight;

    final double minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final double maxX = ((positionX + 1).abs() / 2) * widthDiff;

    final double minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final double maxY = ((positionY + 1).abs() / 2) * heightDiff;

    final double computedX =
    screenWidth < computedWidth ? x.clamp(minX, maxX) : 0.0;

    final double computedY =
    screenHeight < computedHeight ? y.clamp(minY, maxY) : 0.0;

    return Offset(computedX, computedY);
  }
}
