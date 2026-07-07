import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../api/models.dart';
import '../components/boss.dart';
import '../components/brazier.dart';
import '../components/curse_totem.dart';
import '../components/platform_block.dart';
import '../components/portal.dart';
import '../components/skeleton.dart';

/// Cores dos arcanos do enigma (também servem de "pista" na HUD).
const List<Color> brazierColors = [
  Color(0xFF4FA3FF), // azul
  Color(0xFF5AD17A), // verde
  Color(0xFFB146E6), // roxo
];

/// Resultado da montagem de uma fase.
class LevelLayout {
  LevelLayout({
    required this.components,
    required this.braziers,
    required this.portal,
    required this.boss,
    required this.knightStart,
    required this.width,
    required this.height,
  });

  final List<PositionComponent> components;
  final List<Brazier> braziers;
  final Portal? portal;
  final Boss? boss;
  final Vector2 knightStart;
  final double width;
  final double height;
}

/// Monta a fase do estágio pedido.
///
/// - Estágio 1 (Pátio Amaldiçoado): tem o enigma dos arcanos e o portal selado.
/// - Estágio 2 (Passagem Secreta): tem os totens de maldição a destruir.
class LevelBuilder {
  static const double _tile = 40;
  static const double groundY = 520;

  LevelLayout build(DailyChallenge challenge, int stage) {
    final rng = Random(challenge.seed + stage * 7919);
    final icy = challenge.hasCurse('ICE_FLOOR');
    final fast = challenge.hasCurse('FRENZY');
    final tough = challenge.hasCurse('BLOOD_MOON');

    final components = <PositionComponent>[];

    // --- chão com alguns buracos ---
    const segments = 14;
    double x = 0;
    for (var i = 0; i < segments; i++) {
      final gap = i > 1 && rng.nextDouble() < 0.2;
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

    // --- plataformas flutuantes ---
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

    // --- inimigos: divididos entre os estágios ---
    final stage1Enemies = min(6, challenge.totalEnemies);
    final enemyCount = stage == 1 ? stage1Enemies : challenge.totalEnemies - stage1Enemies;
    for (var i = 0; i < enemyCount; i++) {
      final px = _tile * 5 + rng.nextDouble() * (levelWidth - _tile * 7);
      components.add(Skeleton(
        position: Vector2(px, groundY),
        patrolWidth: _tile * (1 + rng.nextInt(3)),
        fast: fast,
        tough: tough,
      ));
    }

    final braziers = <Brazier>[];
    Portal? portal;
    Boss boss;

    if (stage == 1) {
      // três arcanos espaçados pelo pátio
      for (var i = 0; i < 3; i++) {
        final px = levelWidth * (0.3 + i * 0.2);
        braziers.add(Brazier(
          position: Vector2(px, groundY),
          id: i,
          color: brazierColors[i],
        ));
      }
      components.addAll(braziers);

      // chefão guardião perto do fim (selado até o enigma)
      boss = Boss(position: Vector2(levelWidth - _tile * 5, groundY), maxHp: 6, isFinal: false);
      // portal selado logo atrás do chefão
      portal = Portal(position: Vector2(levelWidth - _tile * 2, groundY));
      components.add(portal);
    } else {
      // estágio 2: fantasmas rondando
      for (var i = 0; i < challenge.totalCurses; i++) {
        final px = _tile * 6 + rng.nextDouble() * (levelWidth - _tile * 8);
        components.add(CurseTotem(position: Vector2(px, groundY - _tile)));
      }
      // chefão final
      boss = Boss(position: Vector2(levelWidth - _tile * 4, groundY), maxHp: 10, isFinal: true);
    }
    components.add(boss);

    return LevelLayout(
      components: components,
      braziers: braziers,
      portal: portal,
      boss: boss,
      knightStart: Vector2(_tile, groundY - _tile * 3),
      width: levelWidth,
      height: groundY + _tile * 3,
    );
  }
}
