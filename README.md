<div align="center">

# Cursed Castle

**Um cavaleiro. Um castelo amaldiçoado. Uma corrida diária contra o mundo.**

Jogo de plataforma/ação no estilo dos clássicos dos anos 80/90 (inspirado em *Ghouls'n Ghosts*),
com uma camada online de verdade: desafio diário procedural e ranking global validado no servidor.

`Flutter` · `Flame` · `Java` · `Spring Boot` · `WebSocket-ready`

</div>

---

## A ideia

Arthur, o cavaleiro, precisa atravessar o castelo e destruir as maldições que o assolam.
A armadura quebra quando ele toma dano (armadura → sem armadura → morte), tem pulo duplo e
arremesso de arma — a fórmula clássica do gênero.

O diferencial de portfólio é a **camada online**, que não é um CRUD de cadastro qualquer:

- **Desafio diário procedural** — o servidor gera, a partir de uma *seed* do dia, um conjunto de
  maldições (chão de gelo, dobro de esqueletos, escuridão, etc.). **Todo mundo joga o mesmo desafio no
  mesmo dia** e compete no ranking. Estilo roguelike/Wordle.
- **Ranking global com validação anti-cheat** — o servidor **não confia** na pontuação que o cliente
  envia: ele reconstrói a partida a partir da seed + dos eventos e confere se o resultado é possível.
- **Progresso do jogador** persistido.

## Arquitetura

```
cursed-castle/
├── game/      → cliente do jogo   (Flutter + Flame)
└── server/    → servidor do jogo  (Java + Spring Boot)
```

O jogo roda offline; ao terminar uma run do desafio diário, o cliente fala com o servidor Java para
buscar a seed do dia e submeter a pontuação para validação e ranking.

| Camada  | Tecnologia | Responsabilidade |
|---------|-----------|------------------|
| Cliente | Flutter + Flame | Jogabilidade, física, render, controles |
| Servidor| Spring Boot (Java 21) | Seed diária procedural, validação de run, ranking, persistência |
| Dados   | H2 (dev) / PostgreSQL (prod) | Ranking e progresso |

## Como rodar

### Servidor (Java)
Requer **JDK 21+** e **Maven 3.9+**.

```bash
cd server
mvn spring-boot:run
```

> Dica: com o Maven instalado, gere o *wrapper* uma vez (`mvn -N wrapper:wrapper`)
> para que qualquer pessoa rode `./mvnw` sem instalar o Maven.
A API sobe em `http://localhost:8080`. Endpoints principais:

- `GET  /api/daily`            → desafio do dia (seed + maldições)
- `GET  /api/leaderboard`      → ranking do dia
- `POST /api/leaderboard`      → submete uma run (validada no servidor)

### Jogo (Flutter)
Requer o **Flutter SDK**. Na primeira vez, gere as pastas de plataforma:

```bash
cd game
flutter create .              # gera android/ios/web/windows a partir do pubspec
flutter pub get
flutter run                   # -d chrome, -d windows, ou um emulador
```

> Controles (teclado, para testar no desktop): **← →** anda · **Z** pula (2x = pulo duplo) · **X** arremessa.

## Status

Estrutura inicial (esqueleto jogável + API funcional). Roadmap em aberto: chefe de fase, mais
maldições, controles de toque para mobile e deploy do servidor.

---

<div align="center">
Feito por <a href="https://github.com/andrssb">Andres Barbosa</a>
</div>
