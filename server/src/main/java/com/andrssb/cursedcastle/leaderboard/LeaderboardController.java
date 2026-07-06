package com.andrssb.cursedcastle.leaderboard;

import com.andrssb.cursedcastle.dailychallenge.DailyChallenge;
import com.andrssb.cursedcastle.dailychallenge.DailyChallengeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Ranking do desafio diario: consulta e submissao (validada) de pontuacoes.
 */
@RestController
@RequestMapping("/api/leaderboard")
public class LeaderboardController {

    private final ScoreRepository repository;
    private final RunValidationService validation;
    private final DailyChallengeService dailyChallenge;
    private final Clock clock;

    public LeaderboardController(ScoreRepository repository,
                                 RunValidationService validation,
                                 DailyChallengeService dailyChallenge,
                                 Clock clock) {
        this.repository = repository;
        this.validation = validation;
        this.dailyChallenge = dailyChallenge;
        this.clock = clock;
    }

    /** Top 20 do desafio de hoje. */
    @GetMapping
    public List<LeaderboardEntry> today() {
        DailyChallenge challenge = dailyChallenge.today();
        List<ScoreEntry> entries =
                repository.findTop20ByChallengeDateOrderByScoreDescTimeMsAsc(challenge.date());

        AtomicInteger rank = new AtomicInteger(1);
        return entries.stream()
                .map(e -> new LeaderboardEntry(
                        rank.getAndIncrement(), e.getPlayerName(), e.getScore(), e.getTimeMs()))
                .toList();
    }

    /** Submete uma run. O servidor valida e calcula a pontuacao final. */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public LeaderboardEntry submit(@Valid @RequestBody RunSubmission run) {
        DailyChallenge challenge = dailyChallenge.today();

        // So aceitamos runs do desafio de hoje — impede reenviar pontuacao de dias antigos.
        if (run.seed() != challenge.seed()) {
            throw new InvalidRunException("Seed nao corresponde ao desafio de hoje.");
        }

        long score = validation.validateAndScore(run);

        ScoreEntry saved = repository.save(new ScoreEntry(
                run.playerName().trim(),
                challenge.date(),
                score,
                run.timeMs(),
                Instant.now(clock)));

        return new LeaderboardEntry(0, saved.getPlayerName(), saved.getScore(), saved.getTimeMs());
    }
}
