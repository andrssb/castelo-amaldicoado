import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'fireball.dart';

/// Maldição em forma de fantasma. Destruí-la é objetivo secundário (pontos);
/// flutua e balança de leve.
class CurseTotem extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  CurseTotem({required Vector2 position})
      : super(position: position, size: Vector2(36, 46), anchor: Anchor.bottomCenter);

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
    final w = size.x;
    final h = size.y;
    final bob = math.sin(_pulse) * 3; // balanço suave

    final body = Path();
    // domo da cabeça
    body.addArc(Rect.fromLTWH(0, bob, w, h * 0.9), 3.14, 3.14);
    // laterais retas descendo
    body.lineTo(w, h * 0.78 + bob);
    // barra ondulada embaixo (cauda de fantasma)
    const waves = 4;
    for (var i = waves; i >= 0; i--) {
      final x = w * i / waves;
      final y = (i.isEven ? h * 0.78 : h * 0.9) + bob;
      body.lineTo(x, y);
    }
    body.close();

    canvas.drawPath(body, Paint()..color = const Color(0xCCB388FF));
    canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFE0CCFF));

    // olhos e boca sombrios
    final dark = Paint()..color = const Color(0xFF2A1240);
    canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.3 + bob, w * 0.12, h * 0.16), dark);
    canvas.drawOval(Rect.fromLTWH(w * 0.6, h * 0.3 + bob, w * 0.12, h * 0.16), dark);
    canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.52 + bob, w * 0.16, h * 0.12), dark);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Fireball) {
      game.onCurseDestroyed();
      removeFromParent();
    }
  }
}
