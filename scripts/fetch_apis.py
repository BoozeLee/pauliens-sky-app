#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "requests>=2.31",
#   "rich>=13",
# ]
# ///
"""
fetch_apis.py — Semi-interactive API data fetcher for Paulien's Sky.

Commands:
  uv run scripts/fetch_apis.py --apod
  uv run scripts/fetch_apis.py --horizons --profile kiliaan
  uv run scripts/fetch_apis.py --iers
  uv run scripts/fetch_apis.py --all
"""

import argparse
import csv
import gzip
import io
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import requests
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

ROOT   = Path(__file__).parent.parent
DATA   = ROOT / "assets" / "data"

console = Console()

# ── Profile birth dates (UTC) ─────────────────────────────────────────────────

_PROFILES = {
    "paulien": {
        "name": "Paulien",
        "utc":  "1996-03-13 08:00",
        "lat":  50.9311,
        "lon":  5.3378,
    },
    "nurse": {
        "name": "Nurse",
        "utc":  "2001-10-12 05:00",
        "lat":  51.3225,
        "lon":  4.9436,
    },
    "bernd": {
        "name": "Bernd",
        "utc":  "2000-02-23 14:00",
        "lat":  50.8167,
        "lon":  5.1833,
    },
    "kiliaan": {
        "name": "Kiliaan",
        "utc":  "1986-04-20 09:11",
        "lat":  50.8798,
        "lon":  4.7005,
    },
}

# ── NASA APOD ─────────────────────────────────────────────────────────────────

def fetch_apod() -> None:
    console.rule("[bold cyan]NASA APOD — Astronomy Picture of the Day")
    url = "https://api.nasa.gov/planetary/apod"
    params = {"api_key": "DEMO_KEY", "thumbs": "true"}

    with console.status("Fetching from api.nasa.gov…"):
        r = requests.get(url, params=params, timeout=15)
        r.raise_for_status()
        data = r.json()

    t = Table(show_header=False, box=None, padding=(0, 1))
    t.add_column(style="bold cyan", width=14)
    t.add_column()
    t.add_row("Date",        data.get("date", ""))
    t.add_row("Title",       data.get("title", ""))
    t.add_row("Media type",  data.get("media_type", ""))
    t.add_row("Copyright",   data.get("copyright", "N/A"))
    t.add_row("URL",         data.get("url", ""))
    console.print(t)

    expl = data.get("explanation", "")
    console.print(Panel(expl[:600] + ("…" if len(expl) > 600 else ""),
                        title="Explanation", border_style="cyan"))
    console.print(f"\n[dim]Full URL: {data.get('url', '')}[/dim]")

# ── JPL Horizons ──────────────────────────────────────────────────────────────

_PLANET_IDS = {
    "Sun": "10", "Moon": "301", "Mercury": "199", "Venus": "299",
    "Mars": "499", "Jupiter": "599", "Saturn": "699",
    "Uranus": "799", "Neptune": "899", "Pluto": "999",
}

