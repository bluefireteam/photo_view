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

  PhotoView({
    Key key,
    @required this.imageProvider,
    this.loadingChild,
    this.backgroundColor = const Color.fromRGBO(0, 0, 0, 1.0),
    this.minScale,
    this.maxScale,
    this.gaplessPlayback = false,
    this.size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _PhotoViewState();
  }
}


class _PhotoViewState extends State<PhotoView>{
  PhotoViewScaleState _scaleState;
  GlobalKey containerKey = new GlobalKey();

  Future<ImageInfo> _getImage(){
    Completer completer = new Completer<ImageInfo>();
    ImageStream stream = widget.imageProvider.resolve(new ImageConfiguration());
    var listener = (ImageInfo info, bool completed) {
      completer.complete(info);
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
    _scaleState = PhotoViewScaleState.contained;
  }
  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: _getImage(),
        builder: (BuildContext context, AsyncSnapshot<ImageInfo> info) {
          if(info.hasData){
            return new PhotoViewImageWrapper(
              onDoubleTap: onDoubleTap,
              onStartPanning: onStartPanning,
              imageProvider: widget.imageProvider,
              imageInfo: info.data,
              scaleState: _scaleState,
              backgroundColor: widget.backgroundColor,
              gaplessPlayback: widget.gaplessPlayback,
              size: widget.size ?? MediaQuery.of(context).size,
              scaleBoundaries: new ScaleBoundaries(
                widget.minScale ?? 0.0,
                widget.maxScale ?? 100000000000.0,
                imageInfo: info.data,
                size: widget.size ?? MediaQuery.of(context).size,
              ),
            );
          } else {
            return buildLoading();
          }
        }
    );

  }

  Widget buildLoading() {
    return widget.loadingChild != null
      ? widget.loadingChild
      : new Center(
        child: new Text(
          "Loading",
          style: new TextStyle(
            color: Colors.white
          ),
        )
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