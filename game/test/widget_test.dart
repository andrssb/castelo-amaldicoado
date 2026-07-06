import 'package:cursed_castle/api/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyChallenge', () {
    const challenge = DailyChallenge(
      date: '2026-07-06',
      seed: 42,
      curses: [
        CurseInfo(id: 'ICE_FLOOR', label: 'Chao de Gelo', description: 'escorrega'),
        CurseInfo(id: 'HORDE', label: 'Horda', description: 'dobro'),
      ],
      totalEnemies: 30,
      totalCurses: 4,
      parTimeMs: 180000,
    );

    test('hasCurse identifica maldicoes ativas', () {
      expect(challenge.hasCurse('ICE_FLOOR'), isTrue);
      expect(challenge.hasCurse('DARKNESS'), isFalse);
    });
  });

  test('RunSubmission serializa as evidencias esperadas pelo servidor', () {
    const run = RunSubmission(
      playerName: 'Arthur',
      seed: 42,
      enemiesDefeated: 12,
      cursesDestroyed: 4,
      timeMs: 95000,
    );

    final json = run.toJson();

    expect(json['playerName'], 'Arthur');
    expect(json['seed'], 42);
    expect(json['enemiesDefeated'], 12);
    expect(json['cursesDestroyed'], 4);
    expect(json['timeMs'], 95000);
  });
}
