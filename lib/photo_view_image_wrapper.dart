
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_scale_type.dart';
import 'package:photo_view/photo_view_utils.dart';

class PhotoViewImageWrapper extends StatefulWidget{
  const PhotoViewImageWrapper({
    Key key,
    @required this.onDoubleTap,
    @required this.onStartPanning,
    @required this.imageInfo,
    @required this.scaleType,
    this.backgroundColor,
  }) : super(key:key);

  final Function onDoubleTap;
  final Function onStartPanning;
  final ImageInfo imageInfo;
  final PhotoViewScaleType scaleType;
  final Color backgroundColor;

  @override
  State<StatefulWidget> createState() {
    return new _PhotoViewImageWrapperState();
  }
}


class _PhotoViewImageWrapperState extends State<PhotoViewImageWrapper> with TickerProviderStateMixin{
  Offset _position;
  Offset _normalizedPosition;
  double _scale;
  double _scaleBefore;

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  AnimationController _positionAnimationController;
  Animation<Offset> _positionAnimation;

  void handleScaleAnimation() {
    setState(() {
      _scale = _scaleAnimation.value;
    });
  }

  void handlePositionAnimate() {
    setState(() {
      _position = _positionAnimation.value;
    });
  }

  void onScaleStart(ScaleStartDetails details) {
    _scaleBefore = scaleTypeAwareScale();
    _normalizedPosition= (details.focalPoint - _position);
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = (_scaleBefore * details.scale);
    final Offset delta = (details.focalPoint - _normalizedPosition);
    if(details.scale != 1.0){
      widget.onStartPanning();
    }
    setState(() {
      _scale = newScale;
      _position = clampPosition(delta * (newScale / _scaleBefore));
    });
  }

  void onScaleEnd(ScaleEndDetails details) {
  }

  Offset clampPosition(Offset offset) {
    final x = offset.dx;
    final y = offset.dy;
    final computedWidth = widget.imageInfo.image.width * scaleTypeAwareScale();
    final computedHeight = widget.imageInfo.image.height * scaleTypeAwareScale();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenHalfX = screenWidth / 2;
    final screenHalfY = screenHeight / 2;

    final double computedX = screenWidth < computedWidth ? x.clamp(
        0 - (computedWidth / 2) + screenHalfX,
        computedWidth / 2 - screenHalfX
    ) : 0.0;

    final double computedY = screenHeight < computedHeight ? y.clamp(
        0 - (computedHeight / 2) + screenHalfY,
        computedHeight / 2 - screenHalfY
    ) : 0.0;

    return new Offset(
        computedX,
        computedY
    );
  }

  double scaleTypeAwareScale(){
    return _scale != null || widget.scaleType == PhotoViewScaleType.zooming
        ? _scale
        : getScaleForScaleType(
        imageInfo: widget.imageInfo,
        scaleType: widget.scaleType,
        size: MediaQuery.of(context).size
    );
  }

  @override
  void initState(){
    super.initState();
    _position = Offset.zero;
    _scale = null;
    _scaleAnimationController = new AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);

    _positionAnimationController = new AnimationController(vsync: this)
      ..addListener(handlePositionAnimate);
  }

  @override
  void dispose(){
    _positionAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void didUpdateWidget(PhotoViewImageWrapper oldWidget){
    super.didUpdateWidget(oldWidget);
    if(
    oldWidget.scaleType != widget.scaleType
        && widget.scaleType != PhotoViewScaleType.zooming
    ){
      _scaleAnimation = new Tween<double>(
        begin: _scale == null ? getScaleForScaleType(
            imageInfo: widget.imageInfo,
            scaleType: PhotoViewScaleType.contained,
            size: MediaQuery.of(context).size
        ) : _scale,
        end: getScaleForScaleType(
            imageInfo: widget.imageInfo,
            scaleType: widget.scaleType,
            size: MediaQuery.of(context).size
        ),
      ).animate(_scaleAnimationController);
      _scaleAnimationController
        ..value = 0.0
        ..fling(velocity: 0.4);

      _positionAnimation = new Tween<Offset>(
          begin: _position,
          end: Offset.zero
      ).animate(_positionAnimationController);
      _positionAnimationController
        ..value = 0.0
        ..fling(velocity: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    var matrix = new Matrix4.identity()
      ..translate(_position.dx, _position.dy)
      ..scale(scaleTypeAwareScale());

    return new GestureDetector(
      child: new Container(
        child: new Center(
            child: new Transform(
              child: new CustomSingleChildLayout(
                delegate: new ImagePositionDelegate(
                    widget.imageInfo.image.width /1,
                    widget.imageInfo.image.height /1
                ),
                child: new RawImage(
                  image: widget.imageInfo.image,
                  scale: widget.imageInfo.scale,
                ),
              ),
              transform: matrix,
              alignment: Alignment.center,
            )
        ),
        decoration: new BoxDecoration(
            color: widget.backgroundColor ?? new Color.fromRGBO(0, 0, 0, 1.0)
        ),
      ),
      onDoubleTap: widget.onDoubleTap,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
    );
  }
}


class ImagePositionDelegate extends SingleChildLayoutDelegate{
  final double imageWidth;
  final double imageHeight;
  const ImagePositionDelegate(this.imageWidth, this.imageHeight);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double offsetX = ((size.width - imageWidth) / 2);
    double offsetY = ((size.height - imageHeight) / 2);
    return new Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
      maxWidth: imageWidth,
      maxHeight: imageHeight,
      minHeight: imageHeight,
      minWidth: imageWidth,
    );
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return true;
  }
}