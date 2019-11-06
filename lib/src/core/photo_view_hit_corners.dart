import 'package:flutter/widgets.dart';

import 'package:photo_view/src/controller/photo_view_controller_delegate.dart'
    show PhotoViewControllerDelegate;

mixin HitCornersDetector on PhotoViewControllerDelegate {
  HitAxis hitAxis() => HitAxis(hitCornersX(), hitCornersY());

  HitCorners hitCornersX() {
    final double childWidth = scaleBoundaries.childSize.width * scale;
    final double screenWidth = scaleBoundaries.outerSize.width;
    if (screenWidth >= childWidth) {
      return const HitCorners(true, true);
    }
    final x = -position.dx;
    final cornersX = this.cornersX();
    return HitCorners(x <= cornersX.min, x >= cornersX.max);
  }

  HitCorners hitCornersY() {
    final double childHeight = scaleBoundaries.childSize.height * scale;
    final double screenHeight = scaleBoundaries.outerSize.height;
    if (screenHeight >= childHeight) {
      return const HitCorners(true, true);
    }
    final y = -position.dy;
    final cornersY = this.cornersY();
    return HitCorners(y <= cornersY.min, y >= cornersY.max);
  }

  bool shouldMoveX(Offset move) {
    final hitCornersX = this.hitCornersX();

    if (hitCornersX.hasHitAny && move != Offset.zero) {
      if (hitCornersX.hasHitBoth) {
        return false;
      }
      if (hitCornersX.hasHitMax) {
        return move.dx < 0;
      }
      return move.dx > 0;
    }
    return true;
  }

  bool shouldMoveY(Offset move) {
    final hitCornersY = this.hitCornersY();
    if (hitCornersY.hasHitAny && move != Offset.zero) {
      if (hitCornersY.hasHitBoth) {
        return false;
      }
      if (hitCornersY.hasHitMax) {
        return move.dy > 0;
      }
      return move.dy < 0;
    }
    return true;
  }
}

class HitAxis {
  HitAxis(this.hasHitX, this.hasHitY);

  final HitCorners hasHitX;
  final HitCorners hasHitY;

  bool get hasHitAny => hasHitX.hasHitAny || hasHitY.hasHitAny;

  bool get hasHitBoth => hasHitX.hasHitBoth && hasHitY.hasHitBoth;
}

class HitCorners {
  const HitCorners(this.hasHitMin, this.hasHitMax);

  final bool hasHitMin;
  final bool hasHitMax;

  bool get hasHitAny => hasHitMin || hasHitMax;

  bool get hasHitBoth => hasHitMin && hasHitMax;
}
