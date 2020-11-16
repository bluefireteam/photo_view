import 'package:flutter/material.dart';

import '../../photo_view.dart';

abstract class PhotoViewOptions {
  PhotoViewOptions.customChild({
    Key key,
    @required this.child,
    this.childSize,
    this.backgroundDecoration,
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
    this.disableGestures,
  })  : loadFailedChild = null,
        errorBuilder = null,
        imageProvider = null,
        gaplessPlayback = false,
        loadingBuilder = null;

  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final ImageErrorWidgetBuilder errorBuilder;
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
  final bool disableGestures;
}