
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_scale_type.dart';
import 'package:photo_view/photo_view_utils.dart';
import 'package:photo_view/rotation_gesture/gesture_detector.dart';
import 'package:photo_view/rotation_gesture/rotate_scale_gesture_recognizer.dart'
    as rotate;

class PhotoViewImageWrapper extends StatefulWidget {
  const PhotoViewImageWrapper(
      {Key key,
      @required this.onDoubleTap,
      @required this.onStartPanning,
      @required this.imageInfo,
      @required this.scaleType,
      this.backgroundColor,
      this.minScale,
      this.maxScale})
      : super(key: key);

  final Function onDoubleTap;
  final Function onStartPanning;
  final ImageInfo imageInfo;
  final PhotoViewScaleType scaleType;
  final Color backgroundColor;
  final double minScale;
  final double maxScale;

  @override
  State<StatefulWidget> createState() {
    return new _PhotoViewImageWrapperState();
  }
}

class _PhotoViewImageWrapperState extends State<PhotoViewImageWrapper>
    with TickerProviderStateMixin {
  Offset _position;
  Offset _normalizedPosition;
  double _scale;
  double _scaleBefore;
  double _rotation;
  double _rotationBefore;
  Offset _rotationFocusPoint;

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  AnimationController _positionAnimationController;
  Animation<Offset> _positionAnimation;

  AnimationController _rotationAnimationController;
  Animation<double> _rotationAnimation;

  void handleScaleAnimation() {
    setState(() {
      _scale = _scaleAnimation.value;
    });
  }

  void handlePositionAnimation() {
    setState(() {
      _position = _positionAnimation.value;
    });
  }

  void handleRotationAnimation() {
    setState(() {
      _rotation = _rotationAnimation.value;
    });
  }

  void onScaleStart(rotate.ScaleStartDetails details) {
    _rotationBefore = _rotation;
    _scaleBefore = scaleTypeAwareScale();
    _normalizedPosition = (details.focalPoint - _position);
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
    
  }

  void onScaleUpdate(rotate.ScaleUpdateDetails details) {
    final double newScale = (_scaleBefore * details.scale);
    final Offset delta = (details.focalPoint - _normalizedPosition);
    if (details.scale != 1.0) {
      widget.onStartPanning();
    }
    setState(() {
      _scale = newScale;
      _position = clampPosition(delta * details.scale);
      _rotation = _rotationBefore + details.rotation;
      _rotationFocusPoint= details.focalPoint;
    });
  }

  void onScaleEnd(rotate.ScaleEndDetails details) {
    //animate back to maxScale if gesture exceeded the maxscale specified
    if ((widget.maxScale != null) && (this._scale > widget.maxScale)) {
      double scaleComebackRatio = widget.maxScale / this._scale;
      print(scaleComebackRatio);

      animateScale(_scale, widget.maxScale);
      animatePosition(_position, clampPosition(_position * scaleComebackRatio));
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (widget.minScale != null && this._scale < widget.minScale) {
      double scaleComebackRatio = widget.minScale / this._scale;
      animateScale(_scale, widget.minScale);
      animatePosition(_position, clampPosition(_position * scaleComebackRatio));
    }
  }

  Offset clampPosition(Offset offset) {
    final x = offset.dx;
    final y = offset.dy;
    final computedWidth = widget.imageInfo.image.width * scaleTypeAwareScale();
    final computedHeight =
        widget.imageInfo.image.height * scaleTypeAwareScale();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenHalfX = screenWidth / 2;
    final screenHalfY = screenHeight / 2;

    final double computedX = screenWidth < computedWidth
        ? x.clamp(0 - (computedWidth / 2) + screenHalfX,
            computedWidth / 2 - screenHalfX)
        : 0.0;

    final double computedY = screenHeight < computedHeight
        ? y.clamp(0 - (computedHeight / 2) + screenHalfY,
            computedHeight / 2 - screenHalfY)
        : 0.0;

    return new Offset(computedX, computedY);
  }

  double scaleTypeAwareScale() {
    return _scale != null || widget.scaleType == PhotoViewScaleType.zooming
        ? _scale
        : getScaleForScaleType(
            imageInfo: widget.imageInfo,
            scaleType: widget.scaleType,
            size: MediaQuery.of(context).size);
  }

  void animateScale(double from, double to) {
    _scaleAnimation = new Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animatePosition(Offset from, Offset to) {
    _positionAnimation = new Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void animateRotation(double from, double to) {
    _rotationAnimation = new Tween<double>(begin: from, end: to)
        .animate(_rotationAnimationController);
    _rotationAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  @override
  void initState() {
    super.initState();
    _position = Offset.zero;
    _rotation = 0.0;
    _scale = null;
    _scaleAnimationController = new AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);

    _positionAnimationController = new AnimationController(vsync: this)
      ..addListener(handlePositionAnimation);

    _rotationAnimationController = new AnimationController(vsync: this)
      ..addListener(handleRotationAnimation);
  }

  @override
  void dispose() {
    _positionAnimationController.dispose();
    _scaleAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  void didUpdateWidget(PhotoViewImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleType != widget.scaleType &&
        widget.scaleType != PhotoViewScaleType.zooming) {
      animateScale(
          _scale == null
              ? getScaleForScaleType(
                  imageInfo: widget.imageInfo,
                  scaleType: PhotoViewScaleType.contained,
                  size: MediaQuery.of(context).size)
              : _scale,
          getScaleForScaleType(
              imageInfo: widget.imageInfo,
              scaleType: widget.scaleType,
              size: MediaQuery.of(context).size));
      animatePosition(_position, Offset.zero);
      animateRotation(_rotation, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    var matrix = new Matrix4.identity()
      ..translate(_position.dx, _position.dy)
      ..scale(scaleTypeAwareScale());

    var rotationMatrix = new Matrix4.identity()..rotateZ(_rotation);
    return new RotateGestureDetector(
      child: new Container(
        child: new Center(
          child: new Transform(
            child: new Transform(
              child: new CustomSingleChildLayout(
                delegate: new ImagePositionDelegate(
                    widget.imageInfo.image.width / 1,
                    widget.imageInfo.image.height / 1),
                child: new RawImage(
                  image: widget.imageInfo.image,
                  scale: widget.imageInfo.scale,
                ),
              ),
              transform: rotationMatrix,
              origin: _rotationFocusPoint,
            ),
            transform: matrix,
            alignment: Alignment.center,
          )
        ),
        decoration: new BoxDecoration(color: widget.backgroundColor),
      ),
      onDoubleTap: widget.onDoubleTap,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
    );
  }
}

class ImagePositionDelegate extends SingleChildLayoutDelegate {
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
