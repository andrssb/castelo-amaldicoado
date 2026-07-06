package com.andrssb.cursedcastle.dailychallenge;

import java.time.LocalDate;
import java.util.List;

/**
 * Representacao do desafio diario enviada ao cliente Flutter.
 *
 * @param date         dia do desafio (UTC)
 * @param seed         semente para o cliente gerar a mesma fase do servidor
 * @param curses       maldicoes ativas (id, nome e descricao)
 * @param totalEnemies quantos inimigos a fase deve conter
 * @param totalCurses  quantas maldicoes precisam ser destruidas
 * @param parTimeMs    tempo de referencia da fase
 */
public record DailyChallenge(
        LocalDate date,
        long seed,
        List<CurseInfo> curses,
        int totalEnemies,
        int totalCurses,
        long parTimeMs) {

    public record CurseInfo(String id, String label, String description) {
        static CurseInfo from(Curse curse) {
            return new CurseInfo(curse.name(), curse.label(), curse.description());
        }
    }
}
