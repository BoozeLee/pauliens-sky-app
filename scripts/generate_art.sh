#!/usr/bin/env bash
# generate_art.sh — create per-tradition hero backgrounds via ImageMagick 7
# Requires: magick (ImageMagick 7)
# Output: assets/art/{tradition}_bg.png  (420×860 each)
#
# Compositing layers:
#   1. Deep-space dark navy gradient base
#   2. Tradition-colour tinted star dots (via MVG draw file)
#   3. Large watermark glyph at low opacity (skipped if font missing)
#   4. Radial vignette

set -euo pipefail
cd "$(dirname "$0")/.."

command -v magick >/dev/null 2>&1 || { echo "imagemagick 7 (magick) not found"; exit 1; }

OUT="assets/art"
W=420
H=860
TMPDIR_ART="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_ART"' EXIT

traditions=(western vedic chinese mayan egyptian celtic)
declare -A COLORS=([western]="0,245,255" [vedic]="255,152,0" [chinese]="255,110,199"
                   [mayan]="255,213,79" [egyptian]="255,241,118" [celtic]="105,240,174")
declare -A GLYPHS=([western]="♈" [vedic]="OM" [chinese]="龍"
                   [mayan]="☀" [egyptian]="Eye" [celtic]="✿")
declare -A DENSITIES=([western]=120 [vedic]=80 [chinese]=60
                      [mayan]=40 [egyptian]=50 [celtic]=90)

for TRAD in "${traditions[@]}"; do
  RGB="${COLORS[$TRAD]}"
  DENSITY="${DENSITIES[$TRAD]}"
  GLYPH="${GLYPHS[$TRAD]}"
  OUT_FILE="$OUT/${TRAD}_bg.png"

  R=$(echo "$RGB" | cut -d, -f1)
  G=$(echo "$RGB" | cut -d, -f2)
  B=$(echo "$RGB" | cut -d, -f3)

  echo "→ $TRAD  rgb=($RGB)  glyph=$GLYPH  stars=$DENSITY"

  # ── 1. Dark navy gradient base ─────────────────────────────────────────
  magick -size ${W}x${H} \
    gradient:"#0A0520-#1A1040" \
    "$TMPDIR_ART/base.png"

  # ── 2. Generate MVG star draw commands via Python ──────────────────────
  python3 - "$TMPDIR_ART/stars.mvg" "$DENSITY" "$W" "$H" "$R" "$G" "$B" <<'PYEOF'
import sys, random, math
outfile, density, W, H, R, G, B = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]), int(sys.argv[6]), int(sys.argv[7])
random.seed(hash(outfile))
lines = ["push graphic-context", "stroke none"]
for _ in range(density):
    x = random.randint(2, W - 3)
    y = random.randint(2, H - 3)
    r = random.uniform(0.5, 1.8)
    a = random.uniform(0.3, 0.9)
    # White stars
    ai = int(a * 255)
    lines.append(f"fill 'rgba(255,255,255,{a:.2f})'")
    lines.append(f"circle {x},{y} {x+r:.1f},{y}")
    # Colour-tinted secondary star layer (sparser, smaller)
    if random.random() < 0.35:
        x2 = random.randint(2, W - 3)
        y2 = random.randint(2, H - 3)
        r2 = random.uniform(0.3, 1.2)
        a2 = random.uniform(0.15, 0.45)
        lines.append(f"fill 'rgba({R},{G},{B},{a2:.2f})'")
        lines.append(f"circle {x2},{y2} {x2+r2:.1f},{y2}")
lines.append("pop graphic-context")
with open(outfile, "w") as f:
    f.write("\n".join(lines) + "\n")
print(f"  wrote {len(lines)} MVG lines to {outfile}")
PYEOF

  # ── 3. Apply star layer over base ─────────────────────────────────────
  magick "$TMPDIR_ART/base.png" \
    -draw "@$TMPDIR_ART/stars.mvg" \
    "$TMPDIR_ART/stars.png"

  # ── 4. Colour tint wash ───────────────────────────────────────────────
  magick "$TMPDIR_ART/stars.png" \
    \( +clone -alpha extract -fill "rgb($R,$G,$B)" -colorize 100 \) \
    \( -clone 0 -alpha extract \) \
    -delete 1 \
    \( -size ${W}x${H} xc:"rgba($R,$G,$B,0.15)" \) \
    -compose Over -composite \
    "$TMPDIR_ART/tinted.png"

  # ── 5. Vignette (darken edges) ────────────────────────────────────────
  magick "$TMPDIR_ART/tinted.png" \
    \( -size ${W}x${H} radial-gradient:"rgba(0,0,0,0)"-"rgba(0,0,0,0.6)" \) \
    -compose Multiply -composite \
    "$OUT_FILE"

  echo "   ✓  $OUT_FILE ($(du -h "$OUT_FILE" | cut -f1))"
done

echo ""
echo "Done! Generated $(ls "$OUT"/*_bg.png 2>/dev/null | wc -l) tradition backgrounds in $OUT/"
