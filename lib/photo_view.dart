library photo_view;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:photo_view/photo_view_image_wrapper.dart';
import 'package:photo_view/photo_view_scale_type.dart';
import 'package:photo_view/photo_view_utils.dart';


class PhotoView extends StatefulWidget{
  final ImageProvider imageProvider;
  final Widget loadingChild;

  PhotoView({
    Key key,
    @required this.imageProvider,
    this.loadingChild
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _PhotoViewState();
  }
}


class _PhotoViewState extends State<PhotoView>{
  PhotoViewScaleType _scaleType;

  Future<ImageInfo> _getImage(){
    Completer completer = new Completer<ImageInfo>();
    ImageStream stream = widget.imageProvider.resolve(new ImageConfiguration());
    stream.addListener((ImageInfo info, bool completed) {
      completer.complete(info);
    });
    return completer.future;
  }

  void onDoubleTap () {
    setState(() {
      _scaleType = nextScaleType(_scaleType);
    });
  }

  void onStartPanning () {
    setState(() {
      _scaleType = PhotoViewScaleType.zooming;
    });
  }

  @override
  void initState(){
    super.initState();
    _scaleType = PhotoViewScaleType.contained;
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
              imageInfo: info.data,
              scaleType: _scaleType,
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
