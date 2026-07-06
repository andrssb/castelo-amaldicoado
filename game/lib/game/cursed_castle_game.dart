import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';

import '../api/game_api.dart';
import '../api/models.dart';
import 'components/knight.dart';
import 'world/level_builder.dart';

/// Estado geral de uma partida.
enum RunStatus { playing, won, lost }

/// Jogo Cursed Castle. Constroi a fase do desafio diario, controla o cavaleiro
/// e, ao vencer, submete a run ao servidor para validacao e ranking.
class CursedCastleGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  CursedCastleGame({required this.challenge, required this.api});

  final DailyChallenge challenge;
  final GameApi api;

  // maldicoes ativas (derivadas do desafio)
  late final bool icyFloor = challenge.hasCurse('ICE_FLOOR');
  late final bool glassArmor = challenge.hasCurse('GLASS_ARMOR');
  late final bool darkness = challenge.hasCurse('DARKNESS');

  // --- estado observavel pela HUD ---
  final ValueNotifier<int> enemiesDefeated = ValueNotifier(0);
  final ValueNotifier<int> cursesDestroyed = ValueNotifier(0);
  final ValueNotifier<ArmorState> armor = ValueNotifier(ArmorState.armored);
  final ValueNotifier<double> elapsedSeconds = ValueNotifier(0);
  final ValueNotifier<RunStatus> status = ValueNotifier(RunStatus.playing);

  /// Mensagem do resultado (pontuacao validada ou erro de rede).
  final ValueNotifier<String> resultMessage = ValueNotifier('');

  late Knight _knight;
  double levelWidth = 0;
  double levelHeight = 0;

  @override
  Future<void> onLoad() async {
    final layout = LevelBuilder().build(challenge);
    levelWidth = layout.width;
    levelHeight = layout.height;

    world.addAll(layout.components);

    _knight = Knight(position: layout.knightStart);
    world.add(_knight);

    camera.follow(_knight);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (status.value == RunStatus.playing) {
      elapsedSeconds.value += dt;
    }
  }

  // ---------------------------------------------------------------------------
  // Callbacks vindos dos componentes
  // ---------------------------------------------------------------------------
  void onEnemyDefeated() {
    enemiesDefeated.value++;
  }

  void onCurseDestroyed() {
    cursesDestroyed.value++;
    if (cursesDestroyed.value >= challenge.totalCurses) {
      _win();
    }
  }

  void onKnightHit(ArmorState state) {
    armor.value = state;
  }

  void onKnightDied() {
    if (status.value != RunStatus.playing) return;
    status.value = RunStatus.lost;
    resultMessage.value = 'Arthur tombou. Tente novamente amanha... ou agora!';
  }

  void _win() {
    if (status.value != RunStatus.playing) return;
    status.value = RunStatus.won;
    resultMessage.value = 'Maldicoes destruidas! Validando run...';
    _submit();
  }

  /// Envia a run ao servidor. O servidor recalcula e valida a pontuacao.
  Future<void> _submit() async {
    try {
      final entry = await api.submitRun(RunSubmission(
        playerName: playerName,
        seed: challenge.seed,
        enemiesDefeated: enemiesDefeated.value,
        cursesDestroyed: cursesDestroyed.value,
        timeMs: (elapsedSeconds.value * 1000).round(),
      ));
      resultMessage.value =
          'Run validada! Pontuacao oficial: ${entry.score} pts.';
    } on GameApiException catch (e) {
      resultMessage.value = 'Jogou offline (${e.message}). Pontuacao nao salva.';
    } catch (_) {
      resultMessage.value = 'Servidor indisponivel. Pontuacao nao salva.';
    }
  }

  /// Nome do jogador — definido no menu antes de comecar.
  String playerName = 'Arthur';
}
