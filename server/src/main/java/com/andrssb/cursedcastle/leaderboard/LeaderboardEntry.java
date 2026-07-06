package com.andrssb.cursedcastle.leaderboard;

/**
 * Uma linha do ranking exibida ao jogador.
 *
 * @param rank       posicao (1 = melhor)
 * @param playerName nome do jogador
 * @param score      pontuacao validada pelo servidor
 * @param timeMs     tempo da run
 */
public record LeaderboardEntry(int rank, String playerName, long score, long timeMs) {
}
