# Pauliens Sky

One sky, many traditions. Pauliens Sky is a Flutter astrology app that compares cultural sky systems through a polished mobile/web interface, offline-first interpretation logic, and optional AI-assisted readings.

## What It Demonstrates

- Cross-platform Flutter delivery for web, iOS, Android, Linux, macOS, and Windows.
- Domain modeling across Western, Vedic, Chinese, Mayan, Egyptian, Celtic, and Zoroastrian traditions.
- Provider-based state management with chart, profile, synastry, art, and settings flows.
- Offline fallback behavior for core readings, with optional hosted AI proxy integration.
- Professional product UI with share cards, personality views, fixed-star context, daily readings, and premium gates.

## Stack

- **App:** Flutter, Dart 3, Material UI
- **State:** `provider`
- **Data and services:** local cultural modules, ephemeris/Horizons services, APOD integration
- **Storage:** `shared_preferences`, `flutter_secure_storage`
- **AI path:** optional Vercel/NVIDIA proxy plus local AETHER fallback
- **Quality gates:** `flutter analyze`, `flutter test`, `flutter build web`

## Project Structure

```text
lib/
├── app.dart                         # App shell and navigation
├── cultures/                        # Cultural astrology modules and datasets
├── models/                          # Birth context, chart, profile, synastry models
├── screens/                         # Product screens
├── services/                        # Chart, AI, ephemeris, locale, art, APOD services
├── state/                           # App state
├── theme/                           # Cosmic visual system
└── widgets/                         # Reusable UI components

web/                                 # Flutter web shell and icons
test/                                # Widget tests
```

## Local Development

```bash
flutter pub get
flutter run -d chrome
```

For production web validation:

```bash
flutter analyze
flutter test
flutter build web --release
```

## Optional Environment

The core app works without hosted AI. To enable the deployed AI proxy path, configure:

| Variable | Purpose |
| --- | --- |
| `NVIDIA_API_KEY` | Server-side key for NVIDIA NIM/NVCF proxy functions |
| `PAULIENS_SKY_AI_PROXY_URL` | App-facing AI proxy URL |
| `PAULIENS_SKY_APP_URL` | Public app base URL used by generated assets |

Local-only client config can live in `.env.client.local`; do not commit API keys.

## Deployment

The public web build is deployed at:

```text
https://pauliens-sky-app.vercel.app
```

Before publishing a release, run the validation commands above and confirm the web build loads the main navigation, chart flow, and AI fallback path.

## Status

Portfolio project. The repository is public to show Flutter architecture, cross-cultural domain modeling, and product polish. Secrets, production credentials, and private deployment configuration are intentionally excluded.