def _horizons_time(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d+%H:%M")

def _parse_lon(text: str) -> float | None:
    import re
    soe = text.find("$$SOE")
    eoe = text.find("$$EOE")
    if soe < 0 or eoe < 0:
        return None
    block = text[soe+5:eoe].strip()
    line  = next((l for l in block.split("\n") if l.strip()), "")
    nums  = [float(m.group()) for m in re.finditer(r"-?\d+\.\d+", line)]
    return nums[0] if nums else None

def fetch_horizons(profile_key: str) -> None:
    p = _PROFILES.get(profile_key)
    if not p:
        console.print(f"[red]Unknown profile: {profile_key}[/red]")
        return

    console.rule(f"[bold magenta]JPL Horizons — {p['name']} birth positions")
    dt_utc = datetime.strptime(p["utc"], "%Y-%m-%d %H:%M").replace(tzinfo=timezone.utc)
    dt_stop = dt_utc.replace(hour=dt_utc.hour + 1 if dt_utc.hour < 23 else 23)

    base = "https://ssd.jpl.nasa.gov/api/horizons.api"
    t = Table(title=f"{p['name']} — {p['utc']} UTC", header_style="bold magenta")
    t.add_column("Planet", style="cyan")
    t.add_column("Ecliptic Lon (°)", justify="right")
    t.add_column("Zodiac Sign", style="yellow")

    signs = ["Aries","Taurus","Gemini","Cancer","Leo","Virgo",
             "Libra","Scorpio","Sagittarius","Capricorn","Aquarius","Pisces"]

    for name, body_id in _PLANET_IDS.items():
        params = {
            "format":     "json",
            "COMMAND":    f"'{body_id}'",
            "OBJ_DATA":   "'NO'",
            "MAKE_EPHEM": "'YES'",
            "EPHEM_TYPE": "'OBSERVER'",
            "CENTER":     "'500@399'",
            "START_TIME": f"'{_horizons_time(dt_utc)}'",
            "STOP_TIME":  f"'{_horizons_time(dt_stop)}'",
            "STEP_SIZE":  "'1h'",
            "QUANTITIES": "'31'",
            "ANG_FORMAT": "'DEG'",
        }
        try:
            resp = requests.get(base, params=params, timeout=20)
            resp.raise_for_status()
            result = resp.json().get("result", "")
            lon = _parse_lon(result)
            if lon is not None:
                sign = signs[int(lon / 30) % 12]
                deg  = lon % 30
                t.add_row(name, f"{lon:.4f}°", f"{deg:.1f}° {sign}")
            else:
                t.add_row(name, "parse error", "—")
        except Exception as e:
            t.add_row(name, f"[red]{e}[/red]", "—")

    console.print(t)

# ── IERS Delta-T ──────────────────────────────────────────────────────────────

def fetch_iers() -> None:
    console.rule("[bold yellow]IERS Bulletin B — Delta-T / UT1-UTC")

    # IERS finals2000A has UT1-UTC (column MJD, UT1-UTC)
    url = "https://datacenter.iers.org/data/csv/finals2000A.all.csv"
    out_path = DATA / "delta_t.json"

    with console.status("Downloading IERS finals2000A.all.csv…"):
        try:
            r = requests.get(url, timeout=30)
            r.raise_for_status()
        except Exception as e:
            console.print(f"[red]IERS CSV download failed: {e}[/red]")
            console.print("[yellow]Falling back to Espenak & Meeus polynomial (already embedded in HorizonsService.deltaT())[/yellow]")
            return

    reader = csv.DictReader(io.StringIO(r.text))
    rows = []
    for row in reader:
        try:
            mjd = float(row.get("MJD", row.get("mjd", "")))
            ut1utc = float(row.get("UT1-UTC", row.get("ut1utc", row.get("UT1UTC", ""))))
            rows.append({"mjd": round(mjd, 1), "ut1utc": round(ut1utc, 6)})
        except (ValueError, KeyError):
            continue

    if not rows:
        console.print("[yellow]Could not parse IERS CSV — check column names[/yellow]")
        return

    DATA.mkdir(parents=True, exist_ok=True)
    out = {
        "source": url,
        "fetched": datetime.now(timezone.utc).isoformat(),
        "count":   len(rows),
        "rows":    rows[-365:],  # keep last ~1 year for file size
    }
    out_path.write_text(json.dumps(out, separators=(",", ":")))
    console.print(f"[green]✓ IERS data saved: {len(rows)} entries → {out_path}[/green]")
    console.print(f"  Latest MJD: {rows[-1]['mjd']}, UT1-UTC: {rows[-1]['ut1utc']}s")

# ── All APIs ──────────────────────────────────────────────────────────────────

def main() -> None:
    parser = argparse.ArgumentParser(description="Paulien's Sky — API data fetcher")
    parser.add_argument("--apod",     action="store_true", help="Fetch NASA APOD")
    parser.add_argument("--horizons", action="store_true", help="Fetch JPL Horizons")
    parser.add_argument("--iers",     action="store_true", help="Download IERS Bulletin B")
    parser.add_argument("--all",      action="store_true", help="Run all fetches")
    parser.add_argument("--profile",  default="kiliaan",
                        choices=list(_PROFILES),
                        help="Profile for Horizons fetch")
    args = parser.parse_args()

    if not any([args.apod, args.horizons, args.iers, args.all]):
        parser.print_help()
        return

    if args.apod or args.all:
        fetch_apod()
        console.print()

    if args.horizons or args.all:
        fetch_horizons(args.profile)
        console.print()

    if args.iers or args.all:
        fetch_iers()


if __name__ == "__main__":
    main()
