# Flutter Photo View [![Build Status - Travis](https://travis-ci.org/renancaraujo/photo_view.svg?branch=master)](https://travis-ci.org/renancaraujo/photo_view)
A simple zoomable image widget for Flutter

[PhotoView](/lib/photo_view.dart) is useful in full screen exibition cases.

Resolves a image provider and show the result with useful gestures support, such as pinch to zoom and pan.

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

| Simple Image  | GIF |
| ------------- | ------------- |
| ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen.gif)  | ![In action](https://github.com/renancaraujo/photo_view/blob/master/screen_gif.gif)  |


### API

For more information about how to use Photo View, check the [API Docs](/API.md)



