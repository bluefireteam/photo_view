import 'dart:ui';

import 'package:photo_view/src/photo_view_controller.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:test/test.dart';

void main() {
  PhotoViewController controller;
  setUp(() {
    controller = PhotoViewController();
  });

  test('controller constructor', () {
    const double initialRotation = 0.0;
    const Offset initialPosition = Offset(40.0, 40.0);
    controller = PhotoViewController(
        initialRotation: initialRotation, initialPosition: initialPosition);

    const PhotoViewControllerValue testValue = const PhotoViewControllerValue(
        position: initialPosition,
        scale: null,
        rotation: initialRotation,
        rotationFocusPoint: null,
        scaleState: PhotoViewScaleState.initial);

    expect(controller.value, testValue);
  });
  test('controller change values', () {
    controller.scale = 0.1;
    expect(controller.scale, 0.1);

    controller.position = Offset.zero;
    expect(controller.position, Offset.zero);

    controller.rotation = 0.1;
    expect(controller.rotation, 0.1);

    controller.rotationFocusPoint = Offset.zero;
    expect(controller.rotationFocusPoint, Offset.zero);

    controller.scaleState = PhotoViewScaleState.zooming;
    expect(controller.scaleState, PhotoViewScaleState.zooming);

    controller.updateMultiple(
        position: const Offset(1, 1), scaleState: PhotoViewScaleState.initial);
    expect(controller.scale, 0.1);
    expect(controller.position, const Offset(1, 1));
    expect(controller.rotation, 0.1);
    expect(controller.rotationFocusPoint, Offset.zero);
    expect(controller.scaleState, PhotoViewScaleState.initial);
  });
  test('controller reset', () {
    controller.updateMultiple(position: const Offset(1, 1), rotation: 40);
    controller.reset();
    expect(controller.position, Offset.zero);
    expect(controller.rotation, 0.0);
  });
  test('controller stream mutation', () {
    controller = PhotoViewController();

    const PhotoViewControllerValue value1 = const PhotoViewControllerValue(
        position: Offset.zero,
        scale: null,
        rotation: 0.0,
        rotationFocusPoint: null,
        scaleState: PhotoViewScaleState.zooming);

    const PhotoViewControllerValue value2 = const PhotoViewControllerValue(
        position: Offset.zero,
        scale: null,
        rotation: 1.0,
        rotationFocusPoint: null,
        scaleState: PhotoViewScaleState.zooming);

    const PhotoViewControllerValue value3 = const PhotoViewControllerValue(
        position: Offset.zero,
        scale: 3.0,
        rotation: 1.0,
        rotationFocusPoint: null,
        scaleState: PhotoViewScaleState.zooming);

    const PhotoViewControllerValue value4 = const PhotoViewControllerValue(
        position: const Offset(1, 1),
        scale: 3.0,
        rotation: 45.0,
        rotationFocusPoint: null,
        scaleState: PhotoViewScaleState.zooming);

    expect(controller.outputStateStream,
        emitsInOrder([value1, value2, value3, value4]));
    controller.scaleState = PhotoViewScaleState.zooming;
    controller.rotation = 1.0;
    controller.scale = 3.0;

    controller.updateMultiple(position: const Offset(1, 1), rotation: 45.0);
  });
}
