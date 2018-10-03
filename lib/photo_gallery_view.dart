library photo_view;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_scale_state.dart';

export 'package:photo_view/photo_view_computed_scale.dart';

class PhotoGalleryView extends StatefulWidget {
  /// Creates a page view widget that displays an array of PhotoView widgets that are changed using swipe gestures.
 
  const PhotoGalleryView({
    Key key,
    @required this.imageProviders,
    this.spinnerColor = Colors.black,
  }) : super(key: key);


  final List<ImageProvider> imageProviders;
  final Color spinnerColor;

  @override
  State<StatefulWidget> createState() {
    return new _PhotoGalleryViewState();
  }
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  PhotoViewScaleState _scaleState;
  int _selectedIndex;
  PageController _pageController;

  GlobalKey containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
    _pageController = new PageController(initialPage: _selectedIndex);
  }

  void _handlePageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }

  Widget _buildImagePage(int index){
    return new Stack(
      children: <Widget>[
        new Center(
          child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(widget.spinnerColor),),
        ),
        new PhotoViewInline(
          imageProvider: widget.imageProviders[index],
          backgroundColor: Colors.transparent,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: 4.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new PageView.builder(
        itemCount: widget.imageProviders.length,
        controller: _pageController,
        onPageChanged: _handlePageChanged,
        itemBuilder: (BuildContext context, int index) {
          return _buildImagePage(index);
        }
      ),
    );
  }
}