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

## 🔨 In Progress / Next Sprint

### T4 — JPL Horizons Ephemeris
**API:** https://ssd.jpl.nasa.gov/api/horizons.api — no auth, 60 req/hr
- [ ] `HorizonsService.fetchPositions(BirthContext)` — 10 HTTP calls, one per planet
- [ ] IERS Delta-T polynomial (Espenak & Meeus) applied to JDE
- [ ] Disk cache by JDE (birth charts never change → cache forever)
- [ ] Fallback to existing VSOP87 on network error
- [ ] ChartEngine.computeAsync() integrating Horizons

### T5 — IERS Delta-T Correction
**Source:** https://iers.org/data/ (Bulletin B CSV, no auth)
- [ ] Polynomial ΔT for 1986–2026 (Espenak & Meeus table)
- [ ] Apply to EphemerisService._julianDay → julianEphemerisDay
- [ ] For Paulien 1996: ΔT ≈ 61.6s; for Bernd 2000: ΔT ≈ 63.8s; for Nurse 2001: ΔT ≈ 64.1s

### T6 — HYG Star Catalog (replaces hardcoded BSC table)
**Source:** https://github.com/astronexus/HYG-Database (CSV, 119k stars)
- [ ] Download hygdata_v41.csv, filter magnitude ≤ 4.0 (~2300 stars)
- [ ] Convert RA/Dec → ecliptic longitude (J2000)
- [ ] Generate assets/data/bright_stars.json
- [ ] Update FixedStars to load from JSON asset
- [ ] Expand to top 60+ stars visible in chart (was 18 hardcoded)

### T7 — NASA APOD Home Screen Widget
**API:** https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY — free, 1000/hr
- [ ] `ApodService.fetchToday()` — daily cache in SharedPreferences
- [ ] `ApodCard` widget — CachedNetworkImage + title overlay + explanation
- [ ] Wire into home screen above traditions grid
- [ ] Handle mediaType=video gracefully (show thumbnail)

---

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
- [ ] Transit calculator — current sky vs natal chart
- [ ] Synastry / compatibility between two profiles
- [ ] Chart export as PDF
- [ ] Notification — daily reading push at sunrise
- [ ] Widget (Android home screen glanceable summary)
- [ ] Offline mode — bundle DE440 ephemeris as binary asset
- [ ] APOD background option — use today's NASA image as app wallpaper
