import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'fireball.dart';

/// Arcano do enigma: um pilar mágico que se acende ao ser atingido pelo fogo.
/// O quebra-cabeça é acendê-los na ordem certa para abrir o portal.
class Brazier extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  Brazier({
    required Vector2 position,
    required this.id,
    required this.color,
  }) : super(position: position, size: Vector2(34, 54), anchor: Anchor.bottomCenter);

  /// Identificador (também a "cor" do enigma).
  final int id;
  final Color color;

  bool lit = false;
  double _pulse = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 6;
  }

  void light() => lit = true;
  void reset() => lit = false;

  @override
  void render(Canvas canvas) {
    final base = Rect.fromLTWH(0, -size.y, size.x, size.y);
    // pilar
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(6)),
      Paint()..color = lit ? color : const Color(0xFF2A2440),
    );
    // gema no topo
    final gemColor = lit ? color : color.withValues(alpha: 0.25);
    canvas.drawCircle(Offset(size.x / 2, -size.y + 12), 8, Paint()..color = gemColor);

    if (lit) {
      // chama por cima
      final h = 14 + math.sin(_pulse) * 4;
      final path = Path()
        ..moveTo(size.x / 2 - 8, -size.y + 6)
        ..lineTo(size.x / 2, -size.y + 6 - h)
        ..lineTo(size.x / 2 + 8, -size.y + 6)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xFFFFB020));
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Fireball && !lit) {
      game.onBrazierFired(this);
    }
  }
}
