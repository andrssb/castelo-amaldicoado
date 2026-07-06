import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';

import '../api/game_api.dart';
import '../api/models.dart';
import 'components/brazier.dart';
import 'components/knight.dart';
import 'components/portal.dart';
import 'world/level_builder.dart';

/// Estado geral de uma partida.
enum RunStatus { playing, won, lost }

/// Jogo Cursed Castle. Constrói a fase do desafio diário, controla o cavaleiro
/// e, ao vencer, submete a run ao servidor para validação e ranking.
///
/// A partida tem dois estágios: no primeiro, Arthur resolve o enigma dos arcanos
/// (acendê-los na ordem certa com o fogo) para abrir o portal; no segundo, na
/// passagem secreta, destrói as maldições para vencer.
class CursedCastleGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  CursedCastleGame({required this.challenge, required this.api});

  final DailyChallenge challenge;
  final GameApi api;

  // maldições ativas (derivadas do desafio)
  late final bool icyFloor = challenge.hasCurse('ICE_FLOOR');
  late final bool glassArmor = challenge.hasCurse('GLASS_ARMOR');
  late final bool darkness = challenge.hasCurse('DARKNESS');

  // --- estado observável pela HUD ---
  final ValueNotifier<int> enemiesDefeated = ValueNotifier(0);
  final ValueNotifier<int> cursesDestroyed = ValueNotifier(0);
  final ValueNotifier<ArmorState> armor = ValueNotifier(ArmorState.armored);
  final ValueNotifier<double> elapsedSeconds = ValueNotifier(0);
  final ValueNotifier<RunStatus> status = ValueNotifier(RunStatus.playing);
  final ValueNotifier<int> stage = ValueNotifier(1);

  // --- enigma dos arcanos ---
  final ValueNotifier<int> puzzleProgress = ValueNotifier(0);
  final ValueNotifier<bool> portalOpen = ValueNotifier(false);

  /// Ordem correta de acender os arcanos (a "solução" do enigma).
  late final List<int> requiredOrder = _buildOrder();

  /// Mensagem do resultado (pontuação validada ou erro de rede).
  final ValueNotifier<String> resultMessage = ValueNotifier('');

  late Knight _knight;
  List<Brazier> _braziers = [];
  Portal? _portal;
  bool _advancing = false;

  double levelWidth = 0;
  double levelHeight = 0;

  @override
  Future<void> onLoad() async {
    _loadStage(1);
  }

  List<int> _buildOrder() {
    final order = [0, 1, 2]..shuffle(Random(challenge.seed));
    return order;
  }

  void _loadStage(int newStage) {
    // limpa o estágio anterior (se houver)
    world.removeAll(world.children.toList());

    stage.value = newStage;
    puzzleProgress.value = 0;
    portalOpen.value = false;
    _advancing = false;

    final layout = LevelBuilder().build(challenge, newStage);
    levelWidth = layout.width;
    levelHeight = layout.height;
    _braziers = layout.braziers;
    _portal = layout.portal;

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
    resultMessage.value = 'Arthur tombou. Tente novamente amanhã... ou agora!';
  }

  /// Enigma: acender os arcanos na ordem certa. Errar apaga todos e recomeça.
  void onBrazierFired(Brazier brazier) {
    if (brazier.lit || portalOpen.value) return;

    final expected = requiredOrder[puzzleProgress.value];
    if (brazier.id == expected) {
      brazier.light();
      puzzleProgress.value++;
      if (puzzleProgress.value >= requiredOrder.length) {
        _openPortal();
      }
    } else {
      for (final b in _braziers) {
        b.reset();
      }
      puzzleProgress.value = 0;
    }
  }

  void _openPortal() {
    portalOpen.value = true;
    _portal?.open = true;
  }

  /// Entrou no portal aberto: avança para a passagem secreta (estágio 2).
  void enterPortal() {
    if (_advancing || stage.value >= 2) return;
    _advancing = true;
    _loadStage(2);
  }

  void _win() {
    if (status.value != RunStatus.playing) return;
    status.value = RunStatus.won;
    resultMessage.value = 'Maldições destruídas! Validando run...';
    _submit();
  }

  /// Envia a run ao servidor. O servidor recalcula e valida a pontuação.
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
          'Run validada! Pontuação oficial: ${entry.score} pts.';
    } on GameApiException catch (e) {
      resultMessage.value = 'Jogou offline (${e.message}). Pontuação não salva.';
    } catch (_) {
      resultMessage.value = 'Servidor indisponível. Pontuação não salva.';
    }
  }

  /// Nome do jogador — definido no menu antes de começar.
  String playerName = 'Arthur';
}
