# Flutter Photo View 

[![Build Status - Travis](https://travis-ci.org/renancaraujo/photo_view.svg?branch=master)](https://travis-ci.org/renancaraujo/photo_view) [![Pub](https://img.shields.io/pub/v/photo_view.svg?style=popout)](https://pub.dartlang.org/packages/photo_view) [![Join the chat at https://gitter.im/photo_view/Lobby](https://badges.gitter.im/photo_view/Lobby.svg)](https://gitter.im/photo_view/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A simple zoomable image widget for Flutter

[PhotoView](/lib/photo_view.dart) is useful in full screen exibition cases.

Resolves a image provider and shows the result with useful gestures support, such as pinch to zoom and pan.

## Installation

Add `photo_view` as a dependency in your pubspec.yaml file ([what?](https://flutter.io/using-packages/)).

Import Photo View:
```dart
import 'package:photo_view/photo_view.dart';
```

## Docs & API

For more information about how to use Photo View, check the [API Docs](https://pub.dartlang.org/documentation/photo_view/latest/photo_view/photo_view-library.html)


If you want to see it in practice, check the [example app](/example/lib) that explores most of Photo View's use cases.

## Full screen usage

Given a `ImageProvider imageProvider` (such as [AssetImage](https://docs.flutter.io/flutter/painting/AssetImage-class.html) or [NetworkImage](https://docs.flutter.io/flutter/painting/NetworkImage-class.html)):

```dart
@override
Widget build(BuildContext context) {
  return Container(
    child: PhotoView(
      imageProvider: AssetImage("assets/large-image.jpg"),
    );
  );
}
```

Result: 

![In action](https://github.com/renancaraujo/photo_view/blob/master/screen1.gif)

## Inline Usage

If you want `PhotoView` to scale the image in container with size different than the screen, use `PhotoViewInline` instead.

```dart
@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20.0),
    height: 300.0,
    child: PhotoViewInline(
      imageProvider: AssetImage("assets/large-image.jpg"),
    );
  );
}
```

Result: 

![In action](https://github.com/renancaraujo/photo_view/blob/master/screen5.gif)

## Gallery

To show several images and let user change between them, use `PhotoViewGallery`.

```dart
@override
Widget build(BuildContext context) {
  return Container(
    child: PhotoViewGallery(
      pageOptions: <PhotoViewGalleryPageOptions>[
        PhotoViewGalleryPageOptions(
          imageProvider: AssetImage("assets/gallery1.jpeg"),
          heroTag: "tag1",
        ),
        PhotoViewGalleryPageOptions(
          imageProvider: AssetImage("assets/gallery2.jpeg"),
          heroTag: "tag2",
          maxScale: PhotoViewComputedScale.contained * 0.3
        ),
        PhotoViewGalleryPageOptions(
          imageProvider: AssetImage("assets/gallery3.jpeg"),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.1,
          heroTag: "tag3",
        ),
      ],
      backgroundColor: Colors.black87,
    );
  );
}
```

Result (with a simple HUD): 

![In action](https://user-images.githubusercontent.com/6718144/46573612-2e967d00-c96e-11e8-9b9f-a70d5a62861d.gif)



### More screenshots


| Small image | Animated GIF  | Limited scale | Hero animation |
| ------------- | ------------- | ------------- | ------------- |
| ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen2.gif) | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen3.gif) | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen4.gif) | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen6.gif) |


## Todo:

- [x] Scale on doubleTap
- [x] Zoom when pinched
- [x] Respect screen and image boundaries
- [x] Center image when zooming out
- [x] Add image zoom limits (`minScale` an `maxScale`)
- [x] Add GIF support
- [x] Multiple image support (Gallery mode)
- [ ] Rotate gesture rotates image ([Work in progress](https://github.com/renancaraujo/photo_view/pull/36))

Pull requests are welcome 😊.




