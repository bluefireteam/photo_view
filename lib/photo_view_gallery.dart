library photo_view_gallery;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_controller.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

/// A type definition for a [Function] that receives a index after a page change in [PhotoViewGallery]
///
typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

/// A [StatefulWidget] that shows multiple [PhotoView] widgets in a [PageView]
///
/// Some of [PhotoView] consturctor options are passed direct to [PhotoViewGallery] cosntructor. Those options will affect the gallery in a whole.
///
/// Some of the options may be defined to each image individually, such as `initialScale` or `heroTag`. Those can be assed through a [List] of [PhotoViewGalleryPageOptions].
///
/// Example of usage:
/// ```
/// PhotoViewGallery(
///   pageOptions: <PhotoViewGalleryPageOptions>[
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery1.jpeg"),
///       heroTag: "tag1",
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery2.jpeg"),
///       heroTag: "tag2",
///       maxScale: PhotoViewComputedScale.contained * 0.3
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery3.jpeg"),
///       minScale: PhotoViewComputedScale.contained * 0.8,
///       maxScale: PhotoViewComputedScale.covered * 1.1,
///       heroTag: "tag3",
///     ),
///   ],
///   loadingChild: widget.loadingChild,
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
///
class PhotoViewGallery extends StatefulWidget {
  const PhotoViewGallery({
    Key key,
    @required this.pageOptions,
    this.loadingChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.customSize,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.transitionOnUserGestures = false,
  }) : super(key: key);

  /// A list of options to describe the items in the gallery
  final List<PhotoViewGalleryPageOptions> pageOptions;

  /// Mirror to [PhotoView.loadingChild]
  final Widget loadingChild;

  /// Mirror to [PhotoView.backgroundDecoration]
  final Decoration backgroundDecoration;

  /// Mirror to [PhotoView.gaplessPlayback]
  final bool gaplessPlayback;

  /// An object that controls the [PageView] inside [PhotoViewGallery]
  final PageController pageController;

  /// An callback to be called on a page change
  final PhotoViewGalleryPageChangedCallback onPageChanged;

  /// Mirror to [PhotoView.scaleStateChangedCallback]
  final PhotoViewScaleStateChangedCallback scaleStateChangedCallback;

  /// Mirror to [PhotoView.customSize]
  final Size customSize;

  /// Mirror to [PhotoView.enableRotation]
  final bool enableRotation;

  /// Mirror to [PhotoView.transitionOnUserGestures]
  final bool transitionOnUserGestures;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewGalleryState();
  }
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> {
  PageController _controller;
  bool _locked;

  @override
  void initState() {
    _controller = widget.pageController ?? PageController();
    _locked = false;
    super.initState();
  }

  void scaleStateChangedCallback(PhotoViewScaleState scaleState) {
    setState(() {
      _locked = scaleState != PhotoViewScaleState.initial;
    });
    widget.scaleStateChangedCallback != null
        ? widget.scaleStateChangedCallback(scaleState)
        : null;
  }

  int get actualPage {
    return _controller.hasClients ? _controller.page.floor() : 0;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: widget.onPageChanged,
      itemCount: widget.pageOptions.length,
      itemBuilder: _buildItem,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
    );
  }

  Widget _buildItem(context, int index) {
    final pageOption = widget.pageOptions[index];
    return PhotoView(
      key: ObjectKey(index),
      imageProvider: pageOption.imageProvider,
      loadingChild: widget.loadingChild,
      backgroundDecoration: widget.backgroundDecoration,
      controller: pageOption.controller,
      gaplessPlayback: widget.gaplessPlayback,
      customSize: widget.customSize,
      heroTag: pageOption.heroTag,
      scaleStateChangedCallback: scaleStateChangedCallback,
      enableRotation: widget.enableRotation,
      transitionOnUserGestures: widget.transitionOnUserGestures,
    );
  }
}

/// A helper class that wraps individual options of a item in [PhotoViewGallery]
///
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
class PhotoViewGalleryPageOptions {
  PhotoViewGalleryPageOptions(
      {Key key,
      @required this.imageProvider,
      this.heroTag,
      this.minScale,
      this.maxScale,
      this.initialScale,
      this.controller});

  /// Mirror to [PhotoView.imageProvider]
  final ImageProvider imageProvider;

  /// Mirror to [PhotoView.heroTag
  final Object heroTag;

  /// Mirror to [PhotoView.minScale]
  final dynamic minScale;

  /// Mirror to [PhotoView.maxScale]
  final dynamic maxScale;

  /// Mirror to [PhotoView.initialScale]
  final dynamic initialScale;

  /// Mirror to [PhotoView.controller]
  final PhotoViewController controller;
}
