
import 'package:flutter/widgets.dart';

import 'package:photo_view/src/controller/photo_view_controller_delegate.dart' show PhotoViewControllerDelegate;

mixin HitCornersDetector on PhotoViewControllerDelegate {
  HitCorners get hasHitCorners => HitCorners(hasHitCornersX, hasHitCornersY);
  AxisHitCorners get hasHitCornersX {
    final double childWidth = scaleBoundaries.childSize.width * scale;
    final double screenWidth = scaleBoundaries.outerSize.width;
    if (screenWidth >= childWidth) {
      return const AxisHitCorners(true, true);
    }
    final x = position.dx;
    final cornersX = this.cornersX();
    return AxisHitCorners(x <= cornersX.min, x >= cornersX.max);
  }
  AxisHitCorners get hasHitCornersY {
    final double childHeight = scaleBoundaries.childSize.height * scale;
    final double screenHeight = scaleBoundaries.outerSize.height;
    if (screenHeight >= childHeight) {
      return const AxisHitCorners(true, true);
    }
    final y = position.dy;
    final cornersY = this.cornersY();
    return AxisHitCorners(y <= cornersY.min, y >= cornersY.max);
  }
  bool shouldMoveX(Offset move) {
    if(!hasHitCorners.hasHitAny || move == Offset.zero) {
      return true;
    }
    if(hasHitCornersX.hasHitAny) {
      if(hasHitCornersX.hasHitMax) {
        return move.dx > 0;
      }
      return move.dx < 0;
    }
    return true;
  }
  bool shouldMoveY(Offset move) {
    if(!hasHitCorners.hasHitAny || move == Offset.zero) {
      return true;
    }
    if(hasHitCornersY.hasHitAny) {
      if(hasHitCornersY.hasHitMax) {
        return move.dy > 0;
      }
      return move.dy < 0;
    }
    return true;
  }
}
class HitCorners {
  HitCorners(this.hasHitX, this.hasHitY);

  final AxisHitCorners hasHitX;
  final AxisHitCorners hasHitY;

  bool get hasHitAny => hasHitX.hasHitAny || hasHitY.hasHitAny;
}
class AxisHitCorners {
  const AxisHitCorners(this.hasHitMin, this.hasHitMax);
  final bool hasHitMin;
  final bool hasHitMax;
  bool get hasHitAny => hasHitMin || hasHitMax;
}
