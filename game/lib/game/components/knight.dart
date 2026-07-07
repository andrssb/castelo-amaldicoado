import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cursed_castle_game.dart';
import 'boss.dart';
import 'platform_block.dart';
import 'fireball.dart';
import 'skeleton.dart';

/// Estado da armadura de Arthur, na tradicao do genero:
/// blindado -> sem armadura -> morto.
enum ArmorState { armored, bare, dead }

/// Arthur, o cavaleiro jogavel. Anda, tem pulo duplo, arremessa a arma e perde
/// a armadura ao tomar dano.
class Knight extends PositionComponent
    with CollisionCallbacks, KeyboardHandler, HasGameReference<CursedCastleGame> {
  Knight({required Vector2 position})
      : super(position: position, size: Vector2(28, 40), anchor: Anchor.topLeft);

  // --- fisica ---
  static const double _gravity = 980;
  static const double _moveSpeed = 165;
  static const double _jumpSpeed = 380;
  static const int _maxJumps = 2; // pulo duplo
  static const double _standHeight = 40;
  static const double _crouchHeight = 24;

  final Vector2 _velocity = Vector2.zero();
  double _horizontalInput = 0;
  int _jumpsLeft = _maxJumps;
  bool _grounded = false;
  bool _crouching = false;
  double _facing = 1;

  late final RectangleHitbox _hitbox;

  // --- combate / armadura ---
  ArmorState armor = ArmorState.armored;
  double _invulnerable = 0;
  double _throwCooldown = 0;

  @override
  Future<void> onLoad() async {
    _hitbox = RectangleHitbox(
      position: Vector2.zero(),
      size: Vector2(size.x, _standHeight),
      collisionType: CollisionType.active,
    );
    add(_hitbox);
  }

  /// Agachar/levantar: encolhe o corpo mantendo os pes no chao. So agacha no chao.
  void _setCrouch(bool value) {
    if (value == _crouching) return;
    _crouching = value;
    final newHeight = value ? _crouchHeight : _standHeight;
    final delta = size.y - newHeight; // positivo ao agachar
    position.y += delta; // desce o topo para o "pe" ficar no mesmo lugar
    size.y = newHeight;
    _hitbox.size.setValues(size.x, newHeight);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (armor == ArmorState.dead) return;

    _invulnerable = (_invulnerable - dt).clamp(0, 1);
    _throwCooldown = (_throwCooldown - dt).clamp(0, 1);

    // horizontal — no gelo, a mudanca de velocidade e suave (derrapa)
    final target = _horizontalInput * _moveSpeed;
    if (game.icyFloor && _grounded) {
      _velocity.x += (target - _velocity.x) * (2.5 * dt);
    } else {
      _velocity.x = target;
    }

    // gravidade
    _velocity.y += _gravity * dt;

    _grounded = false; // recalculado nas colisoes com plataformas
    position += _velocity * dt;

    if (_horizontalInput != 0) {
      _facing = _horizontalInput.sign;
    }

    // caiu do mapa
    if (position.y > game.levelHeight + 200) {
      game.onKnightDied();
    }
  }

  @override
  void render(Canvas canvas) {
    final blinking = _invulnerable > 0 && (_invulnerable * 20).floor().isEven;
    if (blinking) return;

    final w = size.x;
    final h = size.y;
    final armored = armor == ArmorState.armored;
    final dead = armor == ArmorState.dead;

    final armorColor = dead
        ? const Color(0xFF5A5A5A)
        : (armored ? const Color(0xFFB33A3A) : const Color(0xFF6E5A46));
    const skin = Color(0xFFE7C9A0);

    final headH = h * 0.30;
    final torsoH = h * 0.42;
    final legTop = headH + torsoH;

    // pernas
    final legPaint = Paint()..color = const Color(0xFF3A2E2E);
    canvas.drawRect(Rect.fromLTWH(w * 0.22, legTop, w * 0.22, h - legTop), legPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.56, legTop, w * 0.22, h - legTop), legPaint);

    // tronco (armadura)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.14, headH, w * 0.72, torsoH), const Radius.circular(3)),
      Paint()..color = armorColor,
    );
    if (armored) {
      // faixa dourada no peito
      canvas.drawRect(
          Rect.fromLTWH(w * 0.14, headH + torsoH * 0.4, w * 0.72, 3),
          Paint()..color = const Color(0xFFE8C36B));
    }

    // cabeca
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, 2, w * 0.44, headH), const Radius.circular(3)),
      Paint()..color = skin,
    );
    // olhos
    if (!dead) {
      final eye = Paint()..color = const Color(0xFF1B1030);
      final ex = _facing >= 0 ? w * 0.52 : w * 0.34;
      canvas.drawRect(Rect.fromLTWH(ex, headH * 0.5, 3, 3), eye);
    }

    // elmo dourado com penacho (so blindado)
    if (armored) {
      canvas.drawRect(Rect.fromLTWH(w * 0.26, 0, w * 0.48, headH * 0.42),
          Paint()..color = const Color(0xFFE8C36B));
      canvas.drawRect(Rect.fromLTWH(w * 0.46, -6, w * 0.08, 8),
          Paint()..color = const Color(0xFFD64545)); // penacho
    }

    // espada flamejante do lado para onde olha
    final swordX = _facing >= 0 ? w * 0.9 : -w * 0.12;
    final bladeRect = Rect.fromLTWH(swordX, headH * 0.6, w * 0.14, torsoH);
    canvas.drawRect(bladeRect, Paint()..color = const Color(0xFFCFD6E0)); // lâmina
    // chama na ponta
    canvas.drawCircle(Offset(bladeRect.center.dx, bladeRect.top - 2), 5,
        Paint()..color = const Color(0xFFFF7A18));
    canvas.drawCircle(Offset(bladeRect.center.dx, bladeRect.top - 2), 2.5,
        Paint()..color = const Color(0xFFFFD65A));
  }

  // ---------------------------------------------------------------------------
  // Entrada
  // ---------------------------------------------------------------------------
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (armor == ArmorState.dead) return false;

    final left = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    final right = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);
    final down = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS);

    // Agacha so quando esta no chao; ao agachar, nao anda.
    _setCrouch(down && _grounded);
    _horizontalInput = _crouching ? 0 : (right ? 1 : 0) - (left ? 1 : 0);

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyZ ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (!_crouching) _tryJump(); // nao pula agachado
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyX) {
        _castFire(); // agachado, o fogo já sai rente ao chão
        return true;
      }
    }
    return false;
  }

  void _tryJump() {
    if (_jumpsLeft > 0) {
      _velocity.y = -_jumpSpeed;
      _jumpsLeft--;
      _grounded = false;
    }
  }

  void _castFire() {
    if (_throwCooldown > 0) return;
    _throwCooldown = 0.35;
    final spawn = position + Vector2(size.x / 2, size.y / 2);
    parent?.add(Fireball(position: spawn, direction: _facing));
  }

  // ---------------------------------------------------------------------------
  // Colisoes
  // ---------------------------------------------------------------------------
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is PlatformBlock) {
      _resolvePlatform(other);
    } else if (other is Skeleton || other is Boss) {
      _takeDamage();
    }
  }

  /// Resolucao AABB simples: empurra o cavaleiro para fora do bloco pelo menor
  /// eixo de sobreposicao. Aterrissa ao bater por cima.
  void _resolvePlatform(PlatformBlock block) {
    final knightRect = toAbsoluteRect();
    final blockRect = block.toAbsoluteRect();

    final overlapLeft = knightRect.right - blockRect.left;
    final overlapRight = blockRect.right - knightRect.left;
    final overlapTop = knightRect.bottom - blockRect.top;
    final overlapBottom = blockRect.bottom - knightRect.top;

    final minX = overlapLeft < overlapRight ? overlapLeft : overlapRight;
    final minY = overlapTop < overlapBottom ? overlapTop : overlapBottom;

    if (minX < minY) {
      // colisao lateral
      position.x += overlapLeft < overlapRight ? -overlapLeft : overlapRight;
      _velocity.x = 0;
    } else if (overlapTop < overlapBottom) {
      // pousou no topo do bloco
      position.y -= overlapTop;
      _velocity.y = 0;
      _grounded = true;
      _jumpsLeft = _maxJumps;
    } else {
      // bateu a cabeca por baixo
      position.y += overlapBottom;
      _velocity.y = 0;
    }
  }

  void _takeDamage() {
    if (_invulnerable > 0) return;
    _invulnerable = 0.9;

    // "Armadura de Vidro": qualquer dano ja mata a armadura.
    if (armor == ArmorState.armored && !game.glassArmor) {
      armor = ArmorState.bare;
    } else if (armor == ArmorState.armored && game.glassArmor) {
      armor = ArmorState.dead;
    } else {
      armor = ArmorState.dead;
    }

    game.onKnightHit(armor);
    if (armor == ArmorState.dead) {
      _velocity.setZero();
      game.onKnightDied();
    }
  }
}
