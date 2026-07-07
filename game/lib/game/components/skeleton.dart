import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'fireball.dart';

/// Esqueleto inimigo. Anda de um lado para o outro dentro de um trecho e some
/// quando atingido por um projetil, somando ao placar.
class Skeleton extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  Skeleton({
    required Vector2 position,
    required this.patrolWidth,
    this.fast = false,
    this.tough = false,
  }) : super(position: position, size: Vector2(32, 44), anchor: Anchor.bottomLeft);

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
    final w = size.x;
    final h = size.y;
    const bone = Color(0xFFE8E2D0);
    const dark = Color(0xFF1B1030);

    // --- escudo (nas costas / lado esquerdo) ---
    final shieldC = Offset(w * 0.08, h * 0.55);
    canvas.drawCircle(shieldC, w * 0.26, Paint()..color = const Color(0xFF7A5230));
    canvas.drawCircle(shieldC, w * 0.26,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFC0A060));
    canvas.drawCircle(shieldC, 3, Paint()..color = const Color(0xFFC0A060));

    // --- espada (lado direito) ---
    canvas.drawRect(Rect.fromLTWH(w * 0.86, h * 0.18, w * 0.1, h * 0.5),
        Paint()..color = const Color(0xFFCFD6E0));
    canvas.drawRect(Rect.fromLTWH(w * 0.80, h * 0.66, w * 0.22, 3),
        Paint()..color = const Color(0xFFC0A060)); // guarda

    // --- caixa toracica / costelas ---
    final rib = Paint()..color = bone;
    canvas.drawRect(Rect.fromLTWH(w * 0.34, h * 0.42, w * 0.32, h * 0.34), rib);
    final ribLine = Paint()
      ..color = const Color(0xFF9A9483)
      ..strokeWidth = 2;
    for (var i = 0; i < 3; i++) {
      final y = h * (0.48 + i * 0.09);
      canvas.drawLine(Offset(w * 0.36, y), Offset(w * 0.64, y), ribLine);
    }

    // --- pernas ---
    canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.76, w * 0.08, h * 0.24), rib);
    canvas.drawRect(Rect.fromLTWH(w * 0.54, h * 0.76, w * 0.08, h * 0.24), rib);

    // --- cranio ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.36, h * 0.3), const Radius.circular(4)),
      Paint()..color = bone,
    );
    // olhos e nariz
    canvas.drawRect(Rect.fromLTWH(w * 0.38, h * 0.2, w * 0.08, h * 0.08), Paint()..color = dark);
    canvas.drawRect(Rect.fromLTWH(w * 0.54, h * 0.2, w * 0.08, h * 0.08), Paint()..color = dark);
    canvas.drawRect(Rect.fromLTWH(w * 0.47, h * 0.3, w * 0.06, h * 0.05), Paint()..color = dark);

    // --- elmo viking com chifres ---
    final helmet = Paint()..color = const Color(0xFF9AA0AA);
    canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.08, w * 0.4, h * 0.1), helmet);
    canvas.drawArc(Rect.fromLTWH(w * 0.3, h * 0.02, w * 0.4, h * 0.16), 3.14, 3.14, true, helmet);
    final horn = Paint()..color = const Color(0xFFE9E0C8);
    // chifre esquerdo
    final leftHorn = Path()
      ..moveTo(w * 0.3, h * 0.12)
      ..lineTo(w * 0.14, h * 0.02)
      ..lineTo(w * 0.28, h * 0.06)
      ..close();
    // chifre direito
    final rightHorn = Path()
      ..moveTo(w * 0.7, h * 0.12)
      ..lineTo(w * 0.86, h * 0.02)
      ..lineTo(w * 0.72, h * 0.06)
      ..close();
    canvas.drawPath(leftHorn, horn);
    canvas.drawPath(rightHorn, horn);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Fireball) {
      _hp--;
      if (_hp <= 0) {
        game.onEnemyDefeated();
        removeFromParent();
      }
    }
  }
}
