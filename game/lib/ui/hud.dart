import 'package:flutter/material.dart';

import '../game/components/knight.dart';
import '../game/cursed_castle_game.dart';
import '../game/world/level_builder.dart';

/// Painel de informações sobreposto ao jogo: estágio, enigma/maldições,
/// estado da armadura e cronômetro.
class Hud extends StatelessWidget {
  const Hud({super.key, required this.game});

  final CursedCastleGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: game.stage,
                    builder: (_, s, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        s == 1
                            ? 'Estágio 1 — Pátio Amaldiçoado'
                            : 'Estágio 2 — Passagem Secreta',
                        style: const TextStyle(
                            color: Color(0xFFE8C36B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: game.stage,
                    builder: (_, s, __) =>
                        s == 1 ? _EnigmaClue(game: game) : _curseLine(),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: game.enemiesDefeated,
                    builder: (_, v, __) => _line(Icons.dangerous, 'Inimigos  $v'),
                  ),
                  ValueListenableBuilder<ArmorState>(
                    valueListenable: game.armor,
                    builder: (_, v, __) => _line(Icons.shield, _armorLabel(v)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _panel(
              child: ValueListenableBuilder<double>(
                valueListenable: game.elapsedSeconds,
                builder: (_, v, __) => Text(
                  _formatTime(v),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _curseLine() => ValueListenableBuilder<int>(
        valueListenable: game.cursesDestroyed,
        builder: (_, v, __) =>
            _line(Icons.auto_awesome, 'Maldições  $v/${game.challenge.totalCurses}'),
      );

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );

  Widget _line(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFE8C36B), size: 16),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      );

  static String _armorLabel(ArmorState s) => switch (s) {
        ArmorState.armored => 'Armadura: intacta',
        ArmorState.bare => 'Armadura: quebrada!',
        ArmorState.dead => 'Derrotado',
      };

  static String _formatTime(double seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$m:$s';
  }
}

/// Pista do enigma: mostra a ordem certa de acender os arcanos (por cor) e o
/// progresso. Quando resolvido, avisa que o portal abriu.
class _EnigmaClue extends StatelessWidget {
  const _EnigmaClue({required this.game});

  final CursedCastleGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.portalOpen,
      builder: (context, open, _) {
        if (open) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.door_front_door, color: Color(0xFF3AE1FF), size: 16),
                SizedBox(width: 6),
                Text('Portal aberto! Entre nele.',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          );
        }
        return ValueListenableBuilder<int>(
          valueListenable: game.puzzleProgress,
          builder: (context, progress, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Acenda na ordem: ',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                ...List.generate(game.requiredOrder.length, (i) {
                  final id = game.requiredOrder[i];
                  final done = i < progress;
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: brazierColors[id]
                          .withValues(alpha: done ? 1 : 0.35),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: done ? Colors.white : Colors.white24,
                        width: done ? 2 : 1,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
