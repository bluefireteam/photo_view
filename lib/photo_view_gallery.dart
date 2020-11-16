library photo_view_gallery;

import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart'
    show
        LoadingBuilder,
        PhotoView,
        PhotoViewImageTapDownCallback,
        PhotoViewImageTapUpCallback,
        ScaleStateCycle;

import 'package:photo_view/src/controller/photo_view_controller.dart';
import 'package:photo_view/src/controller/photo_view_scalestate_controller.dart';
import 'package:photo_view/src/core/photo_view_gesture_detector.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/utils/photo_view_hero_attributes.dart';
import 'package:photo_view/src/utils/photoview_options.dart';

/// A type definition for a [Function] that receives a index after a page change in [PhotoViewGallery]
typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

/// A type definition for a [Function] that defines a page in [PhotoViewGallery.build]
typedef PhotoViewGalleryBuilder = PhotoViewGalleryPageOptions Function(
    BuildContext context, int index);

/// A [StatefulWidget] that shows multiple [PhotoView] widgets in a [PageView]
///
/// Some of [PhotoView] constructor options are passed direct to [PhotoViewGallery] cosntructor. Those options will affect the gallery in a whole.
///
/// Some of the options may be defined to each image individually, such as `initialScale` or `heroAttributes`. Those must be passed via each [PhotoViewGalleryPageOptions].
///
/// Example of usage as a list of options:
/// ```
///
/// final loadingBuilder = (context, progress) => Center(
///   child: Container(
///     width: 20.0,
///     height: 20.0,
///     child: CircularProgressIndicator(
///       value: _progress == null
///           ? null
///           : _progress.cumulativeBytesLoaded /
///           _progress.expectedTotalBytes,
///     ),
///   ),
/// );
/// PhotoViewGallery(
///   pageOptions: <PhotoViewGalleryPageOptions>[
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery1.jpg"),
///       heroAttributes: const HeroAttributes(tag: "tag1"),
///       loadingBuilder: loadingBuilder,
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery2.jpg"),
///       heroAttributes: const HeroAttributes(tag: "tag2"),
///       maxScale: PhotoViewComputedScale.contained * 0.3,
///       loadingBuilder: loadingBuilder,
///     ),
///     PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage("assets/gallery3.jpg"),
///       minScale: PhotoViewComputedScale.contained * 0.8,
///       maxScale: PhotoViewComputedScale.covered * 1.1,
///       heroAttributes: const HeroAttributes(tag: "tag3"),
///       loadingBuilder: loadingBuilder,
///     ),
///   ],
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
///
/// Example of usage with builder pattern:
/// ```
/// final loadingBuilder = (context, progress) => Center(
///   child: Container(
///     width: 20.0,
///     height: 20.0,
///     child: CircularProgressIndicator(
///       value: _progress == null
///           ? null
///           : _progress.cumulativeBytesLoaded /
///           _progress.expectedTotalBytes,
///     ),
///   ),
/// );
/// PhotoViewGallery.builder(
///   scrollPhysics: const BouncingScrollPhysics(),
///   builder: (BuildContext context, int index) {
///     return PhotoViewGalleryPageOptions(
///       imageProvider: AssetImage(widget.galleryItems[index].image),
///       initialScale: PhotoViewComputedScale.contained * 0.8,
///       minScale: PhotoViewComputedScale.contained * 0.8,
///       maxScale: PhotoViewComputedScale.covered * 1.1,
///       heroAttributes: HeroAttributes(tag: galleryItems[index].id),
///       loadingBuilder: loadingBuilder
///     );
///   },
///   itemCount: galleryItems.length,
///   pageController: widget.pageController,
///   onPageChanged: onPageChanged,
/// )
/// ```
class PhotoViewGallery extends StatefulWidget {
  /// Construct a gallery with static items through a list of [PhotoViewGalleryPageOptions].
  const PhotoViewGallery({
    Key key,
    @required this.pageOptions,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
  })  : itemCount = null,
        builder = null,
        assert(pageOptions != null),
        super(key: key);

  /// Construct a gallery with dynamic items.
  ///
  /// The builder must return a [PhotoViewGalleryPageOptions].
  const PhotoViewGallery.builder({
    Key key,
    @required this.itemCount,
    @required this.builder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
  })  : pageOptions = null,
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

  /// Mirror to [PhotoView.backgroundDecoration]
  final Decoration backgroundDecoration;

  /// Mirror to [PhotoView.gaplessPlayback]
  final bool gaplessPlayback;

  /// Mirror to [PageView.reverse]
  final bool reverse;

  /// An object that controls the [PageView] inside [PhotoViewGallery]
  final PageController pageController;

  /// An callback to be called on a page change
  final PhotoViewGalleryPageChangedCallback onPageChanged;

  /// Mirror to [PhotoView.scaleStateChangedCallback]
  final ValueChanged<PhotoViewScaleState> scaleStateChangedCallback;

