import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'skeleton.dart';
import 'curse_totem.dart';

/// Arma arremessada por Arthur (lanca/adaga). Voa em linha reta e some ao
/// atingir um inimigo, uma maldicao ou sair da tela.
class Projectile extends PositionComponent with CollisionCallbacks {
  Projectile({
    required Vector2 position,
    required this.direction,
  }) : super(position: position, size: Vector2(18, 6), anchor: Anchor.center);

  static const double _speed = 420;
  final double direction; // -1 esquerda, +1 direita

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += _speed * direction * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(3)),
      Paint()..color = const Color(0xFFE8C36B),
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Skeleton || other is CurseTotem) {
      removeFromParent();
    }
  }
}
