package com.andrssb.cursedcastle.leaderboard;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Lancada quando uma run submetida e impossivel de ter acontecido de verdade
 * (tentativa de trapaca ou cliente adulterado). Vira HTTP 422.
 */
@ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
public class InvalidRunException extends RuntimeException {

    public InvalidRunException(String message) {
        super(message);
    }
}
