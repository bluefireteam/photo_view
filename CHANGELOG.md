# Changelog

## [Unreleased](https://github.com/renancaraujo/photo_view/tree/HEAD)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.9.0...HEAD)

**Implemented enhancements:**

- \[Help\] How can i use single tap to dismiss photo\_view dialog [\#182](https://github.com/renancaraujo/photo_view/issues/182)
- Ability to close PhotoView with pan down gesture [\#172](https://github.com/renancaraujo/photo_view/issues/172)
- Popup photo view [\#167](https://github.com/renancaraujo/photo_view/issues/167)

**Fixed bugs:**

- \[BUG\]PhotoViewGallery Left-right switch is invalid [\#236](https://github.com/renancaraujo/photo_view/issues/236)

**Closed issues:**

- How to create a gallery with images and custom children? [\#226](https://github.com/renancaraujo/photo_view/issues/226)
- Change PhotoView widget background color [\#225](https://github.com/renancaraujo/photo_view/issues/225)
- If you zoom in to a certain point, the picture will suddenly turn black [\#221](https://github.com/renancaraujo/photo_view/issues/221)
- Issue with PageController [\#214](https://github.com/renancaraujo/photo_view/issues/214)
- Caching image with photo\_view [\#203](https://github.com/renancaraujo/photo_view/issues/203)

**Merged pull requests:**

- Updating usage of InheritedWidget due to Flutter SDK v1.12.1  [\#235](https://github.com/renancaraujo/photo_view/pull/235) ([kranfix](https://github.com/kranfix))
- Add loadFailedChild [\#231](https://github.com/renancaraujo/photo_view/pull/231) ([xuelongqy](https://github.com/xuelongqy))
- custom child size \(PhotoViewGalleryPageOptions\) [\#229](https://github.com/renancaraujo/photo_view/pull/229) ([graknol](https://github.com/graknol))
- Add filterQuality property to improve image quality after scale [\#228](https://github.com/renancaraujo/photo_view/pull/228) ([torta](https://github.com/torta))

## [0.9.0](https://github.com/renancaraujo/photo_view/tree/0.9.0) (2019-11-21)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.8.2...0.9.0)

**Implemented enhancements:**

- Make childSize optional on customChild cosntructor. [\#199](https://github.com/renancaraujo/photo_view/issues/199)

**Merged pull requests:**

- Add tightmode, expose gesture detector scope, minor fix corner hit test and add one tap example [\#211](https://github.com/renancaraujo/photo_view/pull/211) ([renancaraujo](https://github.com/renancaraujo))
- Custom child size now is optional. [\#210](https://github.com/renancaraujo/photo_view/pull/210) ([renancaraujo](https://github.com/renancaraujo))

## [0.8.2](https://github.com/renancaraujo/photo_view/tree/0.8.2) (2019-11-19)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.8.1...0.8.2)

**Fixed bugs:**

- \[BUG\] Enter landscape cuts image [\#163](https://github.com/renancaraujo/photo_view/issues/163)
- Zooming in on specific position\(x, y\) in a zoomed image \(moving the screen\). [\#160](https://github.com/renancaraujo/photo_view/issues/160)

**Closed issues:**

- Web file is not included in the example. [\#200](https://github.com/renancaraujo/photo_view/issues/200)

**Merged pull requests:**

- Expose hit test [\#209](https://github.com/renancaraujo/photo_view/pull/209) ([renancaraujo](https://github.com/renancaraujo))
- Clamp position on every scale update [\#208](https://github.com/renancaraujo/photo_view/pull/208) ([renancaraujo](https://github.com/renancaraujo))

## [0.8.1](https://github.com/renancaraujo/photo_view/tree/0.8.1) (2019-11-19)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.8.0...0.8.1)

**Fixed bugs:**

- \[BUG\] Gallery PhotoViewHeroAttributes [\#204](https://github.com/renancaraujo/photo_view/issues/204)
- Because flutter\_kickstart depends on photo\_view \>=0.3.2-fix which requires the Flutter SDK, version solving failed. [\#198](https://github.com/renancaraujo/photo_view/issues/198)

**Closed issues:**

- Error: Not a constant expression.  const AssetImage\(snapshot.data\[index\]\), [\#205](https://github.com/renancaraujo/photo_view/issues/205)
- \[BUG\] PhotoView without fixed size [\#176](https://github.com/renancaraujo/photo_view/issues/176)

**Merged pull requests:**

- Add recalc scale behavior [\#207](https://github.com/renancaraujo/photo_view/pull/207) ([renancaraujo](https://github.com/renancaraujo))
- Add file for run on the web in example directory [\#201](https://github.com/renancaraujo/photo_view/pull/201) ([YuyaAbo](https://github.com/YuyaAbo))

## [0.8.0](https://github.com/renancaraujo/photo_view/tree/0.8.0) (2019-11-06)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.7.0...0.8.0)

**Fixed bugs:**

- How do i make background as Transparent/White color [\#196](https://github.com/renancaraujo/photo_view/issues/196)

**Merged pull requests:**

- Custom gesture detector [\#197](https://github.com/renancaraujo/photo_view/pull/197) ([renancaraujo](https://github.com/renancaraujo))

## [0.7.0](https://github.com/renancaraujo/photo_view/tree/0.7.0) (2019-10-27)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.6.0...0.7.0)

**Fixed bugs:**

- \[BUG\]\[Hero Animation\]Detail view displays not smoothly when working with NetworkImage [\#191](https://github.com/renancaraujo/photo_view/issues/191)

**Closed issues:**

- Request a new release version [\#194](https://github.com/renancaraujo/photo_view/issues/194)
- \[BUG\]Unable to load asset: [\#193](https://github.com/renancaraujo/photo_view/issues/193)

**Merged pull requests:**

- Let user scroll to next page when PageView child is zooming \(\#41\) [\#185](https://github.com/renancaraujo/photo_view/pull/185) ([criswonder](https://github.com/criswonder))

## [0.6.0](https://github.com/renancaraujo/photo_view/tree/0.6.0) (2019-10-16)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.5.0...0.6.0)

**Fixed bugs:**

- \[BUG\] Gallery example display issue when back from detail view to list view [\#190](https://github.com/renancaraujo/photo_view/issues/190)
- \[BUG\]PhotoViewGallery.builder, the initialPage attribute of PageController is invalid [\#186](https://github.com/renancaraujo/photo_view/issues/186)
- \[BUG\] heroAttributes not showing  [\#184](https://github.com/renancaraujo/photo_view/issues/184)
- What's wrong with the anchor point of photo\_view? [\#174](https://github.com/renancaraujo/photo_view/issues/174)

**Closed issues:**

- How do I disable Zoomable feature and set fit parameter [\#187](https://github.com/renancaraujo/photo_view/issues/187)
- When sliding the PageView, the image flashes [\#181](https://github.com/renancaraujo/photo_view/issues/181)
- \[BUG\]Gallery Example thumbnail disappear when switch PhotoViewGallery pop back [\#178](https://github.com/renancaraujo/photo_view/issues/178)

**Merged pull requests:**

- Update deps, fix typos, fix issues [\#189](https://github.com/renancaraujo/photo_view/pull/189) ([renancaraujo](https://github.com/renancaraujo))
- Correct overriding gesture handlers [\#188](https://github.com/renancaraujo/photo_view/pull/188) ([jibbers42](https://github.com/jibbers42))

## [0.5.0](https://github.com/renancaraujo/photo_view/tree/0.5.0) (2019-09-07)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.4.2...0.5.0)

**Fixed bugs:**

- Text in image can't read properly  [\#166](https://github.com/renancaraujo/photo_view/issues/166)

**Closed issues:**

-  When will you update the version? [\#179](https://github.com/renancaraujo/photo_view/issues/179)
- Hero's `createRectTween` [\#175](https://github.com/renancaraujo/photo_view/issues/175)
- 12/5000   Want to consider perfecting these functions [\#173](https://github.com/renancaraujo/photo_view/issues/173)
- Exit gallery gesture [\#170](https://github.com/renancaraujo/photo_view/issues/170)
- High resolution image zoom result in black screen \[BUG\] [\#162](https://github.com/renancaraujo/photo_view/issues/162)

**Merged pull requests:**

- Fix memory leaks and anti patterns [\#180](https://github.com/renancaraujo/photo_view/pull/180) ([renancaraujo](https://github.com/renancaraujo))
- Implement `HeroProperties` [\#177](https://github.com/renancaraujo/photo_view/pull/177) ([hugocbpassos](https://github.com/hugocbpassos))
- add scaleStateCycle parameter in PhotoViewGalleryPageOptions [\#165](https://github.com/renancaraujo/photo_view/pull/165) ([tmulin](https://github.com/tmulin))
- Fix comment's spelling [\#164](https://github.com/renancaraujo/photo_view/pull/164) ([mf16](https://github.com/mf16))

## [0.4.2](https://github.com/renancaraujo/photo_view/tree/0.4.2) (2019-07-23)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.4.1...0.4.2)

**Implemented enhancements:**

- Tap callbacks in PhotoViewGalleryPageOptions [\#146](https://github.com/renancaraujo/photo_view/issues/146)

**Fixed bugs:**

- scaleStateController of PhotoViewGalleryPageOptions doesn't work [\#150](https://github.com/renancaraujo/photo_view/issues/150)

## [0.4.1](https://github.com/renancaraujo/photo_view/tree/0.4.1) (2019-07-11)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.4.0...0.4.1)

**Fixed bugs:**

- \[BUG\] API Docs not found [\#157](https://github.com/renancaraujo/photo_view/issues/157)
- \[BUG\] can't find photo\_view in pub.dev [\#151](https://github.com/renancaraujo/photo_view/issues/151)
- The argument type 'Null Function\(ImageInfo, bool\)' can't be assigned to the parameter type 'ImageStreamListener' [\#144](https://github.com/renancaraujo/photo_view/issues/144)
- \[BUG\] Exception when resize image by double tap [\#142](https://github.com/renancaraujo/photo_view/issues/142)

**Closed issues:**

- Saving zoomed image? [\#156](https://github.com/renancaraujo/photo_view/issues/156)
- AndroidX support? [\#152](https://github.com/renancaraujo/photo_view/issues/152)

**Merged pull requests:**

- Travis compat [\#161](https://github.com/renancaraujo/photo_view/pull/161) ([renancaraujo](https://github.com/renancaraujo))
- Add the PageView reverse parameter [\#159](https://github.com/renancaraujo/photo_view/pull/159) ([nvbln](https://github.com/nvbln))

## [0.4.0](https://github.com/renancaraujo/photo_view/tree/0.4.0) (2019-05-25)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.3.3...0.4.0)

**Fixed bugs:**

- Small pictures are displayed in their original size instead of enlarged size [\#141](https://github.com/renancaraujo/photo_view/issues/141)

**Merged pull requests:**

- Travis [\#149](https://github.com/renancaraujo/photo_view/pull/149) ([renancaraujo](https://github.com/renancaraujo))
- Fix for Flutter 1.6.3 [\#147](https://github.com/renancaraujo/photo_view/pull/147) ([AlexVegner](https://github.com/AlexVegner))
- Fixes for compatibility with the latest Flutter master branch [\#143](https://github.com/renancaraujo/photo_view/pull/143) ([robinbonnes](https://github.com/robinbonnes))

## [0.3.3](https://github.com/renancaraujo/photo_view/tree/0.3.3) (2019-05-08)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.3.2...0.3.3)

## [0.3.2](https://github.com/renancaraujo/photo_view/tree/0.3.2) (2019-05-08)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.3.1...0.3.2)

**Fixed bugs:**

- Error: The argument type 'String' can't be assigned to the parameter type 'DiagnosticsNode'. [\#135](https://github.com/renancaraujo/photo_view/issues/135)
- onTapUp onTapDown overriding higher onTap handler [\#134](https://github.com/renancaraujo/photo_view/issues/134)
- \[BUG\] Hero-animation doesn't play for network imagae at the first time since hot restart [\#128](https://github.com/renancaraujo/photo_view/issues/128)

**Merged pull requests:**

- ontapup & ontapdown [\#139](https://github.com/renancaraujo/photo_view/pull/139) ([renancaraujo](https://github.com/renancaraujo))
- travis fix attempt [\#138](https://github.com/renancaraujo/photo_view/pull/138) ([renancaraujo](https://github.com/renancaraujo))
- Flutter error compat [\#137](https://github.com/renancaraujo/photo_view/pull/137) ([renancaraujo](https://github.com/renancaraujo))
- Fix FlutterError breaking changes [\#136](https://github.com/renancaraujo/photo_view/pull/136) ([yashshah7197](https://github.com/yashshah7197))

## [0.3.1](https://github.com/renancaraujo/photo_view/tree/0.3.1) (2019-04-23)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.3.0...0.3.1)

**Implemented enhancements:**

- PhotoViewGallery with non PhotoView widget child [\#126](https://github.com/renancaraujo/photo_view/issues/126)

**Merged pull requests:**

- Gallery custom child [\#131](https://github.com/renancaraujo/photo_view/pull/131) ([renancaraujo](https://github.com/renancaraujo))

## [0.3.0](https://github.com/renancaraujo/photo_view/tree/0.3.0) (2019-04-21)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.2.5...0.3.0)

**Fixed bugs:**

- Controller API allow internal malfunction [\#127](https://github.com/renancaraujo/photo_view/issues/127)

**Merged pull requests:**

- Readme and docs [\#130](https://github.com/renancaraujo/photo_view/pull/130) ([renancaraujo](https://github.com/renancaraujo))
- Scalestate controller [\#129](https://github.com/renancaraujo/photo_view/pull/129) ([renancaraujo](https://github.com/renancaraujo))

## [0.2.5](https://github.com/renancaraujo/photo_view/tree/0.2.5) (2019-04-20)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.2.4...0.2.5)

**Fixed bugs:**

- \[BUG\]in afterFirstLayout context.size is zero in release mode [\#117](https://github.com/renancaraujo/photo_view/issues/117)

**Closed issues:**

- Add Edge Bounds [\#125](https://github.com/renancaraujo/photo_view/issues/125)

**Merged pull requests:**

- UNLOCK image if image is zoomedOut [\#124](https://github.com/renancaraujo/photo_view/pull/124) ([Carlit0](https://github.com/Carlit0))
- Added onTapUp & onTapDown callbacks [\#122](https://github.com/renancaraujo/photo_view/pull/122) ([SergeShkurko](https://github.com/SergeShkurko))

## [0.2.4](https://github.com/renancaraujo/photo_view/tree/0.2.4) (2019-04-09)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.2.3...0.2.4)

**Merged pull requests:**

- Travis update [\#121](https://github.com/renancaraujo/photo_view/pull/121) ([renancaraujo](https://github.com/renancaraujo))
- Listener fix [\#120](https://github.com/renancaraujo/photo_view/pull/120) ([renancaraujo](https://github.com/renancaraujo))

## [0.2.3](https://github.com/renancaraujo/photo_view/tree/0.2.3) (2019-04-08)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.2.2...0.2.3)

**Merged pull requests:**

- gallery builder [\#119](https://github.com/renancaraujo/photo_view/pull/119) ([renancaraujo](https://github.com/renancaraujo))

## [0.2.2](https://github.com/renancaraujo/photo_view/tree/0.2.2) (2019-03-12)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.2.1...0.2.2)

## [0.2.1](https://github.com/renancaraujo/photo_view/tree/0.2.1) (2019-02-20)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.2.0...0.2.1)

## [0.2.0](https://github.com/renancaraujo/photo_view/tree/0.2.0) (2019-02-13)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.1.3...0.2.0)

## [0.1.3](https://github.com/renancaraujo/photo_view/tree/0.1.3) (2019-01-14)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.1.2...0.1.3)

## [0.1.2](https://github.com/renancaraujo/photo_view/tree/0.1.2) (2019-01-04)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/renancaraujo/photo_view/tree/0.1.1) (2018-12-28)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/renancaraujo/photo_view/tree/0.1.0) (2018-11-27)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.0.11...0.1.0)

## [0.0.11](https://github.com/renancaraujo/photo_view/tree/0.0.11) (2018-11-18)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.0.10...0.0.11)

## [0.0.10](https://github.com/renancaraujo/photo_view/tree/0.0.10) (2018-10-08)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.0.9...0.0.10)

## [0.0.9](https://github.com/renancaraujo/photo_view/tree/0.0.9) (2018-10-06)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.0.8...0.0.9)

## [0.0.8](https://github.com/renancaraujo/photo_view/tree/0.0.8) (2018-09-14)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/0.0.6...0.0.8)

## [0.0.6](https://github.com/renancaraujo/photo_view/tree/0.0.6) (2018-08-18)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/v0.0.5...0.0.6)

## [v0.0.5](https://github.com/renancaraujo/photo_view/tree/v0.0.5) (2018-08-13)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/v0.0.4...v0.0.5)

## [v0.0.4](https://github.com/renancaraujo/photo_view/tree/v0.0.4) (2018-08-04)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/v0.0.3...v0.0.4)

## [v0.0.3](https://github.com/renancaraujo/photo_view/tree/v0.0.3) (2018-07-18)

[Full Changelog](https://github.com/renancaraujo/photo_view/compare/3af3c8264c9818f17b722d2473945a1d3ccaaac6...v0.0.3)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
