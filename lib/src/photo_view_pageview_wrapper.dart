import 'dart:collection';
import 'package:flutter/material.dart';

/// This class wrap [PageView], use [GestureDetector] to detect touch event and decide which widget should move.
/// [PageViewWrapperController] is touch event handler, it will query [PageView] child move or not, if child can't move
/// it will use [PageController] to move [PageView]
class PageViewWrapper extends StatefulWidget {
  PageViewWrapper({@required this.pageView, @required this.controller});

  final PageView pageView;
  final PageViewWrapperController controller;

  @override
  _PageViewWrapperState createState() => _PageViewWrapperState();
}

class _PageViewWrapperState extends State<PageViewWrapper> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: widget.controller?.onDoubleTap,
      onScaleStart: widget.controller?.onScaleStart,
      onScaleUpdate: widget.controller?.onScaleUpdate,
      onScaleEnd: widget.controller?.onScaleEnd,
      child: NotificationListener<ScrollNotification>(
        child: IgnorePointer(child: widget.pageView),
        onNotification: (ScrollNotification notify) {
          if (notify.metrics.pixels <= notify.metrics.maxScrollExtent) {
            widget.controller?.onScrollUpdate(notify.metrics.pixels);
          }
          return false;
        },
      ),
    );
  }
}

abstract class GestureDetectorCallback {
  GestureDetectorCallback();

  void onDoubleTap();

  void onScaleStart(ScaleStartDetails detail);

  void onScaleUpdate(ScaleUpdateDetails detail);

  void onScaleEnd(ScaleEndDetails details);

  bool canMove(double scale, Offset delta);
}

///Touch event handler.
///It will dispatch event to PageView child and will move itself if needed.
class PageViewWrapperController implements GestureDetectorCallback {
  PageViewWrapperController(
      {this.pageViewController, this.onPageChangedWrapper}) {
    onPageChangedWrapper.addListener(onPageChange);
    _currentSelectPage = pageViewController.initialPage;
  }
  final String tag = 'PageViewGestureController';
  final bool verbose = true;
  final int durationMs = 400;
  final double pi = 3.14;
  final OnPageChangedWrapper onPageChangedWrapper;
  PageController pageViewController;
  double _lastScrollPixels;
  double _freshScrollPixels;
  ScaleStartDetails _scaleStartDetail;
  bool needNotifyChildEnd = false;
  Set<GestureDetectorCallback> childCallbacks =
      HashSet<GestureDetectorCallback>();
  Map<GestureDetectorCallback, bool> callbackStartMap = HashMap();
  Map<GestureDetectorCallback, int> callbackIntMap = HashMap();
  Offset _startPosition;
  Offset _lastDelta;
  int _currentSelectPage = 0;

  void onPageChange(int value) {
    _currentSelectPage = value;
    if(verbose){ debugPrint('$tag onPageChange $value'); }
  }

  void addChildGestureCallback(
      int index, GestureDetectorCallback childCallback) {
    if(verbose){ debugPrint('$tag addChildGestureCallback $index=>$childCallback'); }
    childCallbacks.add(childCallback);
    callbackIntMap[childCallback] = index;
  }

  void removeChildGestureCallback(
      int index, GestureDetectorCallback childCallback) {
    if(verbose){ debugPrint('$tag removeChildGestureCallback $index=>$childCallback'); }
    childCallbacks.remove(childCallback);
    callbackIntMap.remove(childCallback);
  }

  @override
  void onDoubleTap() {
    for (final callback in childCallbacks) {
      final callbackIndex = callbackIntMap[callback];
      if (callbackIndex != null && callbackIndex == _currentSelectPage) {
        callback.onDoubleTap();
      }
    }
  }

  @override
  void onScaleEnd(ScaleEndDetails details) {
    if(verbose){ debugPrint('$tag onScaleEnd'); }
    _startPosition = null;
    _scaleStartDetail = null;
    final direction = details.velocity.pixelsPerSecond.direction;
    final distance = details.velocity.pixelsPerSecond.distance;
    if (needNotifyChildEnd) {
      for (final callback in childCallbacks) {
        final callbackIndex = callbackIntMap[callback];
        if (callbackIndex != null && callbackIndex == _currentSelectPage) {
          final bool started = callbackStartMap[callback];
          if (started != null && started) {
            callback.onScaleEnd(details);
          }
        }
      }
      needNotifyChildEnd = false;
    } else {
      final ScrollPositionWithSingleContext scrollPosition =
          pageViewController.position;
      if (direction != 0 && distance != 0) {
        final bool firstQuadrant = direction >= -pi * 3 / 8 && direction <= 0;
        final bool secondQuadrant =
            direction >= -pi && direction <= -5 * pi / 8;
        final bool thirdQuadrant = direction >= 5 * pi / 8 && direction <= pi;
        final bool fourthQuadrant = direction > 0 && direction < pi * 3 / 8;
        if (firstQuadrant ||
            secondQuadrant ||
            thirdQuadrant ||
            fourthQuadrant) {
          if (secondQuadrant || thirdQuadrant) {
            //向左滑动
            scrollPosition
                .goBallistic(details.velocity.pixelsPerSecond.distance);
          } else {
            //向右滑动
            scrollPosition
                .goBallistic(-details.velocity.pixelsPerSecond.distance);
          }
        } else {
          animateToPage(scrollPosition);
        }
      } else {
        animateToPage(scrollPosition);
      }
    }
  }

