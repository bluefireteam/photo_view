import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewSwipe extends StatefulWidget {
  PhotoViewSwipe({
    Key key,
    @required this.imageProvider,
    this.dragBgColor, // default Colors.black.withOpacity(0.5)
    this.dragDistance, // default 160
    this.photoBackground, // deafult Colors.black

    // Standard photo_view
    this.loadingBuilder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
  })  : child = null,
        childSize = null,
        super(key: key);

  final ImageProvider imageProvider;
  final Color dragBgColor;
  final double dragDistance;
  final Color photoBackground;

  // Standard photo_view
  final LoadingBuilder loadingBuilder;
  final Widget loadFailedChild;
  final Decoration backgroundDecoration;
  final bool gaplessPlayback;
  final PhotoViewHeroAttributes heroAttributes;
  final Size customSize;
  final ValueChanged<PhotoViewScaleState> scaleStateChangedCallback;
  final bool enableRotation;
  final Widget child;
  final Size childSize;
  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;
  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final Alignment basePosition;
  final ScaleStateCycle scaleStateCycle;
  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;
  final HitTestBehavior gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;

  @override
  _PhotoViewSwipeState createState() => _PhotoViewSwipeState();
}

class _PhotoViewSwipeState extends State<PhotoViewSwipe> {
  Offset _position = Offset(0.0, 0.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.dragBgColor ?? Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() =>
                    _position = Offset(0.0, _position.dy + details.delta.dy));
              },
              onVerticalDragEnd: (details) {
                double pixelsPerSecond = _position.dy.abs();
                if (pixelsPerSecond > (widget.dragDistance ?? 160)) {
                  Navigator.pop(context);
                } else {
                  setState(() => _position = Offset(0.0, 0.0));
                }
              },
              child: Container(
                decoration: _position.dy == 0.0
                    ? BoxDecoration(
                        color: (widget.photoBackground ?? Colors.black),
                      )
                    : null,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: PhotoView(
                  imageProvider: widget.imageProvider,
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                  loadingBuilder: widget.loadingBuilder,
                  loadFailedChild: widget.loadFailedChild,
                  gaplessPlayback: widget.gaplessPlayback,
                  heroAttributes: widget.heroAttributes,
                  scaleStateChangedCallback: widget.scaleStateChangedCallback,
                  enableRotation: widget.enableRotation,
                  controller: widget.controller,
                  scaleStateController: widget.scaleStateController,
                  maxScale: widget.maxScale,
                  minScale: widget.minScale,
                  initialScale: widget.initialScale,
                  basePosition: widget.basePosition,
                  scaleStateCycle: widget.scaleStateCycle,
                  onTapUp: widget.onTapUp,
                  onTapDown: widget.onTapDown,
                  customSize: widget.customSize,
                  gestureDetectorBehavior: widget.gestureDetectorBehavior,
                  tightMode: widget.tightMode,
                  filterQuality: widget.filterQuality,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
