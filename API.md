# Photo View API reference

## PhotoView class

A [StatefulWidget](https://docs.flutter.io/flutter/widgets/StatefulWidget-class.html) that contains all the photo view rendering elements.

#### Sample code

```dart
new PhotoView(
  imageProvider: imageProvider,
  loadingChild: new LoadingText(),
  backgroundColor: Colors.white,
  minScale: PhotoViewScaleBoundary.contained,
  maxScale: 2.0,
  gaplessPlayback: false
);
```

### Constructor

[PhotoView](/lib/photo_view.dart)({
@required [ImageProvider](https://docs.flutter.io/flutter/painting/ImageProvider-class.html) imageProvider,
[Widget](https://docs.flutter.io/flutter/widgets/Widget-class.html) loadingChild,
[Color](https://docs.flutter.io/flutter/dart-ui/Color-class.html) backgroundColor,
dynamic ([double](https://docs.flutter.io/flutter/dart-core/double-class.html) or [PhotoViewScaleBoundary](/lib/photo_view_scale_boundary.dart)) minScale,
dynamic ([double](https://docs.flutter.io/flutter/dart-core/double-class.html) or [PhotoViewScaleBoundary](/lib/photo_view_scale_boundary.dart)) maxScale, bool gaplessPlayback})

Given a `imageProvider` it resolves into an zoomable image widget using a [FutureBuilder](https://docs.flutter.io/flutter/widgets/FutureBuilder-class.html). In the meantime, PhotoView can show an intermediate view, something like a "loader", passed via `loadingChild`. The zoom scale can be clamped by `minScale` and `maxScale` params. `backgroundColor`, changes the background behind image, defaults to `Colors.black`. The optional parameter `gaplessPlayback` is used to continue showing the old image (`true`), or briefly show nothing (`false`), when the `imageProvider` changes. By default it's set to `false`.
