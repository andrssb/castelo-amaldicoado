import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'brazier.dart';
import 'curse_totem.dart';
import 'skeleton.dart';

/// Bola de fogo conjurada pela espada de Arthur. Voa em linha reta e some ao
/// atingir um inimigo, uma maldição, um arcano (para acendê-lo) ou sair da tela.
class Fireball extends PositionComponent with CollisionCallbacks {
  Fireball({
    required Vector2 position,
    required this.direction,
  }) : super(position: position, size: Vector2(22, 14), anchor: Anchor.center);

  static const double _speed = 430;
  final double direction; // -1 esquerda, +1 direita

  double _flicker = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += _speed * direction * dt;
    _flicker += dt * 30;
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    // rastro de brasa
    canvas.drawCircle(Offset(cx - direction * 8, cy),
        4 + math.sin(_flicker) * 1.5, Paint()..color = const Color(0x88FF6A00));
    // corpo laranja
    canvas.drawCircle(Offset(cx, cy), cy, Paint()..color = const Color(0xFFFF7A18));
    // núcleo amarelo
    canvas.drawCircle(Offset(cx + direction * 2, cy), cy - 4,
        Paint()..color = const Color(0xFFFFD65A));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Skeleton || other is CurseTotem || other is Brazier) {
      removeFromParent();
    }
  }
}
