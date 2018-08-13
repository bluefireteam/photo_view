# Flutter Photo View [![Build Status - Travis](https://travis-ci.org/renancaraujo/photo_view.svg?branch=master)](https://travis-ci.org/renancaraujo/photo_view)

[![Pub](https://img.shields.io/pub/v/photo_view.svg?style=popout)](https://pub.dartlang.org/packages/photo_view)

A simple zoomable image widget for Flutter

[PhotoView](/lib/photo_view.dart) is useful in full screen exibition cases.

Resolves a image provider and show the result with useful gestures support, such as pinch to zoom and pan.

## Installation

Add `photo_view` as a dependency in your pubspec.yaml file.

#### Todo:
- [x] Scale on doubleTap
- [x] Zoom when pinched
- [x] Respect screen and image boundaries
- [x] Center image when zooming out
- [x] Add image zoom limits (`minScale` an `maxScale`)
- [x] Add GIF support
- [ ] Multiple image support (Gallery mode)
- [ ] Rotate gesture rotates image ([Work in progress](https://github.com/renancaraujo/photo_view/pull/4))

Pull requests are welcome 😊.

## Sample code

Given a `ImageProvider imageProvider` (such as [AssetImage](https://docs.flutter.io/flutter/painting/AssetImage-class.html) or [NetworkImage](https://docs.flutter.io/flutter/painting/NetworkImage-class.html)):

```dart
@override
Widget build(BuildContext context) {
  return new Container(
    child: new PhotoView(
      imageProvider: imageProvider
    );
  );
}
```

## Inline Usage

If you want `PhotoView` to scale the image in container with size different than the screen, use `PhotoViewInline` instead.

```dart
@override
Widget build(BuildContext context) {
  return new Container(
    child: new PhotoViewInline(
      imageProvider: AssetImage("assets/large-image.jpg"),
      minScale: PhotoViewScaleBoundary.contained * 0.8,
      maxScale: 4.0,
    );
  );
}
```

### API

For more information about how to use Photo View, check the [API Docs](/API.md)

### Screenshots


| Large image  | Small image |
| ------------- | ------------- |
| ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen1.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen2.gif)  |

| Animated GIF  | Limited scale |
| ------------- | ------------- |
| ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen3.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen4.gif)  |





