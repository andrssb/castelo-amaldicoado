import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Cliente HTTP para a camada online (servidor Java).
///
/// O jogo funciona offline; esta classe so entra em cena para buscar o desafio
/// do dia e submeter a run ao ranking.
class GameApi {
  GameApi({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// Ajuste para o dominio do servidor em producao.
  /// (Em emulador Android, `localhost` do host e `10.0.2.2`.)
  static const String _defaultBaseUrl = 'http://localhost:8080';

  final String baseUrl;
  final http.Client _client;

  Future<DailyChallenge> fetchDaily() async {
    final res = await _client.get(Uri.parse('$baseUrl/api/daily'));
    if (res.statusCode != 200) {
      throw GameApiException('Falha ao buscar o desafio (${res.statusCode}).');
    }
    return DailyChallenge.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final res = await _client.get(Uri.parse('$baseUrl/api/leaderboard'));
    if (res.statusCode != 200) {
      throw GameApiException('Falha ao buscar o ranking (${res.statusCode}).');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Submete a run. O servidor valida e devolve a pontuacao oficial.
  Future<LeaderboardEntry> submitRun(RunSubmission run) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/api/leaderboard'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(run.toJson()),
    );
    if (res.statusCode == 422) {
      throw GameApiException('Run rejeitada pelo servidor (anti-cheat).');
    }
    if (res.statusCode != 201) {
      throw GameApiException('Falha ao enviar a pontuacao (${res.statusCode}).');
    }
    return LeaderboardEntry.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void dispose() => _client.close();
}

class GameApiException implements Exception {
  GameApiException(this.message);
  final String message;

  @override
  String toString() => 'GameApiException: $message';
}
