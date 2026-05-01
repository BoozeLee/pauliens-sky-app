# Paulien's Sky — Mini Game Design Specs

---

## Game 1: Ms. Paulina — Cosmic Pacman

### Concept
A Pacman-style arcade game where the player navigates Ms. Paulina — a luminous soul whose head is a spinning zodiac glyph — through 12 zodiac-themed mazes collecting planetary fragments, aspects, and Behenian star power-ups. Each maze represents a zodiac sign; the player's birth chart determines starting bonuses. Four shadow planets act as enemies.

### Core Mechanics
- **12 levels** = 12 zodiac signs. Each maze has sign-specific color palette, wall geometry, and ambient music tone.
- **Collectibles:**
  - Planet glyphs (☉☽☿♀♂♃♄) = standard dots, 10 pts each
  - Aspect fragments (lines between signs) = bonus corridors, 25 pts
  - Star fragments = rare pickups, 50 pts
- **Behenian power-ups** — eating a named star (Sirius, Vega, Algol, etc.) triggers a 10s power mode unique to that star's mythology:
  - *Sirius* → "Isis Mode" — speed ×1.8, enemies flee
  - *Algol* → "Medusa Mode" — enemies freeze, double score
  - *Vega* → "Orpheus Mode" — attract nearby collectibles magnetically
  - *Spica* → "Fortuna Mode" — all dots worth ×3 briefly
  - *(remaining 14 Behenian stars mapped to unique effects)*
- **Shadow planet enemies (4):**
  - **Lilith** (black moon) — seductive pathfinder, hunts by smell, lures player
  - **Chiron** (centaur) — wounded healer, unpredictable erratic movement
  - **Rahu** (north node) — obsessive pursuer, accelerates as player collects more
  - **Ketu** (south node) — dissolver, phases through walls periodically
- **Moon phase mechanic** — changes every 3 levels. Waxing = enemies slower, Waning = maze walls shift at intervals.
- **Birth chart bonuses (from active profile):**
  - Sun sign → starting power-up flavour
  - Moon sign → base speed modifier (Water signs faster, Earth signs more shield)
  - ASC → shield duration when hit

### Flutter Implementation
```
lib/games/paulina/
├── paulina_game.dart         — root widget, game loop via Flame engine
├── maze_generator.dart       — sign-themed procedural maze (12 templates)
├── player.dart               — Ms. Paulina entity, birth-chart bonus resolver
├── enemies/
│   ├── lilith.dart
│   ├── chiron.dart
│   ├── rahu.dart
│   └── ketu.dart
├── collectibles.dart         — planet/aspect/star pickup logic
├── power_ups.dart            — 18 Behenian star effects
└── game_state.dart           — score, level, moon phase, journal
```
**Engine:** [Flame](https://pub.dev/packages/flame) — Flutter game engine already suitable for 2D arcade games.
**Integration:** `GameScreen` navigates from the Explore tab. `ChartEngine.compute(activeProfile)` runs at game start, resolves bonuses.

### Visual Style
Dark cosmic background (matches app). Maze walls = constellation line-art in sign color. Player = glowing zodiac wheel sprite with particle trail. Enemies = smoky shadow orbs with mythology sigils. Score = Cinzel font in neon yellow.

---

## Game 2: Celestial Lovers — Intimate Astrology Card Game (18+)

### Concept
A personalized two-player card game for couples. It reads the actual synastry between two profiles and generates a deck of prompts calibrated to their real planetary aspects — Venus-Mars conjunctions produce physical prompts, Moon-Moon aspects produce emotional connection cards, Mercury aspects produce intellectual/playful ones. Four escalation tiers let partners choose how deep to go.

### Core Mechanics
- **Setup:** Both players select their profiles. The synastry engine computes all aspects between their charts. The deck is ordered/weighted by aspect strength and type.
- **4 Deck Types** (drawn from different planetary pairings):
  | Deck | Planet pairs | Theme |
  |------|-------------|-------|
  | Emotional ♾ | Moon-Moon, Moon-Venus, Moon-Sun | Vulnerability, connection, feelings |
  | Intellectual ☿ | Mercury-Mercury, Mercury-Sun | Words, play, creativity, teasing |
  | Physical ♀♂ | Venus-Mars, ASC-Venus, ASC-Mars | Attraction, sensation, presence |
  | Soul ☉♄ | Sun-Sun, Sun-Saturn, Saturn-Moon | Depth, trust, long-term resonance |
- **Escalation levels** — player chooses before each session:
  - **Curious** — playful, fully clothed, emotionally safe
  - **Intimate** — emotional depth, light physical touch, eye contact
  - **Sensual** — erotic tension, body awareness, adult themes
  - **Bold** — explicit adult prompts for established partners
- **Each card:**
  - Aspect name + symbol (e.g. "Venus △ Mars")
  - A 2-3 sentence prompt tailored to that aspect at the chosen escalation level
  - Timer: 60s default (adjustable 30–120s)
  - Options: Complete ✓ / Skip ↷ / Forfeit 🔥 (loser does a dare)
- **Prompt examples:**
  - *Venus trine Mars / Sensual*: "Your magnetic pull is celestial law. One partner traces a slow path with a single fingertip — no words, no rush — while the other stays perfectly still."
  - *Moon square Moon / Curious*: "Your emotional worlds clash like tides. Each of you shares one thing you've never said out loud. Listen without responding."
  - *Mercury sextile Mercury / Intimate*: "Your minds orbit each other naturally. Take turns whispering one secret desire — something that surprises even yourself."
- **Deck seeding:** prompts stored in `assets/data/lovers_prompts.json`, keyed by aspect type + escalation level. 200+ cards authored.

### Flutter Implementation
```
lib/games/lovers/
├── lovers_game.dart          — root widget + session state
├── age_gate.dart             — 18+ confirmation (stored in secure prefs)
├── deck_builder.dart         — uses SynastryEngine + profile pair → ordered deck
├── card_widget.dart          — flip animation, timer, action buttons
├── prompt_repository.dart    — loads lovers_prompts.json, resolves by aspect+level
└── session_state.dart        — pause/resume, score tally, history

assets/data/lovers_prompts.json  — structured prompt library (200+ entries)
```
**Navigation:** Accessed from Explore tab or Profile Comparison screen ("♥ Play Together" button, only shown when 2+ profiles exist).
**Age gate:** A one-time 18+ acknowledgement, stored in `flutter_secure_storage`.

### Visual Style
Matches app dark cosmic theme. Cards are deep navy with gold foil borders (BoxDecoration gradient). Card faces show zodiac aspect symbol large in center with prompt beneath. Flip animation using `AnimationController` + `Transform`. Cosmic particle burst on card reveal.

---

## Integration Summary

Both games access the same data layer the app already has:
- `FullChart` / `AstroSnapshot` → birth bonuses for Paulina, aspect weights for Lovers
- `SynastryEngine` → Lovers deck builder
- `FixedStars.all` → Paulina power-up catalog
- `CosmicTheme` / `CosmicColors` → shared visual identity
- `AppState.profiles` → profile selection for both games

Neither game requires new backend services — they are fully on-device.
