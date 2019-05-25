library photo_view;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/src/photo_view_computed_scale.dart';
import 'package:photo_view/src/photo_view_controller.dart';
import 'package:photo_view/src/photo_view_controller_delegate.dart';
import 'package:photo_view/src/photo_view_image_wrapper.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:after_layout/after_layout.dart';
import 'package:photo_view/src/photo_view_typedefs.dart';
import 'package:photo_view/src/photo_view_utils.dart';

export 'package:photo_view/src/photo_view_computed_scale.dart';
export 'package:photo_view/src/photo_view_scale_state.dart';
export 'package:photo_view/src/photo_view_controller.dart';
export 'package:photo_view/src/photo_view_typedefs.dart';

/// A [StatefulWidget] that contains all the photo view rendering elements.
///
/// Sample code to use within an image:
///
/// ```
/// PhotoView(
///  imageProvider: imageProvider,
///  loadingChild: LoadingText(),
///  backgroundDecoration: BoxDecoration(color: Colors.black),
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroTag: "someTag",
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  transitionOnUserGestures: true,
///  controller:  controller,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
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
///  gaplessPlayback: false,
///  customSize: MediaQuery.of(context).size,
///  heroTag: "someTag",
///  scaleStateChangedCallback: this.onScaleStateChanged,
///  enableRotation: true,
///  transitionOnUserGestures: true,
///  controller:  controller,
///  minScale: PhotoViewComputedScale.contained * 0.8,
///  maxScale: PhotoViewComputedScale.covered * 1.8,
///  initialScale: PhotoViewComputedScale.contained,
///  basePosition: Alignment.center,
///  scaleStateCycle: scaleStateCycle
/// );
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
/// Sample using hero animation:
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
/// **Note: If you don't want to the zoomed image do not overlaps the size of the container, use [ClipRect](https://docs.flutter.io/flutter/widgets/ClipRect-class.html)**
///
/// ## Controllers
///
/// Controllers, when specified to PhotoView widget, enables the author(you) to listen for state updates through a `Stream` and change those values externally.
///
/// While [PhotoViewScaleStateController] is only responsible for the `scaleState`, [PhotoViewController] is responsible for all fields os [PhotoViewControllerValue].
///
/// To use them, pass a instance of those items on [controller] or [scaleStateController];
///
/// Since those follows the standard controller pattern found in widgets like [PageView] and [ScrollView], whoever instantiates it, should [dispose] it afterwards.
///
/// Example of [controller] usage, only listening for state changes:
///
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   PhotoViewController controller;
///   double scaleCopy;
///
///   @override
///   void initState() {
///     super.initState();
///     controller = PhotoViewController()
///       ..outputStateStream.listen(listener);
///   }
///
///   @override
///   void dispose() {
///     controller.dispose();
///     super.dispose();
///   }
///
///   void listener(PhotoViewControllerValue value){
///     scaleCopy = value.scale;
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: PhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               controller: controller,
///             );
///         ),
///         Text("Scale applied: $scaleCopy")
///       ],
///     );
///   }
/// }
/// ```
///
/// An example of [scaleStateController] with state changes:
/// ```
/// class _ExampleWidgetState extends State<ExampleWidget> {
///
///   PhotoViewScaleStateController scaleStateController;
///
///   @override
///   void initState() {
///     super.initState();
///     scaleStateController = PhotoViewScaleStateController();
///   }
///
///   @override
///   void dispose() {
///     scaleStateController.dispose();
///     super.dispose();
///   }
///
///   void goBack(){
///     scaleStateController.scaleState = PhotoViewScaleState.originalSize;
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Stack(
///       children: <Widget>[
///         Positioned.fill(
///             child: PhotoView(
///               imageProvider: AssetImage("assets/pudim.png"),
///               scaleStateController: scaleStateController,
///               );
///         ),
///         FlatButton(
///           child: Text("Go to original size"),
///           onPressed: goBack,
///         );
///       ],
///     );
///   }
/// }
/// ```
///
class PhotoView extends StatefulWidget {
  /// Creates a widget that displays a zoomable image.
  ///
  /// To show an image from the network or from an asset bundle, use their respective
  /// image providers, ie: [AssetImage] or [NetworkImage]
  ///
  /// Internally, the image is rendered within an [Image] widget.
  PhotoView({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.customSize,
    this.heroTag,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.transitionOnUserGestures = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
  })  : child = null,
        childSize = null,
        super(key: key);

  /// Creates a widget that displays a zoomable child.
  ///
  /// It has been created to resemble [PhotoView] behavior within widgets that aren't an image, such as [Container], [Text] or a svg.
  ///
  /// Instead of a [imageProvider], this constructor will receive a [child] and a [childSize].
  ///
  PhotoView.customChild({
    Key key,
    @required this.child,
    @required this.childSize,
    this.backgroundDecoration,
    this.customSize,
    this.heroTag,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.transitionOnUserGestures = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
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

  /// Defines the maximum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic maxScale;

  /// Defines the minimum size in which the image will be allowed to assume, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic minScale;

  /// Defines the initial size in which the image will be assume in the mounting of the component, it
  /// is proportional to the original image size. Can be either a double (absolute value) or a
  /// [PhotoViewComputedScale], that can be multiplied by a double
  final dynamic initialScale;

  /// A way to control PhotoView transformation factors externally and listen to its updates
  final PhotoViewControllerBase controller;

  /// A way to control PhotoViewScaleState value externally and listen to its updates
  final PhotoViewScaleStateController scaleStateController;

  /// The alignment of the scale origin in relation to the widget size. Default is [Alignment.center]
  final Alignment basePosition;

  /// Defines de next [PhotoViewScaleState] given the actual one. Default is [defaultScaleStateCycle]
  final ScaleStateCycle scaleStateCycle;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  final PhotoViewImageTapUpCallback onTapUp;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  final PhotoViewImageTapDownCallback onTapDown;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }
}

class _PhotoViewState extends State<PhotoView>
    with AfterLayoutMixin<PhotoView> {
  bool _loading;
  Size _childSize;
  Size _outerSize;

  bool _controlledController;
  PhotoViewControllerBase _controller;

  bool _controlledScaleStateController;
  PhotoViewScaleStateController _scaleStateController;

  Future<ImageInfo> _getImage() {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream =
        widget.imageProvider.resolve(const ImageConfiguration());
    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
        if (mounted) {
          setState(() {
            _childSize =
                Size(info.image.width.toDouble(), info.image.height.toDouble());
            _loading = false;
          });
        }
      }
    });
    stream.addListener(listener);
    completer.future.then((_) {
      stream.removeListener(listener);
    });
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    if (widget.child == null) {
      _getImage();
    } else {
      _childSize = widget.childSize;
      _loading = false;
    }
    if (widget.controller == null) {
      _controlledController = true;
      _controller = PhotoViewController();
    } else {
      _controlledController = false;
      _controller = widget.controller;
    }

    if (widget.scaleStateController == null) {
      _controlledScaleStateController = true;
      _scaleStateController = PhotoViewScaleStateController();
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController;
    }

    _scaleStateController.outputScaleStateStream.listen(scaleStateListener);
  }

  @override
  void didUpdateWidget(PhotoView oldWidget) {
    if (oldWidget.childSize != widget.childSize && widget.childSize != null) {
      setState(() {
        _childSize = widget.childSize;
      });
    }
    if (oldWidget.customSize != widget.customSize) {
      setState(() {
        _outerSize = widget.customSize;
      });
    }
    if (widget.controller == null) {
      if (!_controlledController) {
        _controlledController = true;
        _controller = PhotoViewController();
      }
    } else {
      _controlledController = false;
      _controller = widget.controller;
    }

    if (widget.scaleStateController == null) {
      if (!_controlledScaleStateController) {
        _controlledScaleStateController = true;
        _scaleStateController = PhotoViewScaleStateController();
      }
    } else {
      _controlledScaleStateController = false;
      _scaleStateController = widget.scaleStateController;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controlledController) {
      _controller.dispose();
    }
    if (_controlledScaleStateController) {
      _scaleStateController.dispose();
    }
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (mounted) {
      _outerSize = context.size;
    }
  }

  void scaleStateListener(PhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback(_scaleStateController.scaleState);
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
      backgroundDecoration: widget.backgroundDecoration,
      enableRotation: widget.enableRotation,
      heroTag: widget.heroTag,
      delegate: PhotoViewControllerDelegate(
        controller: _controller,
        scaleStateController: _scaleStateController,
        scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
        basePosition: widget.basePosition ?? Alignment.center,
        scaleBoundaries: ScaleBoundaries(
          widget.minScale ?? 0.0,
          widget.maxScale ?? double.infinity,
          widget.initialScale ?? PhotoViewComputedScale.contained,
          _computedOuterSize,
          _childSize,
        ),
      ),
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
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
    if (_loading == null) {
      return _buildLoading();
    }
    return _buildWrapperImage(context);
  }

  Widget _buildWrapperImage(BuildContext context) {
    return PhotoViewImageWrapper(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      gaplessPlayback: widget.gaplessPlayback,
      enableRotation: widget.enableRotation,
      heroTag: widget.heroTag,
      transitionOnUserGestures: widget.transitionOnUserGestures,
      delegate: PhotoViewControllerDelegate(
        basePosition: widget.basePosition ?? Alignment.center,
        controller: _controller,
        scaleStateController: _scaleStateController,
        scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
        scaleBoundaries: ScaleBoundaries(
          widget.minScale ?? 0.0,
          widget.maxScale ?? double.infinity,
          widget.initialScale ?? PhotoViewComputedScale.contained,
          _computedOuterSize,
          _childSize,
        ),
      ),
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
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

  Size get _computedOuterSize =>
      widget.customSize ?? _outerSize ?? MediaQuery.of(context).size;
}

/// The default [ScaleStateCycle]
PhotoViewScaleState defaultScaleStateCycle(PhotoViewScaleState actual) {
  switch (actual) {
    case PhotoViewScaleState.initial:
      return PhotoViewScaleState.covering;
    case PhotoViewScaleState.covering:
      return PhotoViewScaleState.originalSize;
    case PhotoViewScaleState.originalSize:
      return PhotoViewScaleState.initial;
    case PhotoViewScaleState.zoomedIn:
    case PhotoViewScaleState.zoomedOut:
      return PhotoViewScaleState.initial;
    default:
      return PhotoViewScaleState.initial;
  }
}