  @override
  void onScaleStart(ScaleStartDetails detail) {
    if(verbose){ debugPrint('$tag onScaleStart $_startPosition'); }
    _startPosition = detail.focalPoint;
    _lastScrollPixels =
        pageViewController.position.pixels ?? _freshScrollPixels;
    _scaleStartDetail = detail;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail) {
    if (childCallbacks.isNotEmpty) {
      final Offset delta = detail.focalPoint - _startPosition;
      bool pageViewShouldMove = false;
      for (final callback in childCallbacks) {
        final callbackIndex = callbackIntMap[callback];
        if (callbackIndex != null && callbackIndex == _currentSelectPage) {
          if (needNotifyChildEnd) {
            callback.onScaleUpdate(detail);
//            if(verbose){ debugPrint('$tag child onScaleUpdate'); }
          } else {
            final bool childCanMove = callback.canMove(detail.scale, delta);
            if (childCanMove != null && childCanMove) {
              needNotifyChildEnd = true;
              callbackStartMap[callback] = childCanMove;
              callback.onScaleStart(_scaleStartDetail);
//              if(verbose){ debugPrint('$tag child onScaleStart'); }
            } else {
              pageViewShouldMove = true;
            }
          }
        }
      }

      if (pageViewShouldMove) {
//        if(verbose){ debugPrint('$tag move pageview 1'); }
        movePageViewSelf(detail);
      }
    } else {
//      if(verbose){ debugPrint('$tag move pageview 2'); }
      movePageViewSelf(detail);
    }
  }

  //scroll to next or pre page after finger up
  void animateToPage(ScrollPositionWithSingleContext scrollPosition) {
    final tail = pageViewController.page - pageViewController.page.floor();
    if (_lastDelta == null) {
      return;
    }

    if (_lastDelta.dx > 0) {
      //finger move right
      if (tail >= 0.5) {
        pageViewController.animateToPage(pageViewController.page.ceil(),
            curve: Curves.decelerate,
            duration: Duration(milliseconds: durationMs));
      } else {
        pageViewController
          ..animateToPage(pageViewController.page.floor(),
              curve: Curves.decelerate,
              duration: Duration(milliseconds: durationMs));
      }
    } else {
      //finger move left
      if (tail >= 0.5) {
        pageViewController
          ..animateToPage(pageViewController.page.ceil(),
              curve: Curves.decelerate,
              duration: Duration(milliseconds: durationMs));
      } else {
        pageViewController
          ..animateToPage(pageViewController.page.floor(),
              curve: Curves.decelerate,
              duration: Duration(milliseconds: durationMs));
      }
    }
  }

  void onScrollUpdate(double pixels) {
    _freshScrollPixels = pixels;
  }

  void movePageViewSelf(ScaleUpdateDetails detail) {
    final ScrollPositionWithSingleContext scrollPosition =
        pageViewController.position;
    if(verbose){
      debugPrint('$tag$hashCode movePageViewSelf _startPosition $_startPosition');
    }
    final Offset delta = detail.focalPoint - _startPosition;
    final value = _lastScrollPixels - delta.dx;
    _lastDelta = delta;
    scrollPosition.jumpToWithoutSettling(
        value.clamp(-0.0, scrollPosition.maxScrollExtent));
  }

  @override
  bool canMove(double scale, Offset delta) {
    return true;
  }
}

///dispatch onPageChanged to listeners
class OnPageChangedWrapper {
  final HashSet<ValueChanged<int>> _listeners = HashSet();

  void addListener(ValueChanged<int> listener) {
    _listeners.add(listener);
  }

  void removeListener(ValueChanged<int> listener) {
    _listeners.remove(listener);
  }

  void onPageChanged(int value) {
    for (final listener in _listeners) {
      listener(value);
    }
  }
}
