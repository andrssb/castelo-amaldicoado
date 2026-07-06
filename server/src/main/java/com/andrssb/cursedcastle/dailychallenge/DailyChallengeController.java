package com.andrssb.cursedcastle.dailychallenge;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Expoe o desafio diario para o cliente do jogo.
 */
@RestController
@RequestMapping("/api/daily")
public class DailyChallengeController {

    private final DailyChallengeService service;

    public DailyChallengeController(DailyChallengeService service) {
        this.service = service;
    }

    @GetMapping
    public DailyChallenge today() {
        return service.today();
    }
}
