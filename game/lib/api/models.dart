/// Modelos que espelham o contrato da API do servidor Java.

class CurseInfo {
  const CurseInfo({
    required this.id,
    required this.label,
    required this.description,
  });

  final String id;
  final String label;
  final String description;

  factory CurseInfo.fromJson(Map<String, dynamic> json) => CurseInfo(
        id: json['id'] as String,
        label: json['label'] as String,
        description: json['description'] as String,
      );
}

/// Desafio do dia devolvido por `GET /api/daily`.
class DailyChallenge {
  const DailyChallenge({
    required this.date,
    required this.seed,
    required this.curses,
    required this.totalEnemies,
    required this.totalCurses,
    required this.parTimeMs,
  });

  final String date;
  final int seed;
  final List<CurseInfo> curses;
  final int totalEnemies;
  final int totalCurses;
  final int parTimeMs;

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
        date: json['date'] as String,
        seed: (json['seed'] as num).toInt(),
        curses: (json['curses'] as List<dynamic>)
            .map((e) => CurseInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalEnemies: json['totalEnemies'] as int,
        totalCurses: json['totalCurses'] as int,
        parTimeMs: (json['parTimeMs'] as num).toInt(),
      );

  bool hasCurse(String id) => curses.any((c) => c.id == id);
}

/// Uma linha do ranking (`GET /api/leaderboard`).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.score,
    required this.timeMs,
  });

  final int rank;
  final String playerName;
  final int score;
  final int timeMs;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: json['rank'] as int,
        playerName: json['playerName'] as String,
        score: (json['score'] as num).toInt(),
        timeMs: (json['timeMs'] as num).toInt(),
      );
}

/// O que o cliente envia ao terminar uma run (evidencias, sem o score final —
/// quem calcula a pontuacao e o servidor).
class RunSubmission {
  const RunSubmission({
    required this.playerName,
    required this.seed,
    required this.enemiesDefeated,
    required this.cursesDestroyed,
    required this.timeMs,
  });

  final String playerName;
  final int seed;
  final int enemiesDefeated;
  final int cursesDestroyed;
  final int timeMs;

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'seed': seed,
        'enemiesDefeated': enemiesDefeated,
        'cursesDestroyed': cursesDestroyed,
        'timeMs': timeMs,
      };
}