  /// The axis along which the [PageView] scrolls. Mirror to [PageView.scrollDirection]
  final Axis scrollDirection;

  bool get _isBuilder => builder != null;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewGalleryState();
  }
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> {
  PageController _controller;

  @override
  void initState() {
    _controller = widget.pageController ?? PageController();
    super.initState();
  }

  void scaleStateChangedCallback(PhotoViewScaleState scaleState) {
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
    // Enable corner hit test
    return PhotoViewGestureDetectorScope(
      axis: widget.scrollDirection,
      child: PageView.builder(
        reverse: widget.reverse,
        controller: _controller,
        onPageChanged: widget.onPageChanged,
        itemCount: itemCount,
        itemBuilder: _buildItem,
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);
    final isCustomChild = pageOption.child != null;

    final PhotoView photoView = isCustomChild
        ? PhotoView.customChild(
            key: ObjectKey(index),
            child: pageOption.child,
            childSize: pageOption.childSize,
            backgroundDecoration: widget.backgroundDecoration,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: pageOption.customSize,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: pageOption.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            disableGestures: pageOption.disableGestures,
          )
        : PhotoView(
            key: ObjectKey(index),
            imageProvider: pageOption.imageProvider,
            loadingBuilder: pageOption.loadingBuilder,
            loadFailedChild: pageOption.loadFailedChild,
            backgroundDecoration: widget.backgroundDecoration,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: pageOption.customSize,
            gaplessPlayback: widget.gaplessPlayback,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: pageOption.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            disableGestures: pageOption.disableGestures,
            errorBuilder: pageOption.errorBuilder,
          );

    return ClipRect(
      child: photoView,
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

/// A helper class that wraps individual options of a page in [PhotoViewGallery]
///
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
class PhotoViewGalleryPageOptions implements PhotoViewOptions {
  PhotoViewGalleryPageOptions({
    Key key,
    @required this.imageProvider,
    this.loadingBuilder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.errorBuilder,
  })  : child = null,
        childSize = null,
        assert(imageProvider != null);

  PhotoViewGalleryPageOptions.customChild({
    @required this.child,
    this.childSize,
    this.backgroundDecoration,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
  })  : loadFailedChild = null,
        errorBuilder = null,
        imageProvider = null,
        gaplessPlayback = false,
        loadingBuilder = null,
        assert(child != null);

  /// Mirror to [PhotoView.imageProvider]
  @override
  final ImageProvider imageProvider;

  /// Mirror to [PhotoView.heroAttributes]
  @override
  final PhotoViewHeroAttributes heroAttributes;

  /// Mirror to [PhotoView.minScale]
  @override
  final dynamic minScale;

  /// Mirror to [PhotoView.maxScale]
  @override
  final dynamic maxScale;

  /// Mirror to [PhotoView.initialScale]
  @override
  final dynamic initialScale;

  /// Mirror to [PhotoView.controller]
  @override
  final PhotoViewController controller;

  /// Mirror to [PhotoView.scaleStateController]
  @override
  final PhotoViewScaleStateController scaleStateController;

  /// Mirror to [PhotoView.basePosition]
  @override
  final Alignment basePosition;

  /// Mirror to [PhotoView.child]
  @override
  final Widget child;

  /// Mirror to [PhotoView.childSize]
  @override
  final Size childSize;

  /// Mirror to [PhotoView.scaleStateCycle]
  @override
  final ScaleStateCycle scaleStateCycle;

  /// Mirror to [PhotoView.onTapUp]
  @override
  final PhotoViewImageTapUpCallback onTapUp;

  /// Mirror to [PhotoView.onTapDown]
  @override
  final PhotoViewImageTapDownCallback onTapDown;

  /// Mirror to [PhotoView.gestureDetectorBehavior]
  @override
  final HitTestBehavior gestureDetectorBehavior;

  /// Mirror to [PhotoView.tightMode]
  @override
  final bool tightMode;

  /// Mirror to [PhotoView.disableGestures]
  @override
  final bool disableGestures;

  /// Mirror to [PhotoView.filterQuality]
  @override
  final FilterQuality filterQuality;

  /// Mirror to [PhotoView.backgroundDecoration]
  @override
  final Decoration backgroundDecoration;

  /// Mirror to [PhotoView.enableRotation]
  @override
  final bool enableRotation;

  /// Mirror to [PhotoView.errorBuilder]
  @override
  final ImageErrorWidgetBuilder errorBuilder;

  /// Mirror to [PhotoView.gaplessPlayback]
  @override
  final bool gaplessPlayback;

  @override
  final Widget loadFailedChild;

  /// Mirror to [PhotoView.loadingBuilder]
  @override
  final LoadingBuilder loadingBuilder;

  @override
  // TODO: implement scaleStateChangedCallback
  get scaleStateChangedCallback => throw UnimplementedError();

  @override
  // TODO: implement customSize
  Size get customSize => throw UnimplementedError();
}
