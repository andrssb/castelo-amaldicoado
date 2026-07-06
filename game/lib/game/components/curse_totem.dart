import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'projectile.dart';

/// Totem de maldicao. Destrui-lo e o objetivo da fase; cada um destruido conta
/// para o placar e para o progresso da run.
class CurseTotem extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  CurseTotem({required Vector2 position})
      : super(position: position, size: Vector2(30, 46), anchor: Anchor.bottomCenter);

  double _pulse = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    final glow = 0.5 + 0.5 * (1 + math.sin(_pulse)) / 2;
    final rect = Rect.fromLTWH(0, -size.y, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = Color.lerp(const Color(0xFF4B1E6B), const Color(0xFFB146E6), glow)!,
    );
    // "olho" da maldicao
    canvas.drawCircle(
      Offset(size.x / 2, -size.y / 2),
      6,
      Paint()..color = const Color(0xFFFFE38A),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Projectile) {
      game.onCurseDestroyed();
      removeFromParent();
    }
  }
}
