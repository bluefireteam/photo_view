import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_scale_boundaries.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/photo_view_utils.dart';

class PhotoViewImageWrapper extends StatefulWidget {
  const PhotoViewImageWrapper({
    Key key,
    @required this.setNextScaleState,
    @required this.onStartPanning,
    @required this.imageInfo,
    @required this.scaleState,
    @required this.scaleBoundaries,
    @required this.imageProvider,
    @required this.size,
    this.backgroundColor,
    this.gaplessPlayback = false,
    this.heroTag,
  }) : super(key: key);

  final Function setNextScaleState;
  final Function onStartPanning;
  final ImageInfo imageInfo;
  final PhotoViewScaleState scaleState;
  final Color backgroundColor;
  final ScaleBoundaries scaleBoundaries;
  final ImageProvider imageProvider;
  final bool gaplessPlayback;
  final Size size;
  final String heroTag;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewImageWrapperState();
  }
}

class _PhotoViewImageWrapperState extends State<PhotoViewImageWrapper>
    with TickerProviderStateMixin {
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
    _scaleBefore = scaleStateAwareScale();
    _normalizedPosition = details.focalPoint - _position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition;
    if (details.scale != 1.0) {
      widget.onStartPanning();
    }
    setState(() {
      _scale = newScale;
      _position = clampPosition(delta * details.scale);
    });
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double maxScale = widget.scaleBoundaries.computeMaxScale();
    final double minScale = widget.scaleBoundaries.computeMinScale();



    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition = clampPosition(_position * scaleComebackRatio, maxScale);
      animatePosition(_position, clampedPosition);
      computeNextScaleState();
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
          _position, clampPosition(_position * scaleComebackRatio, maxScale));
      computeNextScaleState();
      return;
    }
    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if(_scaleBefore / _scale == 1.0 && magnitude >= 400.0 ){
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition( _position, clampPosition(_position + direction * 100.0));
    }

  }

  Offset clampPosition(Offset offset, [double scale]) {
    final double _scale = scale ?? scaleStateAwareScale();
    final double x = offset.dx;
    final double y = offset.dy;
    final double computedWidth = widget.imageInfo.image.width * _scale;
    final double computedHeight = widget.imageInfo.image.height * _scale;
    final double screenWidth = widget.size.width;
    final double screenHeight = widget.size.height;
    final double screenHalfX = screenWidth / 2;
    final double screenHalfY = screenHeight / 2;

    final double computedX = screenWidth < computedWidth
        ? x.clamp(0 - (computedWidth / 2) + screenHalfX,
            computedWidth / 2 - screenHalfX)
        : 0.0;

    final double computedY = screenHeight < computedHeight
        ? y.clamp(0 - (computedHeight / 2) + screenHalfY,
            computedHeight / 2 - screenHalfY)
        : 0.0;

    return Offset(computedX, computedY);
  }

  double scaleStateAwareScale() {
    return _scale != null || widget.scaleState == PhotoViewScaleState.zooming
        ? _scale
        : getScaleForScaleState(
                imageInfo: widget.imageInfo,
                scaleState: widget.scaleState,
                size: widget.size)
            .clamp(widget.scaleBoundaries.computeMinScale(),
                widget.scaleBoundaries.computeMaxScale());
  }

  void animateScale(double from, double to) {
    _scaleAnimation = Tween<double>(
      begin: from,
      end: to,
    ).animate(_scaleAnimationController);
    _scaleAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

   void animatePosition(Offset from, Offset to) {
    _positionAnimation = Tween<Offset>(begin: from, end: to)
        .animate(_positionAnimationController);
    _positionAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  @override
  void initState() {
    super.initState();
    _position = Offset.zero;
    _scale = null;
    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);

    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(handlePositionAnimate);
  }

  @override
  void dispose() {
    _positionAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PhotoViewImageWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleState != widget.scaleState &&
        widget.scaleState != PhotoViewScaleState.zooming) {
      final double prevScale = _scale == null
          ? getScaleForScaleState(
                  imageInfo: widget.imageInfo,
                  scaleState: PhotoViewScaleState.contained,
                  size: widget.size)
              .clamp(widget.scaleBoundaries.computeMinScale(),
                  widget.scaleBoundaries.computeMaxScale())
          : _scale;

      final double nextScale = getScaleForScaleState(
              imageInfo: widget.imageInfo,
              scaleState: widget.scaleState,
              size: widget.size)
          .clamp(widget.scaleBoundaries.computeMinScale(),
              widget.scaleBoundaries.computeMaxScale());

      animateScale(prevScale, nextScale);
      animatePosition(_position, Offset.zero);
    }
  }

  void computeNextScaleState() {
    final PhotoViewScaleState _originalScaleState = widget.scaleState;

    if (_originalScaleState == PhotoViewScaleState.zooming) {
      widget.setNextScaleState(nextScaleState(_originalScaleState));
      return;
    }

    final double originalScale = getScaleForScaleState(
            imageInfo: widget.imageInfo,
            scaleState: _originalScaleState,
            size: widget.size)
        .clamp(widget.scaleBoundaries.computeMinScale(),
            widget.scaleBoundaries.computeMaxScale());

    double prevScale = originalScale;
    PhotoViewScaleState _prevScaleState = _originalScaleState;
    double nextScale = originalScale;
    PhotoViewScaleState _nextScaleState = _originalScaleState;
    do {
      prevScale = nextScale;
      _prevScaleState = _nextScaleState;
      _nextScaleState = nextScaleState(_prevScaleState);
      nextScale = getScaleForScaleState(
              imageInfo: widget.imageInfo,
              scaleState: _nextScaleState,
              size: widget.size)
          .clamp(widget.scaleBoundaries.computeMinScale(),
              widget.scaleBoundaries.computeMaxScale());
    } while (prevScale == nextScale && _originalScaleState != _nextScaleState);

    if (originalScale == nextScale) {
      return;
    }

    widget.setNextScaleState(_nextScaleState);
  }

  @override
  Widget build(BuildContext context) {
    final matrix = Matrix4.identity()
      ..translate(_position.dx, _position.dy)
      ..scale(scaleStateAwareScale());

    return GestureDetector(
      child: Container(
        child: Center(
            child: Transform(
          child: CustomSingleChildLayout(
            delegate: ImagePositionDelegate(widget.imageInfo.image.width / 1,
                widget.imageInfo.image.height / 1),
            child: _buildHero(),
          ),
          transform: matrix,
          alignment: Alignment.center,
        )),
        decoration: BoxDecoration(color: widget.backgroundColor),
      ),
      onDoubleTap: computeNextScaleState,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
    );
  }

  Widget _buildHero() {
    return widget.heroTag != null
        ? Hero(tag: widget.heroTag, child: _buildImage())
        : _buildImage();
  }

  Widget _buildImage() {
    return Image(
      image: widget.imageProvider,
      gaplessPlayback: widget.gaplessPlayback,
    );
  }
}

class ImagePositionDelegate extends SingleChildLayoutDelegate {
  final double imageWidth;
  final double imageHeight;
  const ImagePositionDelegate(this.imageWidth, this.imageHeight);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double offsetX = (size.width - imageWidth) / 2;
    final double offsetY = (size.height - imageHeight) / 2;
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
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
