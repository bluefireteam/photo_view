# Flutter Photo View 

[![Build Status - Travis](https://travis-ci.org/renancaraujo/photo_view.svg?branch=master)](https://travis-ci.org/renancaraujo/photo_view) [![Pub](https://img.shields.io/pub/v/photo_view.svg?style=popout)](https://pub.dartlang.org/packages/photo_view) [![Join the chat at https://gitter.im/photo_view/Lobby](https://badges.gitter.im/photo_view/Lobby.svg)](https://gitter.im/photo_view/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A simple zoomable image widget for Flutter

[PhotoView](/lib/photo_view.dart) is useful in full screen exibition cases.

Resolves a image provider and show the result with useful gestures support, such as pinch to zoom and pan.

## Installation

Add `photo_view` as a dependency in your pubspec.yaml file.

Import Photo View:
```dart
import 'package:photo_view/photo_view.dart';
```


## Sample code

Given a `ImageProvider imageProvider` (such as [AssetImage](https://docs.flutter.io/flutter/painting/AssetImage-class.html) or [NetworkImage](https://docs.flutter.io/flutter/painting/NetworkImage-class.html)):

```dart
@override
Widget build(BuildContext context) {
  return new Container(
    child: new PhotoView(
      imageProvider: AssetImage("assets/large-image.jpg"),
      minScale: PhotoViewScaleBoundary.contained * 0.8,
      maxScale: 4.0,
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

For more information about how to use Photo View, check the [API Docs](https://pub.dartlang.org/documentation/photo_view/latest/photo_view/photo_view-library.html)

### Screenshots


| Large image  | Small image | Animated GIF  |
| ------------- | ------------- | ------------- |
| ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen1.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen2.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen3.gif)  |

| Limited scale | Inline | Hero animation |
| ------------- | ------------- | ------------- |
| ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen4.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen5.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen6.gif)  |


## Todo:

- [x] Scale on doubleTap
- [x] Zoom when pinched
- [x] Respect screen and image boundaries
- [x] Center image when zooming out
- [x] Add image zoom limits (`minScale` an `maxScale`)
- [x] Add GIF support
- [ ] Multiple image support (Gallery mode)
- [ ] Rotate gesture rotates image ([Work in progress](https://github.com/renancaraujo/photo_view/pull/4))

Pull requests are welcome 😊.




