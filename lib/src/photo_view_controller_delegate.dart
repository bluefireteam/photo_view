
import 'dart:ui';

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

  Offset get position => controller.position;
  set position(Offset position) {
    controller.position = position;
  }

  double get rotation => controller.rotation;
  set rotation(double rotation) {
    controller.rotation = rotation;
  }

  void updateScaleStateFromNewScale(double newScale){
    final PhotoViewScaleState newScaleState = newScale != 1.0
        ? (newScale > scaleBoundaries.initialScale)
        ? PhotoViewScaleState.zoomedIn
        : PhotoViewScaleState.zoomedOut
        : scaleStateController.scaleState;

    scaleStateController.scaleState = newScaleState; // Todo: update irt silently
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
}
