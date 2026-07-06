import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Um bloco solido do cenario (chao/plataforma). Serve de superficie para o
/// cavaleiro andar e pular.
class PlatformBlock extends PositionComponent with CollisionCallbacks {
  PlatformBlock({
    required Vector2 position,
    required Vector2 size,
    this.icy = false,
  }) : super(position: position, size: size);

  /// Quando a maldicao "Chao de Gelo" esta ativa, o cavaleiro derrapa.
  final bool icy;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = icy ? const Color(0xFF7FB4C9) : const Color(0xFF3A3350);
    canvas.drawRect(size.toRect(), paint);
    // borda superior para dar contraste de "topo do bloco"
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 4),
      Paint()..color = icy ? const Color(0xFFBFE6F2) : const Color(0xFF574F73),
    );
  }
}
