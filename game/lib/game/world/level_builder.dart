import 'dart:math';

import 'package:flame/components.dart';

import '../../api/models.dart';
import '../components/curse_totem.dart';
import '../components/platform_block.dart';
import '../components/skeleton.dart';

/// Resultado da montagem de uma fase.
class LevelLayout {
  LevelLayout({
    required this.components,
    required this.knightStart,
    required this.width,
    required this.height,
  });

  final List<PositionComponent> components;
  final Vector2 knightStart;
  final double width;
  final double height;
}

/// Monta a fase a partir do desafio do dia. Usa a mesma seed do servidor para o
/// leiaute (posicoes), enquanto as QUANTIDADES (inimigos/totens) vem prontas do
/// servidor — assim o cliente nunca gera mais do que o anti-cheat permite.
class LevelBuilder {
  static const double _tile = 40;
  static const double groundY = 520;

  LevelLayout build(DailyChallenge challenge) {
    final rng = Random(challenge.seed);
    final icy = challenge.hasCurse('ICE_FLOOR');
    final fast = challenge.hasCurse('FRENZY');
    final tough = challenge.hasCurse('BLOOD_MOON');

    final components = <PositionComponent>[];

    // segmentos de chao com alguns buracos
    const segments = 14;
    double x = 0;
    for (var i = 0; i < segments; i++) {
      final gap = i > 1 && rng.nextDouble() < 0.22;
      final segWidth = _tile * (3 + rng.nextInt(3));
      if (!gap) {
        components.add(PlatformBlock(
          position: Vector2(x, groundY),
          size: Vector2(segWidth, _tile * 3),
          icy: icy,
        ));
      }
      x += segWidth;
    }
    final levelWidth = x;

    // plataformas flutuantes
    final floating = 5 + rng.nextInt(4);
    for (var i = 0; i < floating; i++) {
      final px = _tile * 3 + rng.nextDouble() * (levelWidth - _tile * 6);
      final py = groundY - _tile * (2 + rng.nextInt(3));
      components.add(PlatformBlock(
        position: Vector2(px, py),
        size: Vector2(_tile * (2 + rng.nextInt(2)), _tile / 2),
        icy: icy,
      ));
    }

    // inimigos — QUANTIDADE definida pelo servidor
    for (var i = 0; i < challenge.totalEnemies; i++) {
      final px = _tile * 4 + rng.nextDouble() * (levelWidth - _tile * 6);
      components.add(Skeleton(
        position: Vector2(px, groundY),
        patrolWidth: _tile * (1 + rng.nextInt(3)),
        fast: fast,
        tough: tough,
      ));
    }

    // totens de maldicao — QUANTIDADE definida pelo servidor
    for (var i = 0; i < challenge.totalCurses; i++) {
      final px = _tile * 6 + rng.nextDouble() * (levelWidth - _tile * 8);
      components.add(CurseTotem(position: Vector2(px, groundY)));
    }

    return LevelLayout(
      components: components,
      knightStart: Vector2(_tile, groundY - _tile * 3),
      width: levelWidth,
      height: groundY + _tile * 3,
    );
  }
}
