# Paulien's Sky — V2 Task List

## ✅ Completed

### Core App
- [x] Flutter project scaffold, Linux + Android targets
- [x] Cosmic dark theme (CosmicTheme, CosmicColors)
- [x] 5-tab bottom navigation (Home, Chart, AI, Explore, Settings)
- [x] Sky background with twinkling star field
- [x] EN/NL locale toggle (LocaleService, shared_preferences)
- [x] Multi-profile support (Paulien, Nurse, Bernd)
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
- [x] **Zoroastrian** ← NEW — Fasli calendar, 30 day Yazatas, 4 season stars
      (Tishtrya/Sirius, Vanant/Vega, Satavaesa/Fomalhaut, Hapto-iringa/Ursa Major),
      6 Amesha Spentas, sacred fire types, Fravashi archetypes, karmic virtues
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

### Schema & UI
- [x] **ui_schema.json** — JSON source of truth for entire visual language
      (palette, nav tabs, 7 traditions, card templates, star field, zodiac wheel)
- [x] **UiSchema Dart loader** — typed data classes, SchemaIcons resolver
- [x] **TraditionCard / InsightCard / SchemaSignBadge** — zero hardcode widgets
- [x] Main nav reads tabs from UiSchema + LocaleService (live EN/NL)
- [x] Traditions grid reads from UiSchema.traditions
- [x] 7 per-tradition hero backgrounds (ImageMagick star-field compositing)
- [x] scripts/generate_art.sh — reproducible art generation

### Freemium V2
- [x] All features unlocked — no premium gate (V2 freemium model)
- [x] V2 What's New screen (replaces upgrade screen)
- [x] Version bumped to 2.0.0+2

### Profiles (correct UTC times, Belgium timezone offsets)
- [x] **Paulien** — 13 Mar 1996, 09:00 CET → 08:00 UTC, Hasselt (50.9311°N 5.3378°E)
- [x] **Nurse** — 12 Oct 2001, 07:00 CEST → 05:00 UTC, Turnhout (51.3225°N 4.9436°E)
- [x] **Bernd** — 23 Feb 2000, 15:00 CET → 14:00 UTC, Sint-Truiden (50.8167°N 5.1833°E)
- [x] AppState merges default profiles on load (Bernd/Nurse survive stale prefs)

---

## ✅ Recently Completed

### T11 — Kiliaan Profile ✅
- [x] Profile added: 20 Apr 1986, 11:11 CEST (09:11 UTC), Leuven (50.8798°N 4.7005°E)
- [x] ASC: Cancer 19.0°  MC: Pisces 19.8°  Sun: Taurus 0.3°
- [x] Vedic: Aries 6.7°, Ashwini nakshatra
- [x] Chinese: Fire Tiger | Celtic: Willow (Saille) | Zoroastrian: Ardibehesht 1st day
- [x] 11:11 = Master Number — born at the threshold gateway
- [x] Added to penta_mind.py _PROFILES + corpus expanded to 40+ passages
- [x] AppState._defaults + profile switcher

### T12 — Secure API Key Storage ✅
- [x] flutter_secure_storage ^9.0.0 added to pubspec
- [x] PremiumService: keys stored in Android Keystore / iOS Keychain
- [x] Migration: stale SharedPreferences keys auto-migrated on first run
- [x] Sync in-memory cache populated at startup via loadApiKeys()

### T13 — AI Status Indicator ✅
- [x] _AiStatusRow widget in AI screen header
- [x] 🟢/⚫ dots for AETHER, Claude, Gemini with tooltips

### T14 — Developer Tooling ✅
- [x] Makefile with build, run, apod, horizons, stars, iers, penta, push targets
- [x] scripts/task_runner.py — parses TASKS.md, interactive TUI, --auto mode
- [x] scripts/fetch_apis.py — NASA APOD, JPL Horizons, IERS Bulletin B

### T15 — Corpus Expansion ✅
- [x] penta_mind.py corpus expanded from 14 → 40+ passages
- [x] 5+ passages per tradition (Western, Vedic, Chinese, Mayan, Egyptian, Celtic, Zoroastrian)
- [x] Taurus/cusp, Fire Tiger, Willow, Ashwini, Ardibehesht passages added
- [x] 11:11 Master Number passage added


### T4 — JPL Horizons Ephemeris ✅
- [x] `HorizonsService.fetchPositions(BirthContext)` — 10 HTTP calls, one per planet
- [x] IERS Delta-T polynomial (Espenak & Meeus 2006) applied to JDE
- [x] Disk cache by JDE key (birth charts never change → cache forever)
- [x] Fallback to VSOP87 on network error
- [x] ChartEngine.computeAsync() — tries Horizons, falls back gracefully

### T5 — IERS Delta-T Correction ✅
- [x] Polynomial ΔT for 1986–2026 (Espenak & Meeus 2006 table)
- [x] Embedded in HorizonsService.deltaT() + HorizonsService.jde()

### T6 — HYG Star Catalog ✅
- [x] Download hyg_v38.csv.gz (gzipped), filter magnitude ≤ 4.0 → 518 stars
- [x] Convert RA/Dec → ecliptic longitude (J2000, ε = 23.4392911°)
- [x] Generated assets/data/bright_stars.json
- [x] scripts/build_star_catalog.py

