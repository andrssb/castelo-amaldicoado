package com.andrssb.cursedcastle.leaderboard;

import com.andrssb.cursedcastle.dailychallenge.ChallengeGenerator;
import com.andrssb.cursedcastle.dailychallenge.LevelBlueprint;
import org.springframework.stereotype.Service;

/**
 * Anti-cheat. Reconstroi a fase a partir da seed e verifica se as evidencias da
 * run cabem dentro do que aquela fase permite. Se couberem, devolve a pontuacao
 * <b>calculada pelo servidor</b> — que e o que vai para o ranking.
 *
 * <p>Como a geracao da fase e deterministica ({@link ChallengeGenerator}), o
 * servidor nao precisa ter "assistido" a partida para saber o que era possivel
 * nela: bastam a seed e os numeros reportados.
 */
@Service
public class RunValidationService {

    private final ChallengeGenerator generator;

    public RunValidationService(ChallengeGenerator generator) {
        this.generator = generator;
    }

    /**
     * @return a pontuacao canonica (calculada pelo servidor) se a run for valida
     * @throws InvalidRunException se a run for impossivel para aquela seed
     */
    public long validateAndScore(RunSubmission run) {
        LevelBlueprint level = generator.generate(run.seed());

        if (run.enemiesDefeated() > level.totalEnemies()) {
            throw new InvalidRunException(
                    "Inimigos derrotados (%d) acima do total da fase (%d)."
                            .formatted(run.enemiesDefeated(), level.totalEnemies()));
        }

        if (run.cursesDestroyed() > level.totalCurses()) {
            throw new InvalidRunException(
                    "Maldicoes destruidas (%d) acima do total da fase (%d)."
                            .formatted(run.cursesDestroyed(), level.totalCurses()));
        }

        if (run.timeMs() < level.minTimeMs()) {
            throw new InvalidRunException(
                    "Tempo (%d ms) abaixo do minimo plausivel (%d ms)."
                            .formatted(run.timeMs(), level.minTimeMs()));
        }

        long score = generator.scoreOf(
                run.seed(), run.enemiesDefeated(), run.cursesDestroyed(), run.timeMs());

        if (score > level.maxScore()) {
            // Rede de seguranca: nunca deveria acontecer se os limites acima passaram.
            throw new InvalidRunException(
                    "Pontuacao (%d) acima do maximo teorico da fase (%d)."
                            .formatted(score, level.maxScore()));
        }

        return score;
    }
}
