# Paulien's Sky — Task List

---

## ✅ Completed (v2.0.0 — Sprint 1 & 2)

### Core App
- [x] Flutter project scaffold, Linux + Android targets
- [x] Cosmic dark theme (CosmicTheme, CosmicColors)
- [x] 5-tab bottom navigation (Home, Chart, AI, Explore, Settings)
- [x] Sky background with twinkling star field
- [x] EN/NL locale toggle (LocaleService, shared_preferences)
- [x] Multi-profile support (Paulien, Nurse, Bernd, Kiliaan)
- [x] Profile switcher in home screen header
- [x] Birth input screen (date, time, place, geocoding)
- [x] Splash screen with Cinzel font

### Chart Engine (7 Traditions)
- [x] **Western** — tropical zodiac, houses, decans, all planets, aspects
- [x] **Vedic (Jyotish)** — sidereal, nakshatras, Lahiri ayanamsha
- [x] **Chinese (BaZi)** — Ba Zi pillars, year animal, five elements
- [x] **Mayan (Tzolk'in)** — day sign, tonal number, galactic tone
- [x] **Egyptian** — 36 decans, deity rulers
- [x] **Celtic** — tree calendar, ogham, animal totems
- [x] **Zoroastrian** — Fasli calendar, 30 day Yazatas, 4 season stars,
      6 Amesha Spentas, sacred fire types, Fravashi archetypes
- [x] Zodiac wheel widget (dual-ring tropical + sidereal)
- [x] Fixed stars card — 18 Behenian stars with mythology, herbs, stones
- [x] Personality radar — cross-tradition trait synthesis
- [x] Share card — PNG export to Downloads

### AI System
- [x] Claude (Anthropic) + Gemini chat integration
- [x] AETHER local model (llama.cpp FFI, isolate-based streaming)
- [x] Penta-layer prompt system (context + RAG + memory + culture + user query)
- [x] TF-IDF RAG over classical astrology texts
- [x] JSONL persistent memory journal
- [x] Model manager screen (download + load GGUF models)
- [x] AI Orchestrator — routes local → Claude → Gemini → error

### Profiles
- [x] **Paulien** — 13 Mar 1996, 09:00 CET, Hasselt
- [x] **Nurse** — 12 Oct 2001, 07:00 CEST, Turnhout
- [x] **Bernd** — 23 Feb 2000, 15:00 CET, Sint-Truiden
- [x] **Kiliaan** — 20 Apr 1986, 11:11 CEST, Leuven (Cancer ASC, Taurus ☉, Ashwini)
- [x] AppState CRUD (add / update / remove / switch / persist via SharedPrefs)

### Developer Tooling
- [x] Makefile (build, run, apod, horizons, stars, iers, penta, push)
- [x] scripts/task_runner.py — TUI task runner
- [x] scripts/fetch_apis.py — NASA APOD, JPL Horizons, IERS
- [x] scripts/build_star_catalog.py — HYG CSV → bright_stars.json
- [x] scripts/penta_mind.py — CLI oracle with Claude API
- [x] scripts/download_model.sh — GGUF download helper
- [x] Omarchy desktop entry

### APIs Integrated
- [x] JPL Horizons — sub-arcsecond positions (disk cache by JDE key)
- [x] NASA APOD — daily cosmic image + widget
- [x] IERS Delta-T — polynomial correction
- [x] HYG Star Catalog — 518 stars (mag ≤ 4.0) in bright_stars.json

---

## ✅ Sprint 3 (2026-05-01)

### T6b — FixedStars from HYG Catalog ✅
- [x] `FixedStar._fromHyg()` factory from JSON
- [x] `FixedStars.loadCatalog()` — async, merges Behenian lore, precise HYG longitudes
- [x] Falls back to 18 hardcoded stars if asset unavailable
- [x] Called at startup in `main()`

### T16 — AETHER Build ✅
- [x] Updated `aether_llm.cpp` for new llama.cpp vocab API
- [x] `libaether_llm.so` (27KB) at `linux/libs/`
- [x] Fixed `build_llama.sh` false-failure

### T17 — Synastry Engine ✅
- [x] `SynastryChart` / `SynastryAspect` / `AspectType` models
- [x] `SynastryEngine.compute()` — all planet×planet aspects, 5 types
- [x] `_SynastrySection` in `ProfileComparisonScreen`

---

## ✅ Sprint 4 (2026-05-01)

### T18 — OpenAI GPT-4o-mini Integration ✅
- [x] `PremiumService`: `openAiApiKey`, `hasOpenAiKey`, `setOpenAiKey`,
      `clearOpenAiKey`, added to secure storage migration
- [x] `AiService`: `openAiKey` field, `_callOpenAi()` (gpt-4o-mini),
      `AiProvider.openai` enum, updated `_pickProvider()`
- [x] `AiOrchestrator`: `AiProvider.openai` in chain (position 4),
      `hasOpenAi`, routing updated in `chatStream` + `_inferSync`
- [x] `ai_screen.dart`: GPT toggle chip + status dot
- [x] `settings_screen.dart`: OpenAI key field + badge

### T19 — Profile Manager UI ✅
- [x] `_ProfileManager` widget in Settings — lists all profiles
      with avatar, name, DOB, active indicator
- [x] Switch active profile with tap
- [x] Edit profile → `BirthInputScreen` (pre-filled with existing data)
- [x] Delete profile with confirmation dialog (min 1 profile)
- [x] "Add New Profile" button → `BirthInputScreen`
- [x] `BirthInputScreen` now has "SAVE AS PROFILE" button
- [x] `existingProfileId` param → UPDATE vs CREATE path
- [x] Profiles persist to SharedPrefs via `AppState`

---

## 🔨 Sprint 5 — Next Priorities

### T20 — Ms. Paulina: Cosmic Pacman (Mini Game 1)
See design spec: [GAME_DESIGN.md](GAME_DESIGN.md)
- [ ] `lib/games/paulina/` — game module scaffold
- [ ] `PaulinaGame` widget (Flutter CustomPainter or Flame engine)
- [ ] 12-level zodiac maze generator (sign-themed layouts)
- [ ] Player entity: Ms. Paulina with birth-chart bonuses
- [ ] Collectibles: planet glyphs, star fragments, aspect corridors
- [ ] Shadow planet enemies (Lilith, Chiron, Rahu, Ketu) with AI movement
- [ ] Behenian star power-ups (18 stars = 18 power-up flavours)
- [ ] Moon phase mechanic (changes maze behavior each level)
- [ ] High score + myth unlock journal
- [ ] Wired to existing birth chart for starting bonuses

### T21 — Celestial Lovers: Adult Card Game (Mini Game 2)
See design spec: [GAME_DESIGN.md](GAME_DESIGN.md)
- [ ] `lib/games/lovers/` — game module scaffold
- [ ] Age gate screen (18+)
- [ ] Two-profile synastry deck builder (uses SynastryEngine)
- [ ] 4 deck types: Emotional, Intellectual, Physical, Soul
- [ ] Escalation levels: Curious → Intimate → Sensual → Bold
- [ ] 200+ prompt cards authored and seeded in assets/data/lovers_prompts.json
- [ ] Card deal animation (cosmic flip)
- [ ] Timer widget (60s default, adjustable)
- [ ] Forfeit / Skip mechanics
- [ ] Persistent session state (paused game resumes)

### T22 — Transit Calculator
- [ ] `TransitEngine.compute(FullChart natal, DateTime now)` — current sky positions
- [ ] Compute aspects between current sky and natal planets
- [ ] `TransitCard` widget in Chart screen (new tab)
- [ ] Highlight major transits (Pluto, Saturn, Jupiter conjunctions/oppositions)

### T23 — Prokerala API Integration
- [ ] `ProkeralaService` — Indian charts, nakshatras, 300/day free tier
- [ ] Dasha period calculator (Vimshottari)
- [ ] Ashtakavarga scoring
- [ ] Display in Vedic tradition tab

---

## 📋 Backlog

### Features
- [ ] Babylonian astrology module (MUL.APIN star catalogue, cuneiform signs)
- [ ] House system selector (Placidus, Koch, Whole Sign, Equal)
- [ ] Aspect table (conjunctions, oppositions, trines, squares, sextiles)
- [ ] Chart export as PDF
- [ ] Push notification: daily reading at sunrise
- [ ] Android APK build + distribution
- [ ] Offline DE440 ephemeris bundle
- [ ] APOD background option — use today's NASA image as app wallpaper
- [ ] Widget (Android home screen glanceable summary)
- [ ] Profile: birth notes / metadata field (parents, significant events)
- [ ] Model manager: download Mistral-7B-v0.1.Q4_K_M.gguf

### Astrology APIs
| API | Auth | What it gives |
|-----|------|--------------|
| **Prokerala** | Free key | Indian charts, nakshatras, 300/day |
| **AstrologyAPI** | Free tier | Planets, houses, aspects, Nakshatra |
| **Yale BSC5** | None | 9100 bright stars fixed-width |
