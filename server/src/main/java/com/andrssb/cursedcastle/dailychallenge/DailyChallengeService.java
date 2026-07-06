package com.andrssb.cursedcastle.dailychallenge;

import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.LocalDate;
import java.util.List;

/**
 * Constroi o desafio de um dia. A seed e derivada exclusivamente da data,
 * entao o desafio e o mesmo para todos os jogadores e reproduzivel a qualquer
 * momento (inclusive para validar runs antigas).
 */
@Service
public class DailyChallengeService {

    private final ChallengeGenerator generator;
    private final Clock clock;

    public DailyChallengeService(ChallengeGenerator generator, Clock clock) {
        this.generator = generator;
        this.clock = clock;
    }

    public DailyChallenge today() {
        return forDate(LocalDate.now(clock));
    }

    public DailyChallenge forDate(LocalDate date) {
        long seed = seedFor(date);
        LevelBlueprint level = generator.generate(seed);

        List<DailyChallenge.CurseInfo> curses = level.curses().stream()
                .map(DailyChallenge.CurseInfo::from)
                .toList();

        return new DailyChallenge(
                date,
                seed,
                curses,
                level.totalEnemies(),
                level.totalCurses(),
                ChallengeGenerator.PAR_TIME_MS);
    }

    /**
     * Seed estavel a partir da data (mistura de bits do epoch-day) — evita datas
     * proximas gerarem fases parecidas.
     */
    public long seedFor(LocalDate date) {
        long day = date.toEpochDay();
        long mixed = day * 0x9E3779B97F4A7C15L;   // constante de dispersao (razao aurea de 64 bits)
        mixed ^= (mixed >>> 29);
        mixed *= 0xBF58476D1CE4E5B9L;
        mixed ^= (mixed >>> 32);
        return mixed;
    }
}
