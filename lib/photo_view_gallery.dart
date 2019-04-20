library photo_view_gallery;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/src/photo_view_controller.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

/// A type definition for a [Function] that receives a index after a page change in [PhotoViewGallery]
///
typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

typedef PhotoViewGalleryBuilder = PhotoViewGalleryPageOptions Function(
    BuildContext context, int index);

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
/// Example of usage with builder pattern:
/// ```
/// PhotoViewGallery.builder(
///   scrollPhysics: const BouncingScrollPhysics(),
///   builder: (BuildContext context, int index) {
///     return PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage(widget.galleryItems[index].image),
///       initialScale: PhotoViewComputedScale.contained * 0.8,
///       minScale: PhotoViewComputedScale.contained * 0.8,
///       maxScale: PhotoViewComputedScale.covered * 1.1,
///       heroTag: galleryItems[index].id,
///     );
///   },
///   itemCount: galleryItems.length,
///   loadingChild: widget.loadingChild,
///   backgroundDecoration: widget.backgroundDecoration,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
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
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
  })  : _isBuilder = false,
        itemCount = null,
        builder = null,
        assert(pageOptions != null),
        super(key: key);

  const PhotoViewGallery.builder({
    Key key,
    @required this.itemCount,
    @required this.builder,
    this.loadingChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.customSize,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.transitionOnUserGestures = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
  })  : _isBuilder = true,
        pageOptions = null,
        assert(itemCount != null),
        assert(builder != null),
        super(key: key);

  /// A list of options to describe the items in the gallery
  final List<PhotoViewGalleryPageOptions> pageOptions;

  /// The count of items in the gallery, only used when constructed via [PhotoViewGallery.builder]
  final int itemCount;

  /// Called to build items for the gallery when using [PhotoViewGallery.builder]
  final PhotoViewGalleryBuilder builder;

  /// [ScrollPhysics] for the internal [PageView]
  final ScrollPhysics scrollPhysics;

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

  /// The axis along which the [PageView] scrolls. Mirror to [PageView.scrollDirection]
  final Axis scrollDirection;

  final bool _isBuilder;

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
      _locked = (scaleState == PhotoViewScaleState.initial ||
              scaleState == PhotoViewScaleState.zoomedOut)
          ? false
          : true;
    });
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback(scaleState);
    }
  }

  int get actualPage {
    return _controller.hasClients ? _controller.page.floor() : 0;
  }

  int get itemCount {
    if (widget._isBuilder) {
      return widget.itemCount;
    }
    return widget.pageOptions.length;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: widget.onPageChanged,
      itemCount: itemCount,
      itemBuilder: _buildItem,
      scrollDirection: widget.scrollDirection,
      physics:
          _locked ? const NeverScrollableScrollPhysics() : widget.scrollPhysics,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);
    return ClipRect(
      child: PhotoView(
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
        initialScale: pageOption.initialScale,
        minScale: pageOption.minScale,
        maxScale: pageOption.maxScale,
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildPageOption(
      BuildContext context, int index) {
    if (widget._isBuilder) {
      return widget.builder(context, index);
    }
    return widget.pageOptions[index];
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
      this.controller,
      this.basePosition});

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

  /// Mirror to [PhotoView.basePosition]
  final Alignment basePosition;
}