### T7 — NASA APOD Home Screen Widget ✅
- [x] `ApodService.fetchToday()` — memory + daily SharedPrefs cache
- [x] `ApodCard` widget — CachedNetworkImage, expandable explanation
- [x] Wired into home screen (new "TODAY IN THE COSMOS" section)
- [x] Video mediaType handled (YouTube thumbnail + play icon)

### T8 — Profile Comparison Screen ✅
- [x] `ProfileComparisonScreen` — shared/unique traits, sign tables across all 7 traditions
- [x] Trait bar chart (dual-color overlay per profile)
- [x] Compare button wired into HomeScreen
- [x] AppState.chartFor(id) — lazy per-profile chart cache

### T9 — AETHER Penta-Mind ✅
- [x] `scripts/penta_mind.py` — uv-runnable, 5-layer prompt architecture
- [x] Layer 1: TF-IDF RAG over 14 embedded classical passages
- [x] Layer 2: JSONL rolling memory journal per profile
- [x] Layer 3: Birth chart context (all 7 traditions)
- [x] Layer 4: Tradition culture frame (7 available)
- [x] Layer 5: User query
- [x] Claude API integration with rich terminal output

### T10 — Omarchy Desktop Entry ✅
- [x] `~/.local/share/applications/pauliens_sky.desktop` created

## ✅ Recently Completed (Sprint 3)

### T6b — FixedStars from HYG JSON ✅
- [x] `FixedStar._fromHyg()` factory — loads name/lon/mag/spect from JSON
- [x] `FixedStars.loadCatalog()` — async JSON loader, merges Behenian lore by name
- [x] `_catalog` replaces hardcoded 18 stars with 518-star HYG catalog at startup
- [x] Behenian stars get precise HYG longitudes + keep all lore/herb/stone
- [x] Called from `main()` alongside `UiSchema.load()`

### T16 — AETHER .so Build ✅
- [x] Updated `aether_llm.cpp` for new llama.cpp API:
      `llama_model_get_vocab()`, `llama_memory_clear(llama_get_memory(ctx))`,
      `llama_vocab_eos(vocab)`, `llama_vocab_n_tokens(vocab)`,
      `llama_token_to_piece(vocab, ...)`
- [x] `libaether_llm.so` (27KB) built at `linux/libs/libaether_llm.so`
- [x] Fixed `build_llama.sh` same-file cp false-failure

### T17 — Synastry Engine ✅
- [x] `lib/models/synastry_chart.dart` — `AspectType` (5 aspects + orbs + harmony scores),
      `SynastryAspect` (planet pair + type + orb + strength),
      `SynastryChart` (aspects list + weighted compatibility score 0–1)
- [x] `lib/services/synastry_engine.dart` — computes all planet × planet aspects
      across two `FullChart`s, includes ASC, sorts by strength
- [x] `_SynastrySection` widget in `ProfileComparisonScreen`:
      score bar with color/label, harmonious aspects (≤8), dynamic tensions (≤5)

## 🔨 Next Sprint

- [ ] Transit calculator — current sky vs natal chart overlay
- [ ] Android APK build + distribution
- [ ] Push notification: daily reading at sunrise
- [ ] Offline mode: bundle DE440 ephemeris as binary asset
- [ ] Prokerala API integration (Indian charts, 300/day free tier)
- [ ] Model manager: download Mistral-7B-v0.1.Q4_K_M.gguf (recommended model)
- [ ] Profile: add birth notes / metadata field (parents, significant events)

## 📋 Backlog

### Astrology APIs to integrate
| API | URL | Auth | What it gives |
|-----|-----|------|--------------|
| **JPL Horizons** | ssd.jpl.nasa.gov/api/horizons.api | None | Sub-arcsecond positions, 60/hr |
| **NASA APOD** | api.nasa.gov/planetary/apod | Free key | Daily cosmic image, 1000/hr |
| **IERS Bulletin B** | iers.org/data/ | None | Delta-T, UT1-UTC (download CSV) |
| **HYG Catalog** | github.com/astronexus/HYG-Database | None | 119k stars CSV |
| **Yale BSC5** | stsci.edu/fuse/catalogs/bsc5.txt | None | 9100 bright stars fixed-width |
| **Prokerala** | prokerala.com/api/ | Free key | Indian charts, nakshatras, 300/day |
| **AstrologyAPI** | astrologyapi.com | Free tier | Planets, houses, aspects, Nakshatra |

### Features
- [ ] Babylonian astrology module (MUL.APIN star catalogue, cuneiform signs)
- [ ] House system selector (Placidus, Koch, Whole Sign, Equal)
- [ ] Aspect table (conjunctions, oppositions, trines, squares, sextiles)
- [x] Transit calculator — current sky vs natal chart (Next Sprint)
- [x] Synastry / compatibility between two profiles ✅ T17
- [ ] Chart export as PDF
- [ ] Notification — daily reading push at sunrise
- [ ] Widget (Android home screen glanceable summary)
- [ ] Offline mode — bundle DE440 ephemeris as binary asset
- [ ] APOD background option — use today's NASA image as app wallpaper
