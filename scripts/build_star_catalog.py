#!/usr/bin/env python3
"""
Build bright star catalog from HYG Database v3.8.
Filters to magnitude <= 4.0, converts RA/Dec to ecliptic longitude,
and outputs JSON for use in Paulien's Sky app.
"""

import json
import math
import csv
import gzip
import io
import os
import requests

# Constants
HYG_URL = "https://github.com/astronexus/HYG-Database/raw/main/hyg/v3/hyg_v38.csv.gz"
OUTPUT_PATH = "/home/kilisan/dev/pauliens_sky/assets/data/bright_stars.json"
MAG_LIMIT = 4.0
EPSILON_DEG = 23.4392911  # obliquity of ecliptic J2000


def ra_dec_to_ecliptic_lon(ra_hours: float, dec_deg: float) -> float:
    """Convert RA (hours) and Dec (degrees) to ecliptic longitude (degrees, 0-360)."""
    eps = math.radians(EPSILON_DEG)
    ra_rad = ra_hours * 15.0 * math.pi / 180.0
    dec_rad = math.radians(dec_deg)

    lon_rad = math.atan2(
        math.sin(ra_rad) * math.cos(eps) + math.tan(dec_rad) * math.sin(eps),
        math.cos(ra_rad)
    )
    lon_deg = math.degrees(lon_rad)
    # Normalize to 0-360
    lon_deg = lon_deg % 360.0
    return round(lon_deg, 4)


def main():
    print(f"Downloading HYG database from:\n  {HYG_URL}")
    response = requests.get(HYG_URL, timeout=120)
    response.raise_for_status()
    print(f"Downloaded {len(response.content) / 1024:.1f} KB (gzipped)")

    raw_bytes = gzip.decompress(response.content)
    text = raw_bytes.decode("utf-8")
    stars = []
    reader = csv.DictReader(io.StringIO(text))

    for row in reader:
        # Skip rows with no RA/Dec (e.g., the sun entry where ra == 0 and dec == 0
        # and hip is empty)
        ra_str = row.get("ra", "").strip()
        dec_str = row.get("dec", "").strip()
        hip_str = row.get("hip", "").strip()
        mag_str = row.get("mag", "").strip()

        # Skip sun (hip is empty/0 and ra/dec are 0)
        if not ra_str or not dec_str or not mag_str:
            continue

        try:
            ra = float(ra_str)
            dec = float(dec_str)
            mag = float(mag_str)
        except ValueError:
            continue

        # Skip sun entry: hip is blank/0, ra == 0.0, dec == 0.0
        if not hip_str or hip_str == "0":
            continue

        if mag > MAG_LIMIT:
            continue

        hip = int(hip_str)
        proper = row.get("proper", "").strip()
        name = proper if proper else f"HIP{hip}"

        dist_str = row.get("dist", "").strip()
        try:
            dist = round(float(dist_str), 4) if dist_str else None
        except ValueError:
            dist = None

        spect = row.get("spect", "").strip()

        ecliptic_lon = ra_dec_to_ecliptic_lon(ra, dec)

        stars.append({
            "name": name,
            "hip": hip,
            "mag": round(mag, 4),
            "lon": ecliptic_lon,
            "ra": round(ra, 5),
            "dec": round(dec, 5),
            "dist": dist,
            "spect": spect,
        })

    # Sort by magnitude (brightest first = most negative/smallest value)
    stars.sort(key=lambda s: s["mag"])

    catalog = {
        "version": "HYG-3.8",
        "count": len(stars),
        "stars": stars,
    }

    # Ensure output directory exists
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(catalog, f, separators=(",", ":"), ensure_ascii=False)

    print(f"\nDone.")
    print(f"Stars included (mag <= {MAG_LIMIT}): {len(stars)}")
    print(f"Output written to: {OUTPUT_PATH}")
    print(f"Brightest star: {stars[0]['name']} (mag {stars[0]['mag']}, lon {stars[0]['lon']}°)")


if __name__ == "__main__":
    main()
