<a name="0.9.2"></a>
# [0.9.2](https://github.com/renancaraujo/photo_view/releases/tag/0.9.2) - 15 Feb 2020

## Added
- `loadingBuilder` which provides a way to create a progress loader. Thanks to @neckaros #250 #254

## Deprecated
- `loadingChild` options in both `PhotoView` and `PhotoViewGallery` in favor of `loadingBuilder`;

## Fixed
- Gallery undefined issue #251
- PhotoViewCore throws when using PhotoCiewScaleStateController within gallery. #254 #217 
- `basePosition` on `PhotoViewGallery` being ignored #255 #219



[Changes][0.9.2]


<a name="0.9.1"></a>
# [0.9.1](https://github.com/renancaraujo/photo_view/releases/tag/0.9.1) - 07 Jan 2020

## Added
- `filterQuality` option to the property to improve image quality after scale #228 
- `loadFailedChild` option to specify a widget instance to be shown when the image retrieval process failed #231

## Changed
- **Internal:** stop using deprecated `inheritFromWidgetOfExactType` in favor of `dependOnInheritedWidgetOfExactType` #235
- Made childSize optional for PhotoViewGalleryPageOptions.customChild #229 


[Changes][0.9.1]


<a name="0.9.0"></a>
# [0.9.0](https://github.com/renancaraujo/photo_view/releases/tag/0.9.0) - 21 Nov 2019

## Added

- `tightMode` option that allows `PhotoView` to be used inside a dialog. #167 #211
- `PhotoViewGestureDetectorScope` widget that allows `PhotoView` to be used on scrollable contexts (PageView, list view etc) #211 
-  Dialogs and onetap example on the exmaple app #211

## Changed
- Made `childSize` to be optional. Now it expands if no value is provided #210 #199 

[Changes][0.9.0]


<a name="0.8.2"></a>
# [0.8.2](https://github.com/renancaraujo/photo_view/releases/tag/0.8.2) - 19 Nov 2019

## Fixed 
- Clamping position on controller #208 #160 

## Added
- Exposing hit test on gesture detector #209 

[Changes][0.8.2]


<a name="0.8.1"></a>
# [0.8.1](https://github.com/renancaraujo/photo_view/releases/tag/0.8.1) - 19 Nov 2019

## Added
- Web support on the example app, thanks to @YuyaAbo #201 

## Fixed
- ScaleState were not respected when resizing photoview widget. #163 #207 

[Changes][0.8.1]


<a name="0.8.0"></a>
# [0.8.0](https://github.com/renancaraujo/photo_view/releases/tag/0.8.0) - 07 Nov 2019

## Changed
- Change to our own custom gesture detector, making it work nicely with an extenal gesture detector. It solves #41 which was previously tackled on #185 but with some minor bugs (vertical scrolling pageviews and proper responsiveness on pan gestures). #197 
- Renamed `PhotoViewImageWrapper` to `PhotoViewCore` and reorganized src files, not externally relevant. #197 

## Removed
- [BREAKING] Removed unnecessary function typedefs like `PhotoViewScaleStateChangedCallback` #197 
- [BREAKING] Removed `usePageViewWrapper` option from the gallery #197 




[Changes][0.8.0]


<a name="0.7.0"></a>
# [0.7.0](https://github.com/renancaraujo/photo_view/releases/tag/0.7.0) - 05 Nov 2019

### Solving a one year issue

## Added
- Detect image edge behavior #185 #41 

[Changes][0.7.0]


<a name="0.6.0"></a>
# [0.6.0](https://github.com/renancaraujo/photo_view/releases/tag/0.6.0) - 16 Oct 2019

## Fixed
- Tons of typos on docs #189 
- Weird rotation behavior #189 #174 #92 
- Example app deps update #189 
- General code improvs #189 

[Changes][0.6.0]


<a name="0.5.0"></a>
# [0.5.0](https://github.com/renancaraujo/photo_view/releases/tag/0.5.0) - 07 Sep 2019

## Changed
 - [BREAKING] All hero attributes where moved into a new data class: `PhotoViewHeroAttributes`. #175 #177 
 - Some internal changes fixed a severe memory leak involving controllers delegate: #180 

