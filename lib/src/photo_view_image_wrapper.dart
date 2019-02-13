import 'package:flutter/material.dart';
import 'package:photo_view/src/photo_view_controller.dart';
import 'package:photo_view/src/photo_view_scale_state.dart';
import 'package:photo_view/src/photo_view_typedefs.dart';
import 'package:photo_view/src/photo_view_utils.dart';

/// Internal widget in which controls all animations lifecycles, core responses to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
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
    @required this.scaleBoundaries,
    @required this.basePosition,
    @required this.scaleStateCycle,
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
    @required this.scaleBoundaries,
    @required this.basePosition,
    @required this.scaleStateCycle,
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
  final ScaleBoundaries scaleBoundaries;
  final Alignment basePosition;
  final ScaleStateCycle scaleStateCycle;

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

  double get scaleStateAwareScale {
    return widget.controller.scale ??
        getScaleForScaleState(
            widget.controller.scaleState, widget.scaleBoundaries);
  }

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
    _scaleBefore = scaleStateAwareScale;
    _normalizedPosition = details.focalPoint - widget.controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition;
    if (details.scale != 1.0) {
      widget.controller.scaleState = PhotoViewScaleState.zooming;
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
    final double maxScale = widget.scaleBoundaries.maxScale;
    final double minScale = widget.scaleBoundaries.minScale;

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
    final double _scale = scale ?? scaleStateAwareScale;
    final double x = offset.dx;
    final double y = offset.dy;

    final double computedWidth =
        widget.scaleBoundaries.childSize.width * _scale;
    final double computedHeight =
        widget.scaleBoundaries.childSize.height * _scale;

    final double screenWidth = widget.scaleBoundaries.outerSize.width;
    final double screenHeight = widget.scaleBoundaries.outerSize.height;

    final double positionX = widget.basePosition.x;
    final double positionY = widget.basePosition.y;

    final double widthDiff = computedWidth - screenWidth;
    final double heightDiff = computedHeight - screenHeight;

    final double minX = ((positionX - 1).abs() / 2) * widthDiff * -1;
    final double maxX = ((positionX + 1).abs() / 2) * widthDiff;

    final double minY = ((positionY - 1).abs() / 2) * heightDiff * -1;
    final double maxY = ((positionY + 1).abs() / 2) * heightDiff;

    final double computedX =
        screenWidth < computedWidth ? x.clamp(minX, maxX) : 0.0;

    final double computedY =
        screenHeight < computedHeight ? y.clamp(minY, maxY) : 0.0;

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
        scaleStateAwareScale == widget.scaleBoundaries.initialScale) {
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

    widget.controller.outputStateStream.listen(scaleStateListener);
  }

  void scaleStateListener(PhotoViewControllerValue value) {
    if (widget.controller.prevValue.scaleState !=
            widget.controller.scaleState &&
        widget.controller.scaleState != PhotoViewScaleState.zooming) {
      final double prevScale = widget.controller.scale ??
          getScaleForScaleState(
              PhotoViewScaleState.initial, widget.scaleBoundaries);

      final double nextScale = getScaleForScaleState(
          widget.controller.scaleState, widget.scaleBoundaries);

      animateScale(prevScale, nextScale);
      animatePosition(widget.controller.position, Offset.zero);
      animateRotation(widget.controller.rotation, 0.0);
    }
  }

  void nextScaleState() {
    final ScaleBoundaries scaleBoundaries = widget.scaleBoundaries;
    final PhotoViewControllerBase controller = widget.controller;
    final PhotoViewScaleState scaleState = controller.scaleState;
    if (scaleState == PhotoViewScaleState.zooming) {
      controller.scaleState = widget.scaleStateCycle(scaleState);
      return;
    }

    final double originalScale =
        getScaleForScaleState(scaleState, scaleBoundaries);

    double prevScale = originalScale;
    PhotoViewScaleState prevScaleState = scaleState;
    double nextScale = originalScale;
    PhotoViewScaleState nextScaleState = scaleState;

    do {
      prevScale = nextScale;
      prevScaleState = nextScaleState;
      nextScaleState = widget.scaleStateCycle(prevScaleState);
      nextScale = getScaleForScaleState(nextScaleState, scaleBoundaries);
    } while (prevScale == nextScale && scaleState != nextScaleState);

    if (originalScale == nextScale) {
      return;
    }
    controller.scaleState = nextScaleState;
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.controller.outputStateStream,
        initialData: widget.controller.prevValue,
        builder: (BuildContext context,
            AsyncSnapshot<PhotoViewControllerValue> snapshot) {
          if (snapshot.hasData) {
            final PhotoViewControllerValue value = snapshot.data;
            final matrix = Matrix4.identity()
              ..translate(value.position.dx, value.position.dy)
              ..scale(scaleStateAwareScale);

            final rotationMatrix = Matrix4.identity()..rotateZ(value.rotation);
            final Widget customChildLayout = CustomSingleChildLayout(
              delegate: _CenterWithOriginalSizeDelegate(
                  widget.scaleBoundaries.childSize, widget.basePosition),
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
                  alignment: widget.basePosition,
                )),
                decoration: widget.backgroundDecoration ??
                    const BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 1.0)),
              ),
              onDoubleTap: nextScaleState,
              onScaleStart: onScaleStart,
              onScaleUpdate: onScaleUpdate,
              onScaleEnd: onScaleEnd,
            );
          } else {
            return Container();
          }
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
  const _CenterWithOriginalSizeDelegate(this.subjectSize, this.basePosition);

  final Size subjectSize;
  final Alignment basePosition;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double offsetX =
        ((size.width - subjectSize.width) / 2) * (basePosition.x + 1);
    final double offsetY =
        ((size.height - subjectSize.height) / 2) * (basePosition.y + 1);
    return Offset(offsetX, offsetY);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: subjectSize.width,
      maxHeight: subjectSize.height,
      minHeight: subjectSize.height,
      minWidth: subjectSize.width,
    );
  }

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return true;
  }
}
