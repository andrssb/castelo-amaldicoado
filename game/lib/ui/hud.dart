import 'package:flutter/material.dart';

import '../game/components/knight.dart';
import '../game/cursed_castle_game.dart';

/// Painel de informacoes sobreposto ao jogo: progresso das maldicoes, inimigos,
/// estado da armadura e cronometro.
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
                    valueListenable: game.cursesDestroyed,
                    builder: (_, v, __) => _line(
                        Icons.auto_awesome, 'Maldicoes  $v/${game.challenge.totalCurses}'),
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

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
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
