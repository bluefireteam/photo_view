import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import './app_bar.dart';

class GalleryExample extends StatelessWidget {
  void open(BuildContext context, final int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryPhotoViewWrapper(
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black87,
                ),
                imageProvider: const AssetImage("assets/gallery1.jpeg"),
                imageProvider2: const AssetImage("assets/gallery2.jpeg"),
                imageProvider3: const AssetImage("assets/gallery3.jpeg"),
                index: index,
              ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ExampleAppBar(
            title: "Gallery Example",
            showGoBack: true,
          ),
          Expanded(
              child: Center(
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      open(context, 0);
                    },
                    child: Hero(
                      tag: "tag1",
                      child: Image.asset("assets/gallery1.jpeg", height: 80.0),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      open(context, 1);
                    },
                    child: Hero(
                      tag: "tag2",
                      child: Image.asset("assets/gallery2.jpeg", height: 80.0),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      open(context, 2);
                    },
                    child: Hero(
                      tag: "tag3",
                      child: Image.asset("assets/gallery3.jpeg", height: 80.0),
                    ),
                  )),
            ],
          ))),
        ],
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.imageProvider,
    this.imageProvider2,
    this.imageProvider3,
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.index,
  }) : pageController = PageController(initialPage: index);

  final ImageProvider imageProvider;
  final ImageProvider imageProvider2;
  final ImageProvider imageProvider3;
  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int index;
  final PageController pageController;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;
  @override
  void initState() {
    currentIndex = widget.index;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              PhotoViewGallery(
                pageOptions: <PhotoViewGalleryPageOptions>[
                  PhotoViewGalleryPageOptions(
                    imageProvider: widget.imageProvider,
                    heroTag: "tag1",
                  ),
                  PhotoViewGalleryPageOptions(
                      imageProvider: widget.imageProvider2,
                      heroTag: "tag2",
                      maxScale: PhotoViewComputedScale.contained * 0.3),
                  PhotoViewGalleryPageOptions(
                    imageProvider: widget.imageProvider3,
                    initialScale: PhotoViewComputedScale.contained * 0.8,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 1.1,
                    heroTag: "tag3",
                  ),
                ],
                loadingChild: widget.loadingChild,
                backgroundDecoration: widget.backgroundDecoration,
                pageController: widget.pageController,
                onPageChanged: onPageChanged,
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Image ${currentIndex + 1}",
                  style: const TextStyle(
                      color: Colors.white, fontSize: 17.0, decoration: null),
                ),
              )
            ],
          )),
    );
  }
}
