library photo_view;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_image_wrapper.dart';
import 'package:photo_view/src/photo_view_scale_boundaries.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:after_layout/after_layout.dart';

export 'package:photo_view/src/photo_view_computed_scale.dart';
export 'package:photo_view/photo_view_gallery.dart';

typedef PhotoViewScaleStateChangedCallback = void Function(
    PhotoViewScaleState scaleState);

/// A [StatefulWidget] that contains all the photo view rendering elements.
///
/// Internally, the image is rendered within an [Image] widget.
///
/// To use along a hero animation, provide [heroTag] param.
///
/// Sample code:
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  loadingChild: new LoadingText(),
///  backgroundColor: Colors.white,
///  minScale: PhotoViewComputedScale.contained,
///  maxScale: 2.0,
///  gaplessPlayback: false,
///  size:MediaQuery.of(context).size,
///  heroTag: "someTag"
/// );
/// ```
///

class PhotoView extends StatefulWidget {
  /// Creates a widget that displays an zoomable image.
  ///
  /// To show an image from the network or from an asset bundle, use their respective
  /// image providers, ie: [AssetImage] or [NetworkImage]
  ///
  /// The [maxScale] and [minScale] arguments may be [double] or a [PhotoViewComputedScale] constant
  ///
  /// Sample using [maxScale] and [minScale]
  ///
  /// ```
  /// PhotoView(
  ///  imageProvider: imageProvider,
  ///  minScale: PhotoViewComputedScale.contained * 1.8,
  ///  maxScale: PhotoViewComputedScale.covered * 1.1
  /// );
  /// ```
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
  const PhotoView({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 1.0),
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.gaplessPlayback = false,
    this.customSize,
    this.heroTag,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
  }) : super(key: key);

  /// Given a [imageProvider] it resolves into an zoomable image widget using. It
  /// is required
  final ImageProvider imageProvider;

  /// While [imageProvider] is not resolved, [loadingChild] is build by [PhotoView]
  /// into the screen, by default it is a centered [CircularProgressIndicator]
  final Widget loadingChild;

  /// Changes the background behind image, defaults to `Colors.black`.
  final Color backgroundColor;

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

  final PhotoViewScaleStateChangedCallback scaleStateChangedCallback;

  final bool enableRotation;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoView>
    with AfterLayoutMixin<PhotoView> {
  PhotoViewScaleState _scaleState;
  ImageInfo _imageInfo;
  Size _size;

  Future<ImageInfo> _getImage() {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream =
        widget.imageProvider.resolve(const ImageConfiguration());
    final listener = (ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
        setState(() {
          _imageInfo = info;
        });
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
    _getImage();
    _scaleState = PhotoViewScaleState.initial;
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      _size = context.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.heroTag == null
        ? buildWithFuture(context)
        : buildSync(context);
  }

  Widget buildWithFuture(BuildContext context) {
    return FutureBuilder(
        future: _getImage(),
        builder: (BuildContext context, AsyncSnapshot<ImageInfo> info) {
          if (info.hasData) {
            return buildWrapper(context, info.data);
          } else {
            return buildLoading();
          }
        });
  }

  Widget buildSync(BuildContext context) {
    if (_imageInfo == null) {
      return buildLoading();
    }
    return buildWrapper(context, _imageInfo);
  }

  Widget buildWrapper(BuildContext context, ImageInfo info) {
    return PhotoViewImageWrapper(
      setNextScaleState: setNextScaleState,
      onStartPanning: onStartPanning,
      imageProvider: widget.imageProvider,
      imageInfo: info,
      scaleState: _scaleState,
      backgroundColor: widget.backgroundColor,
      gaplessPlayback: widget.gaplessPlayback,
      size: _computedSize,
      enableRotation: widget.enableRotation,
      scaleBoundaries: ScaleBoundaries(
        widget.minScale ?? 0.0,
        widget.maxScale ?? double.infinity,
        widget.initialScale ?? PhotoViewComputedScale.contained,
        imageInfo: info,
        size: _computedSize,
      ),
      heroTag: widget.heroTag,
    );
  }

  Widget buildLoading() {
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

  Size get _computedSize => widget.customSize ?? _size ?? MediaQuery.of(context).size;
}

@Deprecated("Use PhotoView instead")
class PhotoViewInline extends PhotoView {
  const PhotoViewInline({
    Key key,
    @required ImageProvider imageProvider,
    Widget loadingChild,
    Color backgroundColor,
    dynamic minScale,
    dynamic maxScale,
    dynamic initialScale,
    bool gaplessPlayback,
    Size size,
    Object heroTag,
    PhotoViewScaleStateChangedCallback scaleStateChangedCallback,
  }) : super(
            key: key,
            imageProvider: imageProvider,
            loadingChild: loadingChild,
            backgroundColor: backgroundColor,
            minScale: minScale,
            maxScale: maxScale,
            initialScale: initialScale,
            gaplessPlayback: gaplessPlayback,
            customSize: size,
            heroTag: heroTag,
            scaleStateChangedCallback: scaleStateChangedCallback);
}
