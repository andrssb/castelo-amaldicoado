import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'api/game_api.dart';
import 'api/models.dart';
import 'game/cursed_castle_game.dart';
import 'ui/hud.dart';

void main() {
  runApp(const CursedCastleApp());
}

class CursedCastleApp extends StatelessWidget {
  const CursedCastleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cursed Castle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E20),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8C36B),
          secondary: Color(0xFFB146E6),
        ),
      ),
      home: const MenuScreen(),
    );
  }
}

/// Menu inicial: busca o desafio do dia, mostra as maldicoes e coleta o nome.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GameApi _api = GameApi();
  final TextEditingController _name = TextEditingController(text: 'Arthur');
  DailyChallenge? _challenge;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _challenge = null;
    });
    try {
      final c = await _api.fetchDaily();
      setState(() => _challenge = c);
    } catch (e) {
      setState(() => _error = 'Servidor offline. Suba o backend Java para o desafio do dia.');
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _api.dispose();
    super.dispose();
  }

  void _play() {
    final challenge = _challenge;
    if (challenge == null) return;
    final game = CursedCastleGame(challenge: challenge, api: _api)
      ..playerName = _name.text.trim().isEmpty ? 'Arthur' : _name.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('CURSED CASTLE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Color(0xFFE8C36B))),
                const SizedBox(height: 4),
                const Text('Desafio diario',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 24),
                if (_error != null) _errorBox(),
                if (_challenge != null) _challengeCard(_challenge!),
                if (_challenge == null && _error == null)
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                TextField(
                  controller: _name,
                  maxLength: 24,
                  decoration: const InputDecoration(
                    labelText: 'Seu nome no ranking',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _challenge == null ? null : _play,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('JOGAR'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Teclado: ← → andar · Z pular (2x = pulo duplo) · X arremessar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBox() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _load, child: const Text('Tentar de novo')),
          ],
        ),
      );

  Widget _challengeCard(DailyChallenge c) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF24305C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Maldicoes de hoje (${c.date})',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...c.curses.map((curse) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 16, color: Color(0xFFB146E6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${curse.label} — ${curse.description}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      );
}

/// Tela do jogo em si, com HUD e overlay de resultado.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.game});

  final CursedCastleGame game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<CursedCastleGame>(
        game: game,
        overlayBuilderMap: {
          'hud': (_, g) => Hud(game: g),
          'result': (_, g) => _ResultOverlay(game: g),
        },
        initialActiveOverlays: const ['hud', 'result'],
      ),
    );
  }
}

/// Aparece so quando a run termina (vitoria ou derrota).
class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.game});

  final CursedCastleGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RunStatus>(
      valueListenable: game.status,
      builder: (context, status, _) {
        if (status == RunStatus.playing) return const SizedBox.shrink();
        final won = status == RunStatus.won;
        return Container(
          color: Colors.black.withOpacity(0.7),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(won ? 'VITORIA' : 'DERROTA',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: won ? const Color(0xFFE8C36B) : Colors.redAccent)),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: game.resultMessage,
                builder: (_, msg, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70)),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar ao menu'),
              ),
            ],
          ),
        );
      },
    );
  }
}
