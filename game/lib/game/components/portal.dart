import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'knight.dart';

/// Portal / passagem secreta para o próximo estágio. Começa selado e só abre
/// quando o enigma dos arcanos é resolvido. Ao entrar nele, Arthur avança.
class Portal extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  Portal({required Vector2 position})
      : super(position: position, size: Vector2(56, 84), anchor: Anchor.bottomCenter);

  bool open = false;
  double _swirl = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _swirl += dt * (open ? 4 : 1);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, -size.y, size.x, size.y);
    final oval = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    if (!open) {
      // selado: pedra escura com runas apagadas
      canvas.drawRRect(oval, Paint()..color = const Color(0xFF241C3A));
      canvas.drawRRect(
        oval,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF3C325C),
      );
      return;
    }

    // aberto: vórtice brilhante
    final glow = 0.6 + 0.4 * math.sin(_swirl);
    canvas.drawRRect(
      oval,
      Paint()..color = Color.lerp(const Color(0xFF6A2CC0), const Color(0xFF3AE1FF), glow)!,
    );
    for (var i = 0; i < 3; i++) {
      final r = (size.x / 2 - 6) * (1 - i * 0.25);
      canvas.drawCircle(
        Offset(size.x / 2, -size.y / 2),
        r + math.sin(_swirl + i) * 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFE38A).withValues(alpha: 0.7),
      );
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (open && other is Knight) {
      game.enterPortal();
    }
  }
}
