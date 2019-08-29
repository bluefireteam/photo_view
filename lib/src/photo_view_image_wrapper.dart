import 'package:flutter/widgets.dart';

import 'hero_attributes.dart';
import 'photo_view_controller.dart';
import 'photo_view_controller_delegate.dart';

typedef PhotoViewImageTapUpCallback = Function(BuildContext context,
    TapUpDetails details, PhotoViewControllerValue controllerValue);
typedef PhotoViewImageTapDownCallback = Function(BuildContext context,
    TapDownDetails details, PhotoViewControllerValue controllerValue);

/// Internal widget in which controls all animations lifecycles, core responses
/// to user gestures, updates to  the controller state and mounts the entire PhotoView Layout
class PhotoViewImageWrapper extends StatefulWidget {
  const PhotoViewImageWrapper({
    Key key,
    @required this.imageProvider,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    @required this.delegate,
  })  : customChild = null,
        super(key: key);

  const PhotoViewImageWrapper.customChild({
    Key key,
    @required this.customChild,
    this.backgroundDecoration,
    this.heroAttributes,
    this.enableRotation,
    this.onTapUp,
    this.onTapDown,
    @required this.delegate,
  })  : imageProvider = null,
        gaplessPlayback = false,
        super(key: key);

  final Decoration backgroundDecoration;
  final ImageProvider imageProvider;
  final bool gaplessPlayback;
  final HeroAttributes heroAttributes;
  final bool enableRotation;
  final Widget customChild;

  final PhotoViewControllerDelegate delegate;

  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;

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

  HeroAttributes get heroAttributes => widget.heroAttributes;

  PhotoViewControllerDelegate get delegate => widget.delegate;

  void handleScaleAnimation() {
    delegate.scale = _scaleAnimation.value;
  }

  void handlePositionAnimate() {
    delegate.controller.position = _positionAnimation.value;
  }

  void handleRotationAnimation() {
    delegate.controller.rotation = _rotationAnimation.value;
  }

  void onScaleStart(ScaleStartDetails details) {
    _rotationBefore = delegate.controller.rotation;
    _scaleBefore = delegate.scale;
    _normalizedPosition =
        details.focalPoint - delegate.controller.position;
    _scaleAnimationController.stop();
    _positionAnimationController.stop();
    _rotationAnimationController.stop();
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _scaleBefore * details.scale;
    final Offset delta = details.focalPoint - _normalizedPosition;

    delegate.updateScaleStateFromNewScale(details.scale, newScale);

    delegate.updateMultiple(
        scale: newScale,
        position: delegate.clampPosition(delta * details.scale),
        rotation: _rotationBefore + details.rotation,
        rotationFocusPoint: details.focalPoint);
  }

  void onScaleEnd(ScaleEndDetails details) {
    final double _scale = delegate.scale;
    final Offset _position = delegate.controller.position;
    final double maxScale = delegate.scaleBoundaries.maxScale;
    final double minScale = delegate.scaleBoundaries.minScale;

    //animate back to maxScale if gesture exceeded the maxScale specified
    if (_scale > maxScale) {
      final double scaleComebackRatio = maxScale / _scale;
      animateScale(_scale, maxScale);
      final Offset clampedPosition = delegate
          .clampPosition(_position * scaleComebackRatio, scale: maxScale);
      animatePosition(_position, clampedPosition);
      return;
    }

    //animate back to minScale if gesture fell smaller than the minScale specified
    if (_scale < minScale) {
      final double scaleComebackRatio = minScale / _scale;
      animateScale(_scale, minScale);
      animatePosition(
          _position,
          delegate
              .clampPosition(_position * scaleComebackRatio, scale: minScale));
      return;
    }
    // get magnitude from gesture velocity
    final double magnitude = details.velocity.pixelsPerSecond.distance;

    // animate velocity only if there is no scale change and a significant magnitude
    if (_scaleBefore / _scale == 1.0 && magnitude >= 400.0) {
      final Offset direction = details.velocity.pixelsPerSecond / magnitude;
      animatePosition(_position,
          delegate.clampPosition(_position + direction * 100.0));
    }

    delegate.checkAndSetToInitialScaleState();
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
      delegate.checkAndSetToInitialScaleState();
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
    delegate.startListeners();
    delegate.addAnimateOnScaleStateUpdate(animateOnScaleStateUpdate);
  }

  void animateOnScaleStateUpdate(double prevScale, double nextScale) {
    animateScale(prevScale, nextScale);
    animatePosition(delegate.controller.position, Offset.zero);
    animateRotation(delegate.controller.rotation, 0.0);
  }

  @override
  void dispose() {
    _scaleAnimationController.removeStatusListener(onAnimationStatus);
    _scaleAnimationController.dispose();
    _positionAnimationController.dispose();
    _rotationAnimationController.dispose();
    delegate.dispose();
    super.dispose();
  }

  void onTapUp(TapUpDetails details) {
    widget.onTapUp?.call(context, details, delegate.controller.value);
  }

  void onTapDown(TapDownDetails details) {
    widget.onTapDown?.call(context, details, delegate.controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: delegate.controller.outputStateStream,
        initialData: delegate.controller.prevValue,
        builder: (BuildContext context,
            AsyncSnapshot<PhotoViewControllerValue> snapshot) {
          if (snapshot.hasData) {
            final PhotoViewControllerValue value = snapshot.data;
            final matrix = Matrix4.identity()
              ..translate(value.position.dx, value.position.dy)
              ..scale(delegate.scale);

            final rotationMatrix = Matrix4.identity()..rotateZ(value.rotation);
            final Widget customChildLayout = CustomSingleChildLayout(
              delegate: _CenterWithOriginalSizeDelegate(
                  delegate.scaleBoundaries.childSize,
                  delegate.basePosition),
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
                  alignment: delegate.basePosition,
                )),
                decoration: widget.backgroundDecoration ??
                    const BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 1.0)),
              ),
              onDoubleTap: delegate.nextScaleState,
              onScaleStart: onScaleStart,
              onScaleUpdate: onScaleUpdate,
              onScaleEnd: onScaleEnd,
              onTapUp: onTapUp,
              onTapDown: onTapDown,
            );
          } else {
            return Container();
          }
        });
  }

  Widget _buildHero() {
    return heroAttributes != null
        ? Hero(
            tag: heroAttributes.tag,
            createRectTween: heroAttributes.createRectTween,
            flightShuttleBuilder: heroAttributes.flightShuttleBuilder,
            placeholderBuilder: heroAttributes.placeholderBuilder,
            transitionOnUserGestures: heroAttributes.transitionOnUserGestures,
            child: _buildChild(),
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
