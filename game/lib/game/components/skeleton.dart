import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'projectile.dart';

/// Esqueleto inimigo. Anda de um lado para o outro dentro de um trecho e some
/// quando atingido por um projetil, somando ao placar.
class Skeleton extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  Skeleton({
    required Vector2 position,
    required this.patrolWidth,
    this.fast = false,
    this.tough = false,
  }) : super(position: position, size: Vector2(26, 34), anchor: Anchor.bottomLeft);

  /// Largura do trecho patrulhado a partir da posicao inicial.
  final double patrolWidth;

  /// Maldicao "Furia dos Mortos": anda mais rapido.
  final bool fast;

  /// Maldicao "Lua de Sangue": aguenta dois acertos.
  final bool tough;

  late final double _minX = position.x;
  late final double _maxX = position.x + patrolWidth;
  double _direction = 1;
  int _hp = 1;

  @override
  Future<void> onLoad() async {
    _hp = tough ? 2 : 1;
    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final speed = fast ? 90.0 : 55.0;
    position.x += speed * _direction * dt;
    if (position.x <= _minX) {
      _direction = 1;
    } else if (position.x >= _maxX) {
      _direction = -1;
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, -size.y, size.x, size.y);
    canvas.drawRect(rect, Paint()..color = const Color(0xFFD9D2C3));
    // olhos
    final eye = Paint()..color = const Color(0xFF1B1030);
    canvas.drawRect(Rect.fromLTWH(6, -size.y + 8, 4, 4), eye);
    canvas.drawRect(Rect.fromLTWH(16, -size.y + 8, 4, 4), eye);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Projectile) {
      _hp--;
      if (_hp <= 0) {
        game.onEnemyDefeated();
        removeFromParent();
      }
    }
  }
}
