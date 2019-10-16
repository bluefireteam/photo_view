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
class PageViewWrapperController {
  PageViewWrapperController(
      {this.pageViewController, this.onPageChangedWrapper, this.itemCount}) {
    _callbackList = List(itemCount);
    onPageChangedWrapper.addListener(() {
      onPageChange(onPageChangedWrapper.currentPage);
    });
    _currentSelectPage = pageViewController.initialPage;
  }

  final int durationMs = 400;
  final double pi = 3.14;
  final OnPageChangedWrapper onPageChangedWrapper;
  final int itemCount;
  PageController pageViewController;
  double _lastScrollPixels;
  double _freshScrollPixels;
  ScaleStartDetails _scaleStartDetail;
  bool needNotifyChildEnd = false;
  List<GestureDetectorCallback> _callbackList;
  Offset _startPosition;
  Offset _lastDelta;
  int _currentSelectPage = 0;

  void onPageChange(int value) {
    _currentSelectPage = value;
  }

  void addChildGestureCallback(
      int index, GestureDetectorCallback childCallback) {
    _callbackList[index] = childCallback;
  }

  void removeChildGestureCallback(
      int index, GestureDetectorCallback childCallback) {
    assert(_callbackList[index] == childCallback);
    _callbackList[index] = null;
  }

  void onDoubleTap() {
    _callbackList[_currentSelectPage]?.onDoubleTap();
  }

  void onScaleEnd(ScaleEndDetails details) {
    _startPosition = null;
    _scaleStartDetail = null;
    final direction = details.velocity.pixelsPerSecond.direction;
    final distance = details.velocity.pixelsPerSecond.distance;
    if (needNotifyChildEnd) {
      _callbackList[_currentSelectPage].onScaleEnd(details);
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

  void onScaleStart(ScaleStartDetails detail) {
    _startPosition = detail.focalPoint;
    _lastScrollPixels =
        pageViewController.position.pixels ?? _freshScrollPixels;
    _scaleStartDetail = detail;
  }

  void onScaleUpdate(ScaleUpdateDetails detail) {
    if (_callbackList.isNotEmpty) {
      final Offset delta = detail.focalPoint - _startPosition;
      bool pageViewShouldMove = false;
      final GestureDetectorCallback currentCallback =
          _callbackList[_currentSelectPage];
      if (currentCallback != null) {
        if (needNotifyChildEnd) {
          currentCallback.onScaleUpdate(detail);
        } else {
          final bool childCanMove =
              currentCallback.canMove(detail.scale, delta);
          if (childCanMove != null && childCanMove) {
            needNotifyChildEnd = true;
            currentCallback.onScaleStart(_scaleStartDetail);
          } else {
            pageViewShouldMove = true;
          }
        }
      }

      if (pageViewShouldMove) {
        movePageViewSelf(detail);
      }
    } else {
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
    final Offset delta = detail.focalPoint - _startPosition;
    final value = _lastScrollPixels - delta.dx;
    _lastDelta = delta;
    scrollPosition.jumpTo(value.clamp(-0.0, scrollPosition.maxScrollExtent));
  }
}

///dispatch onPageChanged to listeners
class OnPageChangedWrapper extends ChangeNotifier {
  int currentPage;

  void onPageChanged(int value) {
    if (currentPage != value) {
      currentPage = value;
      notifyListeners();
    }
  }
}
