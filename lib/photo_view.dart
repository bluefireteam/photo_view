library photo_view;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_image_wrapper.dart';
import 'package:photo_view/photo_view_scale_boundaries.dart';
import 'package:photo_view/photo_view_scale_state.dart';
import 'package:photo_view/photo_view_utils.dart';
import 'package:after_layout/after_layout.dart';

export 'package:photo_view/photo_view_scale_boundary.dart';

class PhotoView extends StatefulWidget{
  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Color backgroundColor;
  final minScale;
  final maxScale;
  final bool gaplessPlayback;
  final Size size;
  final String heroTag;

  const PhotoView({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 1.0),
    this.minScale,
    this.maxScale,
    this.gaplessPlayback = false,
    this.size,
    this.heroTag,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _PhotoViewState();
  }
}


class _PhotoViewState extends State<PhotoView>{
  PhotoViewScaleState _scaleState;
  GlobalKey containerKey = GlobalKey();
  ImageInfo _imageInfo;

  Future<ImageInfo> _getImage(){
    final Completer completer = new Completer<ImageInfo>();
    final ImageStream stream = widget.imageProvider.resolve(const ImageConfiguration());
    final listener = (ImageInfo info, bool synchronousCall) {
      if(!completer.isCompleted){
        completer.complete(info);
        setState(() {
          _imageInfo = info;
        });
      }
    };
    stream.addListener(listener);
    completer.future.then((_){ stream.removeListener(listener); });
    return completer.future;
  }

  void onDoubleTap () {
    setState(() {
      _scaleState = nextScaleState(_scaleState);
    });
  }

  void onStartPanning () {
    setState(() {
      _scaleState = PhotoViewScaleState.zooming;
    });
  }

  @override
  void initState(){
    super.initState();
    _getImage();
    _scaleState = PhotoViewScaleState.contained;
  }
  @override
  Widget build(BuildContext context) {
    return widget.heroTag == null ? buildWithFuture(context) : buildSync(context);
  }

  Widget buildWithFuture(BuildContext context){
    return FutureBuilder(
        future: _getImage(),
        builder: (BuildContext context, AsyncSnapshot<ImageInfo> info) {
          if(info.hasData){
            return buildWrapper(context, info.data);
          } else {
            return buildLoading();
          }
        }
    );
  }

  Widget buildSync(BuildContext context){
    if (_imageInfo == null) {
      return buildLoading();
    }
    return buildWrapper(context, _imageInfo);
  }

  Widget buildWrapper(BuildContext context, ImageInfo info){
    return PhotoViewImageWrapper(
      onDoubleTap: onDoubleTap,
      onStartPanning: onStartPanning,
      imageProvider: widget.imageProvider,
      imageInfo: info,
      scaleState: _scaleState,
      backgroundColor: widget.backgroundColor,
      gaplessPlayback: widget.gaplessPlayback,
      size: widget.size ?? MediaQuery.of(context).size,
      scaleBoundaries: ScaleBoundaries(
        widget.minScale ?? 0.0,
        widget.maxScale ?? 100000000000.0,
        imageInfo: info,
        size: widget.size ?? MediaQuery.of(context).size,
      ),
      heroTag: widget.heroTag,
    );
  }

  Widget buildLoading() {
    return widget.loadingChild != null
      ? widget.loadingChild
      // ignore: prefer_const_constructors
      : Center(
      child: Container(
        width: 20.0,
        height: 20.0,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}


class PhotoViewInline extends StatefulWidget{
  final ImageProvider imageProvider;
  final Widget loadingChild;
  final Color backgroundColor;
  final minScale;
  final maxScale;

  PhotoViewInline({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 1.0),
    this.minScale,
    this.maxScale,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PhotoViewInlineState();
}

class _PhotoViewInlineState extends State<PhotoViewInline> with AfterLayoutMixin<PhotoViewInline>{

  Size _size;

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      _size = context.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new PhotoView(
      imageProvider: widget.imageProvider,
      loadingChild: widget.loadingChild,
      backgroundColor: widget.backgroundColor,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      size: _size,
    );
  }



}