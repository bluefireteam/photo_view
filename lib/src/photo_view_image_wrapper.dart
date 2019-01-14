import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_controller.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';

/// Internal widget in which controls the transformation values of the content
class PhotoViewImageWrapper extends StatefulWidget {
  const PhotoViewImageWrapper({
    Key key,
    @required this.controller,
    @required this.imageProvider,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.heroTag,
    this.enableRotation,
    this.transitionOnUserGestures = false,
  })  : customChild = null,
        super(key: key);

  const PhotoViewImageWrapper.customChild({
    Key key,
    @required this.controller,
    @required this.customChild,
    this.backgroundDecoration,
    this.heroTag,
    this.enableRotation,
    this.transitionOnUserGestures = false,
  })  : imageProvider = null,
        gaplessPlayback = false,
        super(key: key);

  final PhotoViewControllerBase controller;
  final Decoration backgroundDecoration;
  final ImageProvider imageProvider;
  final bool gaplessPlayback;
  final String heroTag;
  final bool enableRotation;
  final Widget customChild;
  final bool transitionOnUserGestures;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewImageWrapperState();
  }
}

class _PhotoViewImageWrapperState extends State<PhotoViewImageWrapper>
    with TickerProviderStateMixin {
  Offset _normalizedPosition;
  double _scaleBefore;
  double _rotationBefore;

  AnimationController _scaleAnimationController;
  Animation<double> _scaleAnimation;

  AnimationController _positionAnimationController;
  Animation<Offset> _positionAnimation;

  AnimationController _rotationAnimationController;
  Animation<double> _rotationAnimation;

  void handleScaleAnimation() {
    widget.controller.scale = _scaleAnimation.value;
  }

  void handlePositionAnimate() {
    widget.controller.position = _positionAnimation.value;
  }

  void handleRotationAnimation() {
    widget.controller.rotation = _rotationAnimation.value;
  }

  void onScaleStart(ScaleStartDetails details) {
    _rotationBefore = widget.controller.rotation;
    _scaleBefore = widget.controller.scale;
    _normalizedPosition = details.focalPoint - widget.controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition;
    if (details.scale != 1.0) {
      widget.controller.onStartZooming();
    }
    widget.controller.updateMultiple(
        scale: newScale,
        position: clampPosition(delta * details.scale),
        rotation: _rotationBefore + details.rotation,
        rotationFocusPoint: details.focalPoint);
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = widget.controller.scale;
    final Offset _position = widget.controller.position;
    final double maxScale = widget.controller.maxScale;
    final double minScale = widget.controller.minScale;

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition =
          clampPosition(_position * scaleComebackRatio, maxScale);
      animatePosition(_position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
          _position, clampPosition(_position * scaleComebackRatio, minScale));
      return;
    }
    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore / _scale == 1.0 && magnitude >= 400.0) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition(_position, clampPosition(_position + direction * 100.0));
    }

    checkAndSetToInitialScaleState();
  }

  Offset clampPosition(Offset offset, [double scale]) {
    final double _scale = scale ?? widget.controller.scaleStateAwareScale;
    final double x = offset.dx;
    final double y = offset.dy;
    final double computedWidth = widget.controller.childSize.width * _scale;
    final double computedHeight = widget.controller.childSize.height * _scale;
    final double screenWidth = widget.controller.outerSize.width;
    final double screenHeight = widget.controller.outerSize.height;
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

  void animateRotation(double from, double to) {
    _rotationAnimation = Tween<double>(begin: from, end: to)
        .animate(_rotationAnimationController);
    _rotationAnimationController
      ..value = 0.0
      ..fling(velocity: 0.4);
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      checkAndSetToInitialScaleState();
    }
  }

  void checkAndSetToInitialScaleState() {
    if (widget.controller.scaleState != PhotoViewScaleState.initial &&
        widget.controller.scaleStateAwareScale == widget.controller.initialScale) {
      widget.controller.scaleState = PhotoViewScaleState.initial;
    }
  }

  @override
  void initState() {
    super.initState();
    _scaleAnimationController = AnimationController(vsync: this)
      ..addListener(handleScaleAnimation);
    _scaleAnimationController.addStatusListener(onAnimationStatus);

    _positionAnimationController = AnimationController(vsync: this)
      ..addListener(handlePositionAnimate);

    _rotationAnimationController = AnimationController(vsync: this)
      ..addListener(handleRotationAnimation);
    
    widget.controller.addScaleStateListener(scaleStateListener);
  }

  void scaleStateListener(prevScale, nextScale) {
    animateScale(prevScale, nextScale);
    animatePosition(widget.controller.position, Offset.zero);
    animateRotation(widget.controller.rotation, 0.0);
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    widget.controller.removeScaleStateListener(scaleStateListener);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(valueListenable: widget.controller, builder:  (BuildContext context, PhotoViewControllerValue value, Widget child){
      final matrix = Matrix4.identity()
        ..translate(value.position.dx, value.position.dy)
        ..scale(widget.controller.scaleStateAwareScale);

      final rotationMatrix = Matrix4.identity()..rotateZ(value.rotation);

      final Widget customChildLayout = CustomSingleChildLayout(
        delegate: _CenterWithOriginalSizeDelegate(
            widget.controller.childSize.width, widget.controller.childSize.height),
        child: _buildHero(),
      );

      return GestureDetector(
        child: Container(
          child: Center(
              child: Transform(
                child: widget.enableRotation
                    ? Transform(
                  child: customChildLayout,
                  transform: rotationMatrix,
                  alignment: Alignment.center,
                  origin: value.rotationFocusPoint,
                )
                    : customChildLayout,
                transform: matrix,
                alignment: Alignment.center,
              )),
          decoration: widget.backgroundDecoration ??
              const BoxDecoration(color: const Color.fromRGBO(0, 0, 0, 1.0)),
        ),
        onDoubleTap: widget.controller.nextScaleState,
        onScaleStart: onScaleStart,
        onScaleUpdate: onScaleUpdate,
        onScaleEnd: onScaleEnd,
      );

    });
  }

  Widget _buildHero() {
    return widget.heroTag != null
        ? Hero(
            tag: widget.heroTag,
            child: _buildChild(),
            transitionOnUserGestures: widget.transitionOnUserGestures,
          )
        : _buildChild();
  }

  Widget _buildChild() {
    return widget.customChild == null
        ? Image(
            image: widget.imageProvider,
            gaplessPlayback: widget.gaplessPlayback,
          )
        : widget.customChild;
  }
}

class _CenterWithOriginalSizeDelegate extends SingleChildLayoutDelegate {
  const _CenterWithOriginalSizeDelegate(this.subjectWidth, this.subjectHeight);

  final double subjectWidth;
  final double subjectHeight;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double offsetX = (size.width - subjectWidth) / 2;
    final double offsetY = (size.height - subjectHeight) / 2;
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: subjectWidth,
      maxHeight: subjectHeight,
      minHeight: subjectHeight,
      minWidth: subjectWidth,
    );
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return true;
  }
}
