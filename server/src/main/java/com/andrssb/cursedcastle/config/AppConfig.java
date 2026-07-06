package com.andrssb.cursedcastle.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.time.Clock;

/**
 * Beans de infraestrutura da aplicacao.
 */
@Configuration
public class AppConfig {

    /** Clock injetavel — facilita testar a logica de "hoje" sem depender do relogio real. */
    @Bean
    public Clock clock() {
        return Clock.systemUTC();
    }

    /** Libera o cliente Flutter a chamar a API (origens configuraveis por ambiente). */
    @Bean
    public WebMvcConfigurer corsConfigurer(@Value("${game.cors.allowed-origins}") String origins) {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/api/**")
                        .allowedOrigins(origins.split(","))
                        .allowedMethods("GET", "POST");
            }
        };
    }
}
