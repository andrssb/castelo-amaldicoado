package com.andrssb.cursedcastle.dailychallenge;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;

/**
 * Gera, de forma 100% deterministica, a fase correspondente a uma seed.
 *
 * <p>A mesma seed produz sempre a mesma {@link LevelBlueprint}. Isso e o que
 * permite: (1) todos os jogadores enfrentarem o mesmo desafio no dia e
 * (2) o servidor reconstruir a fase para validar uma run sem confiar no cliente.
 */
@Component
public class ChallengeGenerator {

    /** Pontos por inimigo derrotado. */
    public static final long POINTS_PER_ENEMY = 100L;
    /** Pontos por maldicao destruida. */
    public static final long POINTS_PER_CURSE = 500L;
    /** Tempo de referencia (par). Terminar abaixo disso rende bonus. */
    public static final long PAR_TIME_MS = 180_000L;
    /** Bonus maximo por velocidade. */
    public static final long MAX_TIME_BONUS = 10_000L;
    /** Ninguem termina a fase mais rapido que isto — usado como piso anti-cheat. */
    public static final long MIN_PLAUSIBLE_TIME_MS = 25_000L;

    public LevelBlueprint generate(long seed) {
        Random rng = new Random(seed);

        List<Curse> curses = pickCurses(rng);

        int totalEnemies = 20 + rng.nextInt(21);          // 20..40
        if (curses.contains(Curse.HORDE)) {
            totalEnemies *= 2;
        }

        int totalCurses = 3 + rng.nextInt(3);             // 3..5

        long enemyPoints = curses.contains(Curse.BLOOD_MOON)
                ? POINTS_PER_ENEMY * 2
                : POINTS_PER_ENEMY;

        long maxScore = (long) totalEnemies * enemyPoints
                + (long) totalCurses * POINTS_PER_CURSE
                + MAX_TIME_BONUS;

        return new LevelBlueprint(curses, totalEnemies, totalCurses, MIN_PLAUSIBLE_TIME_MS, maxScore);
    }

    /** Pontos que uma run rende dado o que foi de fato realizado nela. */
    public long scoreOf(long seed, int enemiesDefeated, int cursesDestroyed, long timeMs) {
        LevelBlueprint level = generate(seed);
        long enemyPoints = level.curses().contains(Curse.BLOOD_MOON)
                ? POINTS_PER_ENEMY * 2
                : POINTS_PER_ENEMY;

        long base = (long) enemiesDefeated * enemyPoints
                + (long) cursesDestroyed * POINTS_PER_CURSE;

        return base + timeBonus(timeMs);
    }

    /** Bonus por velocidade: quanto mais abaixo do par, maior — limitado. */
    public long timeBonus(long timeMs) {
        if (timeMs >= PAR_TIME_MS) {
            return 0L;
        }
        long saved = PAR_TIME_MS - timeMs;
        long bonus = saved / 10;                          // ~1 ponto a cada 10ms poupados
        return Math.min(bonus, MAX_TIME_BONUS);
    }

    /** Escolhe de 2 a 3 maldicoes distintas, de forma deterministica pela seed. */
    private List<Curse> pickCurses(Random rng) {
        List<Curse> pool = new ArrayList<>(Arrays.asList(Curse.values()));
        Collections.shuffle(pool, rng);
        int count = 2 + rng.nextInt(2);                   // 2..3
        return List.copyOf(pool.subList(0, count));
    }
}
