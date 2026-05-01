.PHONY: help build run clean apod horizons-paulien horizons-kiliaan stars iers penta-paulien penta-kiliaan all-apis push

FLUTTER   := flutter
UV        := uv
PROFILE   ?= paulien
QUERY     ?= What is my soul's deepest calling?
CULTURE   ?= western

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-22s\033[0m %s\n",$$1,$$2}'

# ── Flutter ───────────────────────────────────────────────────────────────────

build: ## Build Linux release bundle
	$(FLUTTER) build linux --release

run: ## Run on Linux desktop
	$(FLUTTER) run -d linux

android: ## Build Android APK (debug)
	$(FLUTTER) build apk --debug

clean: ## Clean build artifacts
	$(FLUTTER) clean

deps: ## Get/update Flutter dependencies
	$(FLUTTER) pub get

# ── API data tools ────────────────────────────────────────────────────────────

apod: ## Fetch today's NASA APOD to terminal
	$(UV) run scripts/fetch_apis.py --apod

horizons: ## Fetch JPL Horizons positions (PROFILE=paulien|nurse|bernd|kiliaan)
	$(UV) run scripts/fetch_apis.py --horizons --profile $(PROFILE)

horizons-paulien: ## Fetch Horizons for Paulien's birth
	$(UV) run scripts/fetch_apis.py --horizons --profile paulien

horizons-kiliaan: ## Fetch Horizons for Kiliaan's birth
	$(UV) run scripts/fetch_apis.py --horizons --profile kiliaan

stars: ## Rebuild HYG bright star catalog (mag ≤ 4.0, 518 stars)
	$(UV) run scripts/build_star_catalog.py

iers: ## Download latest IERS Bulletin B Delta-T data
	$(UV) run scripts/fetch_apis.py --iers

all-apis: apod iers stars ## Run all API data fetches (Horizons skipped — per-profile)

# ── AETHER Penta-Mind ─────────────────────────────────────────────────────────

penta: ## Run penta-mind oracle (PROFILE=x QUERY="..." CULTURE=western)
	$(UV) run scripts/penta_mind.py --profile $(PROFILE) --query "$(QUERY)" --culture $(CULTURE)

penta-paulien: ## Quick oracle reading for Paulien
	$(UV) run scripts/penta_mind.py --profile paulien --query "What does my Pisces Sun say about my path?" --culture western

penta-kiliaan: ## Quick oracle reading for Kiliaan
	$(UV) run scripts/penta_mind.py --profile kiliaan --query "What do my Cancer Ascendant and early Taurus Sun reveal?" --culture western

penta-all: ## Run oracle for all four profiles
	$(UV) run scripts/penta_mind.py --profile paulien  --query "Soul's calling" --no-api
	$(UV) run scripts/penta_mind.py --profile nurse    --query "Soul's calling" --no-api
	$(UV) run scripts/penta_mind.py --profile bernd    --query "Soul's calling" --no-api
	$(UV) run scripts/penta_mind.py --profile kiliaan  --query "Soul's calling" --no-api

# ── Task runner ───────────────────────────────────────────────────────────────

tasks: ## Interactive task runner (parses TASKS.md)
	$(UV) run scripts/task_runner.py

tasks-auto: ## Auto-run tasks that have matching scripts
	$(UV) run scripts/task_runner.py --auto

# ── Git / deploy ──────────────────────────────────────────────────────────────

push: ## Commit all uncommitted changes and push to GitHub
	@echo "Staging all changes..."
	git add -A
	@read -p "Commit message: " msg; git commit -m "$$msg"
	git push origin main

status: ## Show git status + recent log
	git status --short
	@echo ""
	git log --oneline -8
