import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_scale_state.dart';

typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

class PhotoViewGallery extends StatefulWidget {
  const PhotoViewGallery({
    Key key,
    @required this.pageOptions,
    this.loadingChild,
    this.backgroundColor,
    this.gaplessPlayback = false,
    this.pageController,
    this.onPageChanged,
  }) : super(key: key);

  final List<PhotoViewGalleryPageOptions> pageOptions;
  final Widget loadingChild;
  final Color backgroundColor;
  final bool gaplessPlayback;
  final PageController pageController;
  final PhotoViewGalleryPageChangedCallback onPageChanged;

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

  void scaleStateChangedCallback (PhotoViewScaleState scaleState) {
    setState(() {
      _locked = scaleState != PhotoViewScaleState.contained;
    });
  }

  int get actualPage {
    return _controller.hasClients ?  _controller.page.floor() : 0;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: widget.onPageChanged,
      itemCount:  widget.pageOptions.length,
      itemBuilder: _buildItem,
      physics: _locked ? const NeverScrollableScrollPhysics() : null ,
    );
  }

  Widget _buildItem (context, int index){
    final pageOption = widget.pageOptions[index];
    return PhotoViewInline(
      key: ObjectKey(index),
      imageProvider: pageOption.imageProvider,
      loadingChild: widget.loadingChild,
      backgroundColor: widget.backgroundColor,
      minScale: pageOption.minScale,
      maxScale: pageOption.maxScale,
      gaplessPlayback: widget.gaplessPlayback,
      heroTag: pageOption.heroTag,
        scaleStateChangedCallback: scaleStateChangedCallback
    );
  }

}

class PhotoViewGalleryPageOptions {
  PhotoViewGalleryPageOptions({
    Key key,
    @required this.imageProvider,
    this.heroTag,
    this.minScale,
    this.maxScale,
  });

  final ImageProvider imageProvider;
  final Object heroTag;
  final dynamic minScale;
  final dynamic maxScale;
}

