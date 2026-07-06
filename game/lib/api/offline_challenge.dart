import 'models.dart';

/// Desafio gerado localmente quando o servidor esta indisponivel.
///
/// Mantem o jogo jogavel offline (sem ranking/validacao). A seed vem da data,
/// entao no mesmo dia o desafio local e sempre o mesmo.
DailyChallenge offlineDailyChallenge([DateTime? now]) {
  final today = now ?? DateTime.now();
  final date = DateTime(today.year, today.month, today.day);
  final seed = date.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  const pool = [
    CurseInfo(id: 'ICE_FLOOR', label: 'Chao de Gelo', description: 'O chao escorrega.'),
    CurseInfo(id: 'HORDE', label: 'Horda de Esqueletos', description: 'Dobro de inimigos.'),
    CurseInfo(id: 'FRENZY', label: 'Furia dos Mortos', description: 'Inimigos mais rapidos.'),
    CurseInfo(id: 'GLASS_ARMOR', label: 'Armadura de Vidro', description: 'Um dano ja tira a armadura.'),
  ];

  // escolhe duas maldicoes a partir da seed
  final first = pool[seed % pool.length];
  final second = pool[(seed + 1) % pool.length];
  final curses = [first, if (second.id != first.id) second];

  final hasHorde = curses.any((c) => c.id == 'HORDE');

  return DailyChallenge(
    date: '${date.year}-${_pad2(date.month)}-${_pad2(date.day)}',
    seed: seed,
    curses: curses,
    totalEnemies: hasHorde ? 48 : 24,
    totalCurses: 4,
    parTimeMs: 180000,
  );
}

String _pad2(int n) => n.toString().padLeft(2, '0');
