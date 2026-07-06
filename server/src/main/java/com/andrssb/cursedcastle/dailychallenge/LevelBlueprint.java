package com.andrssb.cursedcastle.dailychallenge;

import java.util.List;

/**
 * Descricao deterministica de uma fase gerada a partir de uma seed.
 *
 * <p>E a "fonte de verdade" do que e possivel numa run: quantos inimigos e
 * maldicoes existem e o tempo minimo plausivel para terminar. Tanto a geracao
 * do desafio diario quanto a validacao anti-cheat derivam desta estrutura, para
 * que nunca fiquem fora de sincronia.
 *
 * @param curses        maldicoes ativas na fase
 * @param totalEnemies  total de inimigos que podem ser derrotados
 * @param totalCurses   total de objetos de maldicao que podem ser destruidos
 * @param minTimeMs     tempo minimo plausivel para concluir (ms)
 * @param maxScore      pontuacao maxima teorica da fase
 */
public record LevelBlueprint(
        List<Curse> curses,
        int totalEnemies,
        int totalCurses,
        long minTimeMs,
        long maxScore) {
}
