package com.andrssb.cursedcastle.leaderboard;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * O que o cliente envia ao terminar uma run. Repare que ele manda as
 * <b>evidencias</b> (o que aconteceu na partida), nao a pontuacao final — quem
 * calcula a pontuacao e o servidor, para nao dar para "chutar" um score alto.
 *
 * @param playerName      nome exibido no ranking
 * @param seed            seed da fase jogada (tem que bater com a do dia)
 * @param enemiesDefeated inimigos derrotados
 * @param cursesDestroyed maldicoes destruidas
 * @param timeMs          tempo total da run em milissegundos
 */
public record RunSubmission(
        @NotBlank @Size(max = 24) String playerName,
        long seed,
        @Min(0) int enemiesDefeated,
        @Min(0) int cursesDestroyed,
        @Min(0) @Max(3_600_000) long timeMs) {
}
