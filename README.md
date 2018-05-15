# photo_view [![Build Status - Travis](https://travis-ci.org/renancaraujo/photo_view.svg?branch=master)](https://travis-ci.org/renancaraujo/photo_view)
A simple zoomable image widget for Flutter projects

[PhotoView](/lib/photo_view.dart) is useful in full screen exibition cases.

Resolves a image provider and show the result with useful gestures support, such as pinch to zoom and pan.

#### Todo:
- [x] Scale on doubleTap
- [x] Zoom when pinched
- [x] Respect screen and image boundaries
- [ ] Multiple image support
- [ ] Rotate gesture rotates image

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

![In action](https://github.com/renancaraujo/photo_view/blob/master/screen.gif)

### Constructor

[PhotoView](/lib/photo_view.dart)({ [ImageProvider](https://docs.flutter.io/flutter/painting/ImageProvider-class.html) imageProvider, [Widget](https://docs.flutter.io/flutter/widgets/Widget-class.html) loadingChild })


Creates a widget that resolves and shows a image with zoom and pan gestures support. If provided, the widget shows `loadingChild` while the image is being resolved.



