package com.andrssb.cursedcastle.leaderboard;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Uma pontuacao registrada no ranking. O {@code score} armazenado e sempre o
 * valor <b>recalculado pelo servidor</b> a partir das evidencias da run, nunca
 * o numero cru enviado pelo cliente.
 */
@Entity
@Table(name = "score_entries")
public class ScoreEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 24)
    private String playerName;

    @Column(nullable = false)
    private LocalDate challengeDate;

    @Column(nullable = false)
    private long score;

    @Column(nullable = false)
    private long timeMs;

    @Column(nullable = false)
    private Instant createdAt;

    protected ScoreEntry() {
        // exigido pelo JPA
    }

    public ScoreEntry(String playerName, LocalDate challengeDate, long score, long timeMs, Instant createdAt) {
        this.playerName = playerName;
        this.challengeDate = challengeDate;
        this.score = score;
        this.timeMs = timeMs;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public String getPlayerName() {
        return playerName;
    }

    public LocalDate getChallengeDate() {
        return challengeDate;
    }

    public long getScore() {
        return score;
    }

    public long getTimeMs() {
        return timeMs;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
