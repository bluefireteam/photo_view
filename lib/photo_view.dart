library photo_view;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_image_wrapper.dart';
import 'package:photo_view/src/photo_view_scale_boundaries.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:after_layout/after_layout.dart';

export 'package:photo_view/src/photo_view_computed_scale.dart';
export 'package:photo_view/src/photo_view_scale_state.dart';

/// A type definition for a [Function] that receives a [PhotoViewScaleState]
///
typedef PhotoViewScaleStateChangedCallback = void Function(
    PhotoViewScaleState scaleState);

/// A [StatefulWidget] that contains all the photo view rendering elements.
///
/// To use the hero animation, provide [heroTag] param.
///
/// Sample code to use within an image:
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  loadingChild: LoadingText(),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained * 1.1,
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroTag: "someTag",
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
/// );
/// ```
///
/// You can customize to show an custom child instead of an image:
///
/// ```
/// PhotoView.customChild(
///  child: Container(
///    width: 220.0,
///    height: 250.0,
///    child: const Text(
///      "Hello there, this is a text",
///    )
///  ),
///  childSize: const Size(220.0, 250.0),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: 1.0,
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroTag: "someTag",
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
/// );
/// ```
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
/// Sample using [maxScale], [minScale] and [initialScale]
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained * 1.1,
/// );
/// ```
///
/// [customSize] is used to define the viewPort size in which the image will be
/// scaled to. This argument is rarely used. By befault is the size that this widget assumes.
///
/// The argument [gaplessPlayback] is used to continue showing the old image
/// (`true`), or briefly show nothing (`false`), when the [imageProvider]
/// changes.By default it's set to `false`.
///
/// To use within an hero animation, specify [heroTag]. When [heroTag] is
/// specified, the image provider retrieval process should be sync.
///
/// Sample using hero animation
/// ```
/// // screen1
///   ...
///   Hero(
///     tag: "someTag",
///     child: Image.asset(
///       "assets/large-image.jpg",
///       width: 150.0
///     ),
///   )
/// // screen2
/// ...
/// child: PhotoView(
///   imageProvider: AssetImage("assets/large-image.jpg"),
///   heroTag: "someTag",
/// )
/// ```
///
class PhotoView extends StatefulWidget {

  /// Creates a widget that displays a zoomable image.
  ///
  /// To show an image from the network or from an asset bundle, use their respective
  /// image providers, ie: [AssetImage] or [NetworkImage]
  ///
  /// Internally, the image is rendered within an [Image] widget.
  const PhotoView({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.gaplessPlayback = false,
    this.customSize,
    this.heroTag,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.transitionOnUserGestures = false,
  })  : child = null,
        childSize = null,
        super(key: key);

  /// Creates a widget that displays a zoomable child.
  ///
  /// It has been created to resemble [PhotoView] behavior within widgets that aren't an image, such as [Container], [Text] or a svg.
  ///
  /// Instead of a [imageProvider], this constructor will receive a [child] and a [childSize].
  ///
  const PhotoView.customChild({
    Key key,
    @required this.child,
    @required this.childSize,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.customSize,
    this.heroTag,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.transitionOnUserGestures = false,
  })  : loadingChild = null,
        imageProvider = null,
        gaplessPlayback = false,
        super(key: key);

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider imageProvider;

  /// While [imageProvider] is not resolved, [loadingChild] is build by [PhotoView]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final Widget loadingChild;

  /// Changes the background behind image, defaults to `Colors.black`.
  final Decoration backgroundDecoration;

  /// Defines the minimal size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic minScale;

  /// Defines the maximal size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic maxScale;

  /// Defines the inial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic initialScale;

  /// This is used to continue showing the old image (`true`), or briefly show
  /// nothing (`false`), when the `imageProvider` changes. By default it's set
  /// to `false`.
  final bool gaplessPlayback;

  /// Defines the size of the scaling base of the image inside [PhotoView],
  /// by default it is `MediaQuery.of(context).size`.
  final Size customSize;

  /// Assists the activation of a hero animation within [PhotoView]
  final Object heroTag;

  /// A [Function] to be called whenever the scaleState changes, this heappens when the user double taps the content ou start to pinch-in.
  final PhotoViewScaleStateChangedCallback scaleStateChangedCallback;

  /// A flag that enables the rotation gesture support
  final bool enableRotation;

  /// The specified custom child to be shown instead of a image
  final Widget child;

