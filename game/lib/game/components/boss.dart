import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../cursed_castle_game.dart';
import 'fireball.dart';

/// Chefão do estágio. Tem vida, patrulha a área final e machuca Arthur ao
/// encostar. No estágio 1 nasce "selado" (invulnerável) até o enigma dos
/// arcanos ser resolvido; o chefão final já nasce vulnerável.
class Boss extends PositionComponent
    with CollisionCallbacks, HasGameReference<CursedCastleGame> {
  Boss({
    required Vector2 position,
    required this.maxHp,
    required this.isFinal,
  }) : super(position: position, size: Vector2(76, 100), anchor: Anchor.bottomCenter);

  final int maxHp;
  final bool isFinal;

  late int hp = maxHp;
  late final double _minX = position.x - 70;
  late final double _maxX = position.x + 30;
  double _dir = -1;
  double _t = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
    position.x += 40 * _dir * dt;
    if (position.x <= _minX) _dir = 1;
    if (position.x >= _maxX) _dir = -1;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    if (isFinal) {
      _renderGhostKing(canvas, w, h);
    } else {
      _renderSkeletonLord(canvas, w, h);
    }
    // escudo mágico quando selado
    if (game.bossSealed.value) {
      canvas.drawOval(
        Rect.fromLTWH(-6, -6, w + 12, h + 12),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0x883AE1FF),
      );
    }
  }

  void _renderSkeletonLord(Canvas canvas, double w, double h) {
    const bone = Color(0xFFEDE7D5);
    const dark = Color(0xFF1B1030);
    // corpo/armadura
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.2, h * 0.4, w * 0.6, h * 0.5), const Radius.circular(6)),
      Paint()..color = const Color(0xFF5B2E2E),
    );
    // espadão
    canvas.drawRect(Rect.fromLTWH(w * 0.86, h * 0.15, w * 0.1, h * 0.6),
        Paint()..color = const Color(0xFFCFD6E0));
    // crânio
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, h * 0.12, w * 0.44, h * 0.32), const Radius.circular(6)),
      Paint()..color = bone,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.34, h * 0.22, w * 0.1, h * 0.08), Paint()..color = dark);
    canvas.drawRect(Rect.fromLTWH(w * 0.56, h * 0.22, w * 0.1, h * 0.08), Paint()..color = dark);
    // elmo viking com chifres
    final helmet = Paint()..color = const Color(0xFF8A9098);
    canvas.drawRect(Rect.fromLTWH(w * 0.26, h * 0.08, w * 0.48, h * 0.1), helmet);
    final horn = Paint()..color = bone;
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.26, h * 0.12)
          ..lineTo(w * 0.06, h * 0.0)
          ..lineTo(w * 0.24, h * 0.05)
          ..close(),
        horn);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.74, h * 0.12)
          ..lineTo(w * 0.94, h * 0.0)
          ..lineTo(w * 0.76, h * 0.05)
          ..close(),
        horn);
  }

  void _renderGhostKing(Canvas canvas, double w, double h) {
    final bob = math.sin(_t * 3) * 4;
    final body = Path()..addArc(Rect.fromLTWH(0, bob, w, h * 0.9), 3.14, 3.14);
    body.lineTo(w, h * 0.8 + bob);
    const waves = 5;
    for (var i = waves; i >= 0; i--) {
      final x = w * i / waves;
      final y = (i.isEven ? h * 0.8 : h * 0.92) + bob;
      body.lineTo(x, y);
    }
    body.close();
    canvas.drawPath(body, Paint()..color = const Color(0xDD9B6BFF));
    // olhos ameaçadores
    final glow = Paint()..color = const Color(0xFFFFE38A);
    canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.32 + bob, w * 0.14, h * 0.14), glow);
    canvas.drawOval(Rect.fromLTWH(w * 0.58, h * 0.32 + bob, w * 0.14, h * 0.14), glow);
    // coroa
    final crown = Paint()..color = const Color(0xFFE8C36B);
    canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.16 + bob, w * 0.4, h * 0.06), crown);
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
          Rect.fromLTWH(w * (0.32 + i * 0.16), h * 0.1 + bob, w * 0.06, h * 0.08), crown);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Fireball && !game.bossSealed.value) {
      hp--;
      game.onBossHit(hp);
      if (hp <= 0) {
        game.onBossDefeated();
        removeFromParent();
      }
    }
  }
}
