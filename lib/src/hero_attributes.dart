import 'package:flutter/material.dart';

import 'photo_view_image_wrapper.dart';

/// Data class that holds the attributes that are going to be passed to
/// [PhotoViewImageWrapper]'s [Hero].
class HeroAttributes {
  const HeroAttributes({
    @required this.tag,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
  }) : assert(tag != null);

  /// Mirror to [Hero.tag]
  final Object tag;

  /// Mirror to [Hero.createRectTween]
  final CreateRectTween createRectTween;

  /// Mirror to [Hero.flightShuttleBuilder]
  final HeroFlightShuttleBuilder flightShuttleBuilder;

  /// Mirror to [Hero.placeholderBuilder]
  final HeroPlaceholderBuilder placeholderBuilder;

  /// Mirror to [Hero.transitionOnUserGestures]
  final bool transitionOnUserGestures;
}