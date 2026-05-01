# Paulien's Sky — Integration Report v2.0.0
**Generated:** 2026-05-01 (updated Sprint 3)
**Repo:** https://github.com/BoozeLee/pauliens-sky-app  
**Branch:** master (tagged v2.0.0, Sprint 3 in progress)  
**Stack:** Flutter 3.x / Dart, Linux + Android targets, uv Python scripts

---

## What This App Is

A cultural astrology engine that computes and synthesises birth charts across **7 traditions simultaneously** (Western, Vedic, Chinese/BaZi, Mayan/Tzolk'in, Egyptian, Celtic, Zoroastrian). It has a local AI (llama.cpp), cloud AI (Claude + Gemini), NASA data feeds, and a cross-profile personality comparison system. All features are freemium (V2).

---

## Profiles (4 People)

| Profile | DOB | Time | UTC | Location | ASC |
|---------|-----|------|-----|----------|-----|
| **Paulien** | 13 Mar 1996 | 09:00 CET | 08:00 | Hasselt, BE | — |
| **Nurse** | 12 Oct 2001 | 07:00 CEST | 05:00 | Turnhout, BE | — |
| **Bernd** | 23 Feb 2000 | 15:00 CET | 14:00 | Sint-Truiden, BE | — |
| **Kiliaan** | 20 Apr 1986 | **11:11 CEST** | 09:11 | Leuven, BE | **Cancer 19°** |

**Kiliaan's chart (computed):**
- Sun: Taurus 0.3° (born right at Aries→Taurus ingress)
- ASC: Cancer 19° · MC: Pisces 19.8°
- Vedic Sun: Aries 6.7°, Nakshatra: **Ashwini** (healer twins)
- Chinese: **Fire Tiger** (1986)
- Celtic: **Willow (Saille)** — Apr 15–May 12
- Zoroastrian: **Ardibehesht 1st day** (Asha Vahishta — Truth & Order)
- 11:11 = Master Number gateway
- Parents: Ingrid & Walter

---

## Architecture

```
lib/
├── models/
│   ├── profile.dart          — 4 static profiles + toJson/fromJson
│   ├── birth_context.dart    — UTC time + lat/lon + person name
│   ├── astro_snapshot.dart   — AstroSnapshot, PlanetPosition, Planet enum
│   └── culture_chart.dart    — CultureChart, CultureId enum (8 values incl. babylonian)
├── services/
│   ├── ephemeris_service.dart     — VSOP87 Sun/Moon/planets (offline)
│   ├── chart_engine.dart          — compute() sync + computeAsync() Horizons-first
│   ├── horizons_service.dart      — JPL Horizons API, Delta-T, JDE cache
│   ├── apod_service.dart          — NASA APOD daily image
│   ├── premium_service.dart       — V2 freemium, secure key storage
│   ├── ai_orchestrator.dart       — routes AETHER → Claude → Gemini → None
│   ├── ai_service.dart            — Anthropic + Gemini HTTP clients
│   ├── locale_service.dart        — EN/NL toggle
│   ├── ui_schema.dart             — JSON-driven visual language loader
│   ├── fixed_stars.dart           — Behenian stars (18 hardcoded — upgrade pending)
│   └── local_llm/
│       ├── llama_service.dart     — llama.cpp isolate + FFI
│       ├── llama_ffi.dart         — libaether_llm.so bindings
│       ├── penta_prompt.dart      — 5-layer prompt builder (in-app)
│       ├── astro_rag.dart         — TF-IDF RAG over corpus.json
│       └── memory_journal.dart    — JSONL rolling memory
├── screens/
│   ├── home_screen.dart           — Profile card, APOD widget, Compare button, traditions grid
│   ├── chart_screen.dart          — 7-tab tradition viewer
│   ├── profile_comparison_screen.dart — Shared traits, radar bars, signs by tradition
│   ├── ai_screen.dart             — Chat, daily reading, chart reading (status dots)
│   ├── personality_screen.dart    — Radar chart + core traits
│   ├── settings_screen.dart       — API keys, locale, profile management
│   └── ...
├── cultures/
│   ├── western/    ├── vedic/    ├── chinese/    ├── mayan/
│   ├── egyptian/   ├── celtic/   └── zoroastrian/
└── widgets/
    ├── apod_card.dart      — NASA APOD expandable card
    ├── zodiac_wheel.dart   — Dual-ring tropical + sidereal SVG wheel
    ├── personality_radar.dart
    ├── daily_reading_card.dart
    └── ...
```

---

## External APIs Integrated

| API | Status | Service file | Cache |
|-----|--------|-------------|-------|
| JPL Horizons | ✅ live | horizons_service.dart | SharedPrefs by JDE key (forever) |
| NASA APOD | ✅ live | apod_service.dart | Daily SharedPrefs |
| HYG Star Catalog | ✅ built | scripts/build_star_catalog.py | assets/data/bright_stars.json |
| IERS Bulletin B | ✅ script | scripts/fetch_apis.py --iers | assets/data/delta_t.json |
| Anthropic Claude | ✅ keyed | ai_service.dart | None (live) |
| Google Gemini | ✅ keyed | ai_service.dart | None (live) |
| llama.cpp (AETHER) | ⚠️ needs .so | llama_service.dart | On-device GGUF |

---

## AI System

### Routing (AiOrchestrator)
1. **AETHER local** — if `libaether_llm.so` compiled + GGUF model downloaded
2. **Claude** — if Anthropic API key in settings
3. **Gemini** — if Google API key in settings
4. **None** — error state, message shown

### Status
- **Cloud AI (Claude/Gemini)**: ✅ fully working — enter key in Settings → instant AI chat
- **Local AI (AETHER)**: ⚠️ needs build step — `scripts/build_llama.sh` compiles the .so, then use Model Manager to download a GGUF (recommended: Mistral-7B-v0.1.Q4_K_M.gguf ~4GB)

### Penta-Layer Prompt (both in-app and CLI)
1. TF-IDF RAG over 40+ classical astrology passages
2. JSONL memory journal (last 5-12 readings per profile)
3. Birth chart context (all 7 traditions)
4. Tradition culture frame (7 available)
5. User query

### CLI Oracle
```bash
uv run scripts/penta_mind.py --profile kiliaan --query "My soul's purpose" --culture zoroastrian
uv run scripts/penta_mind.py --list-traditions
uv run scripts/penta_mind.py --no-api  # print prompt only
```
Requires: `ANTHROPIC_API_KEY` env var for live responses.

---

## Developer Tooling

```bash
make build          # flutter build linux --release
make run            # flutter run -d linux
make apod           # fetch today's APOD to terminal
make horizons PROFILE=kiliaan  # fetch birth positions
make stars          # rebuild HYG catalog (518 stars)
make iers           # update Delta-T table
make penta PROFILE=kiliaan QUERY="..." CULTURE=western
make tasks          # interactive task runner (TUI)
make tasks-auto     # auto-run tasks with matching scripts
make status         # git status + log
```

---

## Security

| Platform | API Key Storage |
|----------|----------------|
| Android | EncryptedSharedPreferences (Android Keystore) |
| iOS | Keychain Services |
| Linux desktop | SharedPreferences (acceptable for dev machine) |

Migration: old SharedPrefs keys auto-migrate to secure storage on first app run (mobile only).

---

## Current Task List

### ✅ Completed (v2.0.0)
- Core app: 5-tab nav, cosmic theme, star background, EN/NL locale
- 7 tradition chart engine (Western, Vedic, Chinese, Mayan, Egyptian, Celtic, Zoroastrian)
- 4 profiles: Paulien, Nurse, Bernd, Kiliaan
- Profile comparison screen (traits, radar, signs by tradition)
- AI system: AETHER + Claude + Gemini + orchestrator + penta-prompt
- JPL Horizons real positions (T4) + IERS Delta-T (T5)
- HYG star catalog 518 stars (T6) + NASA APOD widget (T7)
- Secure API key storage (T12) + AI status indicator (T13)
- Makefile + task_runner.py + fetch_apis.py (T14)
- Corpus expansion 40+ passages (T15) + omarchy desktop entry (T10)
- V2 freemium — all features unlocked

### 🔨 Next Sprint
- [ ] **FixedStars**: load from `assets/data/bright_stars.json` (currently 18 hardcoded Behenian stars — should use the 518-star HYG catalog)
- [ ] **AETHER build**: compile `libaether_llm.so` for Linux + Android arm64
- [ ] **Model download**: add Mistral-7B GGUF to Model Manager auto-download
- [ ] **Synastry**: compatibility engine between two profiles
- [ ] **Transits**: current sky vs natal chart overlay
- [ ] **Prokerala API**: Indian charts, 300/day free tier

### 📋 Backlog
- Android APK build + distribution
- Push notification: daily reading at sunrise
- Offline DE440 ephemeris bundle
- Babylonian tradition module (MUL.APIN)
- House system selector (Placidus, Koch, Whole Sign, Equal)
- Aspect table (conjunctions, oppositions, trines, squares, sextiles)
- Chart export as PDF
- Android home screen glanceable widget
- Profile metadata field (parents, birth notes)

---

## How to Continue in a Fresh Session

Paste this at the start of a new conversation:

> **Context:** I'm working on "Paulien's Sky" — a Flutter cultural astrology app at `/home/kilisan/dev/pauliens_sky`. GitHub: `https://github.com/BoozeLee/pauliens-sky-app`. Latest tag: v2.0.0. See `INTEGRATION_REPORT.md` and `TASKS.md` for full state. The next priority tasks are listed under "🔨 Next Sprint" above. [then describe what you want to work on]
