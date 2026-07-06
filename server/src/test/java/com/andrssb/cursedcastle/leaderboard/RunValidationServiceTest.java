package com.andrssb.cursedcastle.leaderboard;

import com.andrssb.cursedcastle.dailychallenge.ChallengeGenerator;
import com.andrssb.cursedcastle.dailychallenge.LevelBlueprint;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Garante que o anti-cheat aceita runs plausiveis e rejeita as impossiveis.
 */
class RunValidationServiceTest {

    private static final long SEED = 123_456_789L;

    private final ChallengeGenerator generator = new ChallengeGenerator();
    private final RunValidationService service = new RunValidationService(generator);

    @Test
    void aceitaRunPlausivelEDevolvePontuacaoDoServidor() {
        LevelBlueprint level = generator.generate(SEED);
        RunSubmission run = new RunSubmission(
                "Arthur", SEED,
                level.totalEnemies(), level.totalCurses(),
                120_000L);

        long score = service.validateAndScore(run);

        long esperado = generator.scoreOf(
                SEED, level.totalEnemies(), level.totalCurses(), 120_000L);
        assertThat(score).isEqualTo(esperado);
        assertThat(score).isLessThanOrEqualTo(level.maxScore());
    }

    @Test
    void rejeitaMaisInimigosDoQueAFasePermite() {
        LevelBlueprint level = generator.generate(SEED);
        RunSubmission run = new RunSubmission(
                "Trapaceiro", SEED,
                level.totalEnemies() + 1, level.totalCurses(),
                120_000L);

        assertThatThrownBy(() -> service.validateAndScore(run))
                .isInstanceOf(InvalidRunException.class)
                .hasMessageContaining("Inimigos");
    }

    @Test
    void rejeitaTempoImpossivelmenteRapido() {
        LevelBlueprint level = generator.generate(SEED);
        RunSubmission run = new RunSubmission(
                "Turbo", SEED,
                level.totalEnemies(), level.totalCurses(),
                1_000L);

        assertThatThrownBy(() -> service.validateAndScore(run))
                .isInstanceOf(InvalidRunException.class)
                .hasMessageContaining("Tempo");
    }
}