  /// The size of the custom [child]. [PhotoView] uses this value to compute the relation between the child and the container's size to calculate the scale value.
  final Size childSize;

  /// The value specified to homonimous option givento to [Hero]. Sets [Hero.transitionOnUserGestures] in teh internal hero.
  ///
  /// Should only be set when [PhotoView.heroTag] is set
  final bool transitionOnUserGestures;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoView>
    with AfterLayoutMixin<PhotoView> {
  PhotoViewScaleState _scaleState;
  Size _size;
  Size _childSize;

  Future<ImageInfo> _getImage() {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream =
        widget.imageProvider.resolve(const ImageConfiguration());
    final listener = (ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
        if (mounted) {
          setState(() {
            _childSize = Size(info.image.width / 1, info.image.height / 1);
          });
        }
      }
    };
    stream.addListener(listener);
    completer.future.then((_) {
      stream.removeListener(listener);
    });
    return completer.future;
  }

  void setNextScaleState(PhotoViewScaleState newScaleState) {
    setState(() {
      _scaleState = newScaleState;
    });
    widget.scaleStateChangedCallback != null
        ? widget.scaleStateChangedCallback(newScaleState)
        : null;
  }

  void onStartPanning() {
    setState(() {
      _scaleState = PhotoViewScaleState.zooming;
    });
    widget.scaleStateChangedCallback != null
        ? widget.scaleStateChangedCallback(PhotoViewScaleState.zooming)
        : null;
  }

  @override
  void initState() {
    super.initState();
    widget.child ?? _getImage();
    if (widget.child != null) {
      if (widget.childSize != null) {
        _childSize = Size.zero;
      }
      _childSize = widget.childSize;
    }
    _scaleState = PhotoViewScaleState.initial;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      setState(() {
        _size = context.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child == null
        ? _buildImage(context)
        : _buildCustomChild(context);
  }

  Widget _buildCustomChild(BuildContext context) {
    return PhotoViewImageWrapper.customChild(
      customChild: widget.child,
      setNextScaleState: setNextScaleState,
      onStartPanning: onStartPanning,
      childSize: _childSize,
      scaleState: _scaleState,
      backgroundDecoration: widget.backgroundDecoration,
      size: _computedSize,
      enableRotation: widget.enableRotation,
      scaleBoundaries: ScaleBoundaries(
        widget.minScale ?? 0.0,
        widget.maxScale ?? double.infinity,
        widget.initialScale ?? PhotoViewComputedScale.contained,
        childSize: _childSize,
        size: _computedSize,
      ),
      heroTag: widget.heroTag,
    );
  }

  Widget _buildImage(BuildContext context) {
    return widget.heroTag == null
        ? _buildWithFuture(context)
        : _buildSync(context);
  }

  Widget _buildWithFuture(BuildContext context) {
    return FutureBuilder(
        future: _getImage(),
        builder: (BuildContext context, AsyncSnapshot<ImageInfo> info) {
          if (info.hasData) {
            return _buildWrapperImage(context);
          } else {
            return _buildLoading();
          }
        });
  }

  Widget _buildSync(BuildContext context) {
    if (_childSize == null) {
      return _buildLoading();
    }
    return _buildWrapperImage(context);
  }

  Widget _buildWrapperImage(BuildContext context) {
    return PhotoViewImageWrapper(
      setNextScaleState: setNextScaleState,
      onStartPanning: onStartPanning,
      imageProvider: widget.imageProvider,
      childSize: _childSize,
      scaleState: _scaleState,
      backgroundDecoration: widget.backgroundDecoration,
      gaplessPlayback: widget.gaplessPlayback,
      size: _computedSize,
      enableRotation: widget.enableRotation,
      scaleBoundaries: ScaleBoundaries(
        widget.minScale ?? 0.0,
        widget.maxScale ?? double.infinity,
        widget.initialScale ?? PhotoViewComputedScale.contained,
        childSize: _childSize,
        size: _computedSize,
      ),
      heroTag: widget.heroTag,
      transitionOnUserGestures: widget.transitionOnUserGestures,
    );
  }

  Widget _buildLoading() {
    return widget.loadingChild != null
        ? widget.loadingChild
        : Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: const CircularProgressIndicator(),
            ),
          );
  }

  Size get _computedSize =>
      widget.customSize ?? _size ?? MediaQuery.of(context).size;
}