[Changes][0.5.0]


<a name="0.4.2"></a>
# [0.4.2](https://github.com/renancaraujo/photo_view/releases/tag/0.4.2) - 23 Jul 2019

## Fixed
- `onTapUp` and `onTapDown` on `PhotoViewGallery` #146 

[Changes][0.4.2]


<a name="0.4.1"></a>
# [0.4.1](https://github.com/renancaraujo/photo_view/releases/tag/0.4.1) - 11 Jul 2019

First release since halt due to Flutter breaking changes.

With this version, Photo view is stable compatible. It means that every new release must be compatible with the channel master. Breaking changes that are still on master or beta channels will not be included on any new release.
## Added
- The PageView reverse parameter #159 

[Changes][0.4.1]


<a name="0.4.0"></a>
# [0.4.0](https://github.com/renancaraujo/photo_view/releases/tag/0.4.0) - 25 May 2019

 ** Fix Flutter breaking change **

- [BREAKING] This release requires Flutter 1.6.0, which in the date of this release, is not even beta. This is due to several master channel users who complained on a recent breaking change which broke one of the PhotoView core features. #144 #143 #147 https://github.com/flutter/flutter/pull/32936



[Changes][0.4.0]


<a name="0.3.3"></a>
# [0.3.3](https://github.com/renancaraujo/photo_view/releases/tag/0.3.3) - 08 May 2019

## Compatibility fix

- Dowgraded Flutter SDK version to 1.4.7

[Changes][0.3.3]


<a name="0.3.2"></a>
# [0.3.2](https://github.com/renancaraujo/photo_view/releases/tag/0.3.2) - 08 May 2019

## Fixed
- `FlutterError` compatibility with breaking changing breaking for Flutter channel master users. #135 #136 #137 
- `onTapUp` and `onTapDown` overriding higher onTap handle #134 #138 

[Changes][0.3.2]


<a name="0.3.1"></a>
# [0.3.1](https://github.com/renancaraujo/photo_view/releases/tag/0.3.1) - 23 Apr 2019

## Added
- Custom child builder to `PhotoViewGalleryPageOptions` that enables the usage of custom children in the gallery. #126 #131 

[Changes][0.3.1]


<a name="0.3.0"></a>
# [0.3.0](https://github.com/renancaraujo/photo_view/releases/tag/0.3.0) - 21 Apr 2019

## Changed
- [BREAKING] `PhotoViewControllerValue` does not contain `scaleState` value anymore, now you should control that value ona separate controller: `PhotoViewScaleStateController`. That is due to some concerns expressed #127. All details on [controller docs](https://pub.dartlang.org/documentation/photo_view/latest/photo_view/PhotoView-class.html#controllers) #129 #127 

## Added
- `scaleStateController` option to `PhotoView` and `PhotoViewGalleryPageOptions` #129 


[Changes][0.3.0]


<a name="0.2.5"></a>
# [0.2.5](https://github.com/renancaraujo/photo_view/releases/tag/0.2.5) - 20 Apr 2019

## Added
- Two new callbacks `onTapUp` and `onTapDown` #122 
- A exclusive stream for `scaleState` in the controller #124 

## Fixed
- Gallery swipe glitch: do not lock when zooming in #124 #105 
- `herotag` is an Object, not a String anymore #122 

## Removed
- [BREAKING] Scale state `zooming` has been replaced by `zoomingIn` and `zoomingOut` #124 



[Changes][0.2.5]


<a name="0.2.4"></a>
# [0.2.4](https://github.com/renancaraujo/photo_view/releases/tag/0.2.4) - 09 Apr 2019

## Changed
- [BREAKING] `PhotoViewController` no longer extends `ValueNotifier`, instead, it contains one. Method `addListener` is no longer available due to a race condition that creates bugs. #106 

[Changes][0.2.4]


<a name="0.2.3"></a>
# [0.2.3](https://github.com/renancaraujo/photo_view/releases/tag/0.2.3) - 09 Apr 2019

## Added
- New builder constructor for `PhotoViewGallery` #119  #78 #113 

[Changes][0.2.3]


<a name="0.2.2"></a>
# [0.2.2](https://github.com/renancaraujo/photo_view/releases/tag/0.2.2) - 08 Apr 2019

