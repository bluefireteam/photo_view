import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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

  @override
  void initState() {
    _controller = widget.pageController ?? PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      onPageChanged: widget.onPageChanged,
      itemBuilder: _buildItem
    );
  }

  Widget _buildItem (context, int index){
    final pageOption = widget.pageOptions[index];
    return PhotoViewInline(
      imageProvider: pageOption.imageProvider,
      loadingChild: widget.loadingChild,
      backgroundColor: widget.backgroundColor,
      minScale: pageOption.minScale,
      maxScale: pageOption.maxScale,
      gaplessPlayback: widget.gaplessPlayback,
      heroTag: pageOption.heroTag,
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

