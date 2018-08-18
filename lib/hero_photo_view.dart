import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_image_wrapper.dart';
import 'package:photo_view/photo_view_scale_boundaries.dart';
import 'package:photo_view/photo_view_scale_state.dart';
import 'package:photo_view/photo_view_utils.dart';

export 'package:photo_view/photo_view_scale_boundary.dart';

class HeroPhotoView extends PhotoView {
  HeroPhotoView({
    Key key,
    @required ImageProvider imageProvider,
    Color backgroundColor = const Color.fromRGBO(0, 0, 0, 1.0),
    minScale,
    maxScale,
    bool gaplessPlayback = false,
    Size size,
  }) : super(
            key: key,
            imageProvider: imageProvider,
            backgroundColor: backgroundColor,
            minScale: minScale,
            maxScale: maxScale,
            gaplessPlayback: gaplessPlayback,
            size: size);

  @override
  State<StatefulWidget> createState() {
    return new _HeroPhotoViewState();
  }
}

class _HeroPhotoViewState extends State<HeroPhotoView> {
  PhotoViewScaleState _scaleState;
  GlobalKey containerKey = new GlobalKey();
  ImageInfo _imageInfo;

  Future<ImageInfo> _getImage() {
    Completer completer = new Completer<ImageInfo>();
    ImageStream stream = widget.imageProvider.resolve(new ImageConfiguration());
    var listener = (ImageInfo info, bool completed) {
      completer.complete(info);
      setState(() {
        _imageInfo = info;
      });
    };
    stream.addListener(listener);
    completer.future.then((_) {
      stream.removeListener(listener);
    });
    return completer.future;
  }

  void onDoubleTap() {
    setState(() {
      _scaleState = nextScaleState(_scaleState);
    });
  }

  void onStartPanning() {
    setState(() {
      _scaleState = PhotoViewScaleState.zooming;
    });
  }

  @override
  void initState() {
    _getImage();
    super.initState();
    _scaleState = PhotoViewScaleState.contained;
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return new SizedBox();
    }
    return new PhotoViewImageWrapper(
      onDoubleTap: onDoubleTap,
      onStartPanning: onStartPanning,
      imageProvider: widget.imageProvider,
      imageInfo: _imageInfo,
      scaleState: _scaleState,
      backgroundColor: widget.backgroundColor,
      gaplessPlayback: widget.gaplessPlayback,
      size: widget.size ?? MediaQuery.of(context).size,
      scaleBoundaries: new ScaleBoundaries(
        widget.minScale ?? 0.0,
        widget.maxScale ?? 100000000000.0,
        imageInfo: _imageInfo,
        size: widget.size ?? MediaQuery.of(context).size,
      ),
    );
  }
}
