package com.andrssb.cursedcastle.dailychallenge;

/**
 * Maldicoes que modificam a fase do dia. Cada uma altera a jogabilidade
 * de um jeito e o cliente Flutter sabe como renderiza-la a partir do {@code id}.
 */
public enum Curse {

    ICE_FLOOR("Chão de Gelo", "O chão escorrega; frear é difícil."),
    HORDE("Horda de Esqueletos", "Dobro de inimigos no caminho."),
    DARKNESS("Escuridão", "A visão ao redor de Arthur é reduzida."),
    GLASS_ARMOR("Armadura de Vidro", "Um único dano já tira a armadura."),
    FRENZY("Fúria dos Mortos", "Os inimigos se movem mais rápido."),
    BLOOD_MOON("Lua de Sangue", "Inimigos valem mais pontos, mas revidam.");

    private final String label;
    private final String description;

    Curse(String label, String description) {
        this.label = label;
        this.description = description;
    }

    public String label() {
        return label;
    }

    public String description() {
        return description;
    }
}