## Fixed:

- Make `initialScale`, `minScale` and `maxScale` option work on `PhotoViewGallery`

[Changes][0.2.2]


<a name="0.2.1"></a>
# [0.2.1](https://github.com/renancaraujo/photo_view/releases/tag/0.2.1) - 08 Apr 2019

## Added:
- `scrollPhisics` option to `PhotoViewGallery`

[Changes][0.2.1]


<a name="0.2.0"></a>
# [0.2.0](https://github.com/renancaraujo/photo_view/releases/tag/0.2.0) - 15 Feb 2019

### Introducing "Controller"

Controller exposes photo views external State, this releases put the proposal stated on #86 into practice. There is a lot of things to do yet, but it is already o possible to use it. 

## Added
- Controller class: As stated on #86, it is a way to update and listen for changes in the internal values of Photoview, such as `scale` and `rotation`.  Interesting classes: #89 #86 #70 #66 #67 
  - [PhotoViewControllerBase](https://pub.dartlang.org/documentation/photo_view/latest/photo_view/PhotoViewControllerBase-class.html)
  - [PhotoViewController](https://pub.dartlang.org/documentation/photo_view/latest/photo_view/PhotoViewController-class.html)
  - [PhotoViewControllerValue](https://pub.dartlang.org/documentation/photo_view/latest/photo_view/PhotoViewControllerValue-class.html)

- `basePosition`: Define an Alignment that will determinate where the content will be placed along the container. #79 

- `scaleStateCycle`: A way to customize double-tap scale change mechanic #69 


[Changes][0.2.0]


<a name="0.1.3"></a>
# [0.1.3](https://github.com/renancaraujo/photo_view/releases/tag/0.1.3) - 14 Jan 2019

Minor bugfix release

# Fixed
- transitionOnUserGestures value not used #81 

[Changes][0.1.3]


<a name="0.1.2"></a>
# [0.1.2](https://github.com/renancaraujo/photo_view/releases/tag/0.1.2) - 14 Jan 2019

Minor bugfixes

# Fixed
- setState() called after dispose() #71 
- transitionOnUserGestures on hero #65 #77 

[Changes][0.1.2]


<a name="0.1.1"></a>
# [0.1.1](https://github.com/renancaraujo/photo_view/releases/tag/0.1.1) - 29 Dec 2018

Minor bug fix

## Removed
- **[BREAKING]** deprecated `PhotoViewInline` is no longer in the codebase, use `PhotoView` instead. #74 

## Fixed
- `PhotoViewScaleState` is stuck in zooming when clamping. Happens when `minScale` or `maxScale` has the same value as `initialScale`. #61 #62 #73 #76 

[Changes][0.1.1]


<a name="0.1.0"></a>
# [0.1.0](https://github.com/renancaraujo/photo_view/releases/tag/0.1.0) - 27 Nov 2018

Release stabilizing usage API.

## Fixed
- Warning when importing photo_view_scale_state #58 
- Blank image when defining `heroTag` #57 #59 

## Deprecated
- **[BREAKING]** `PhotoViewInline` class has been deprecated in favor of `PhotoView` only. #54 #53 

## Changed
- **[BREAKING]**  `size` option has been renamed to `customSize` #54 
- **[BREAKING]**  `backgroundColor` has been removed. Use `backgroundDecoration` instead. #56 

## Removed
- **[BREAKING]**  `PhotoViewGallery` is not exported by `PhotoView` anymore, import `package:photo_view/photo_view_gallery.dart`

## Added
- **Rotation gesture support**:  use the option `enableRotation` to rotate the content as the user rotates the fingers in the pinch gesture. #36 #32

- **Custom child support**:  added the constructor `PhotoView.customChild` which enables the user to show any widget instead of an image. #51 #55 

- `initialScale` option #52 #29 



[Changes][0.1.0]


<a name="0.0.11"></a>
# [0.0.11](https://github.com/renancaraujo/photo_view/releases/tag/0.0.11) - 18 Nov 2018

## Fixed 
- Added `scaleStateChangedCallback` property to `PhotoViewGallery`constructor. #43 

## Added 
- An animation in `onScaleEnd` to make panning gestures more smoothly. #50 #8 
- Initial scale option: customize initial scale with `initialScale` that can be either a double or a `PhotoViewComputedScale` as well. The new option is on in the `PhotoView`, `PhotoViewGalleryPageOptions` and `PhotoViewInline` constructors #29 #52 

[Changes][0.0.11]


<a name="0.0.10"></a>
# [0.0.10](https://github.com/renancaraujo/photo_view/releases/tag/0.0.10) - 08 Oct 2018

## Fixed 
- Error when not specifying `gaplessPlayback` to `PhotoViewInline`s constructor. #38 #39 

[Changes][0.0.10]


<a name="0.0.9"></a>
# [0.0.9](https://github.com/renancaraujo/photo_view/releases/tag/0.0.9) - 06 Oct 2018

## Removed
- **BREAKING:** Support to Dart 1 has been dropped in this version

## Added
- Analyzer option `unnecessary_new`
- `PhotoViewGallery` widget

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



[Changes][0.0.9]


<a name="0.0.8"></a>
# [0.0.8](https://github.com/renancaraujo/photo_view/releases/tag/0.0.8) - 14 Sep 2018

## Changed 
- **BREAKING:** Renamed `PhotoViewScaleBoundary` to `PhotoViewComputedScale` in order to better describe what is the role of this class, that will represent more than boundaries in the future (`initialScale` for instance) #30 

## Fixed 
- Fixed weird behavior when either `maxScale` or `minscale` passed coincided with the computed value for any of the `PhotoViewScaleState` #30 
- Missing `heroTag` param for `PhotoviewInline` #27  #26 

[Changes][0.0.8]


[0.9.2]: https://github.com/renancaraujo/photo_view/compare/0.9.1...0.9.2
[0.9.1]: https://github.com/renancaraujo/photo_view/compare/0.9.0...0.9.1
[0.9.0]: https://github.com/renancaraujo/photo_view/compare/0.8.2...0.9.0
[0.8.2]: https://github.com/renancaraujo/photo_view/compare/0.8.1...0.8.2
[0.8.1]: https://github.com/renancaraujo/photo_view/compare/0.8.0...0.8.1
[0.8.0]: https://github.com/renancaraujo/photo_view/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/renancaraujo/photo_view/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/renancaraujo/photo_view/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/renancaraujo/photo_view/compare/0.4.2...0.5.0
[0.4.2]: https://github.com/renancaraujo/photo_view/compare/0.4.1...0.4.2
[0.4.1]: https://github.com/renancaraujo/photo_view/compare/0.4.0...0.4.1
[0.4.0]: https://github.com/renancaraujo/photo_view/compare/0.3.3...0.4.0
[0.3.3]: https://github.com/renancaraujo/photo_view/compare/0.3.2...0.3.3
[0.3.2]: https://github.com/renancaraujo/photo_view/compare/0.3.1...0.3.2
[0.3.1]: https://github.com/renancaraujo/photo_view/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/renancaraujo/photo_view/compare/0.2.5...0.3.0
[0.2.5]: https://github.com/renancaraujo/photo_view/compare/0.2.4...0.2.5
[0.2.4]: https://github.com/renancaraujo/photo_view/compare/0.2.3...0.2.4
[0.2.3]: https://github.com/renancaraujo/photo_view/compare/0.2.2...0.2.3
[0.2.2]: https://github.com/renancaraujo/photo_view/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/renancaraujo/photo_view/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/renancaraujo/photo_view/compare/0.1.3...0.2.0
[0.1.3]: https://github.com/renancaraujo/photo_view/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/renancaraujo/photo_view/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/renancaraujo/photo_view/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/renancaraujo/photo_view/compare/0.0.11...0.1.0
[0.0.11]: https://github.com/renancaraujo/photo_view/compare/0.0.10...0.0.11
[0.0.10]: https://github.com/renancaraujo/photo_view/compare/0.0.9...0.0.10
[0.0.9]: https://github.com/renancaraujo/photo_view/compare/0.0.8...0.0.9
[0.0.8]: https://github.com/renancaraujo/photo_view/tree/0.0.8

 <!-- Generated by changelog-from-release -->
