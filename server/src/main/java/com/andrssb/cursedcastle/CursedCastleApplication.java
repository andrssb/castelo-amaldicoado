package com.andrssb.cursedcastle;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Ponto de entrada do servidor do jogo Cursed Castle.
 *
 * <p>Expoe a camada online: geracao do desafio diario procedural,
 * validacao anti-cheat das partidas e ranking global.
 */
@SpringBootApplication
public class CursedCastleApplication {

    public static void main(String[] args) {
        SpringApplication.run(CursedCastleApplication.class, args);
    }
}
