package com.andrssb.cursedcastle.leaderboard;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface ScoreRepository extends JpaRepository<ScoreEntry, Long> {

    /** Melhores pontuacoes de um dia — maior score primeiro, desempate por menor tempo. */
    List<ScoreEntry> findTop20ByChallengeDateOrderByScoreDescTimeMsAsc(LocalDate challengeDate);
}
