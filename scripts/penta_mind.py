#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "anthropic>=0.40",
#   "numpy>=1.26",
#   "scikit-learn>=1.4",
#   "rich>=13",
# ]
# ///
"""
AETHER Penta-Mind — five-layer esoteric AI oracle for Paulien's Sky.

Layers (innermost → outermost):
  1. CORPUS    — TF-IDF RAG over classical astrology texts (local)
  2. MEMORY    — JSONL rolling journal of past readings
  3. CONTEXT   — birth chart snapshot (planets, signs, aspects)
  4. CULTURE   — tradition-specific mythological frame
  5. QUERY     — user's question / intention

Usage:
  uv run scripts/penta_mind.py --profile paulien --query "What does my Venus say about love?"
  uv run scripts/penta_mind.py --profile bernd   --culture vedic --query "My dharma path"
  uv run scripts/penta_mind.py --list-traditions
"""

import argparse
import json
import math
import os
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

# ── Paths ─────────────────────────────────────────────────────────────────────

ROOT    = Path(__file__).parent.parent
DATA    = ROOT / "assets" / "data"
MEMORY  = ROOT / "assets" / "data" / "penta_memory.jsonl"
CORPUS  = ROOT / "assets" / "data" / "corpus.json"

# ── Built-in mini-corpus ──────────────────────────────────────────────────────
# Embedded so the script works without external files.

_CORPUS = [
    # ── Western ──────────────────────────────────────────────────────────────
    {"id": "ptolemy_1", "tradition": "western",
     "text": "Venus governs love, beauty, pleasure, and the aesthetic faculty of the soul. "
             "When well-placed she brings harmony; afflicted, excess and indulgence."},
    {"id": "ptolemy_2", "tradition": "western",
     "text": "Mars is the principle of energy, courage, and conflict. He separates and divides "
             "but also protects. His nature is hot and dry, masculine and diurnal."},
    {"id": "ptolemy_3", "tradition": "western",
     "text": "The Moon is the mirror of the Sun's light, governing the body, the humours, "
             "and the subconscious tides of the soul. Her phase at birth shapes emotional nature."},
    {"id": "ptolemy_4", "tradition": "western",
     "text": "Pisces is the last sign of the zodiac, a sign of completion and dissolution. "
             "Its natives carry the memory of all twelve signs and yearn for the infinite. "
             "Their gift is compassion; their challenge, boundaries."},
    {"id": "ptolemy_5", "tradition": "western",
     "text": "Taurus is the fixed earth sign ruled by Venus. Those born under it seek beauty, "
             "stability, and the pleasures of the senses. They build slowly and endure permanently. "
             "The early degrees of Taurus carry the cusp energy of the Ram's ending — a fire "
             "that grounds itself into form, combining Aries initiative with Taurine persistence."},
    {"id": "ptolemy_6", "tradition": "western",
     "text": "Cancer rising bestows a face that reflects the Moon's changing light — empathic, "
             "protective, and deeply perceptive. Those with Cancer Ascendant wear their feelings "
             "like armour and nurture those in their orbit as a mother guards her children."},
    {"id": "ptolemy_7", "tradition": "western",
     "text": "The Ascendant is the mask through which the soul enters the world — the lens of "
             "first impressions. It colours the body, the manner, and the instinctive response. "
             "The Ascendant sign is as powerful as the Sun sign in shaping external expression."},
    {"id": "fixed_1", "tradition": "western",
     "text": "Sirius, the brightest fixed star, confers ambition, fame, and a burning will "
             "when conjunct the Ascendant or luminaries. Ancient mariners called it the guardian star."},
    {"id": "fixed_2", "tradition": "western",
     "text": "Regulus at the heart of Leo bestows nobility, leadership, and the demand for justice. "
             "Its shift in 2012 into Virgo added a quality of humble service to its regality."},
    {"id": "fixed_3", "tradition": "western",
     "text": "Aldebaran, the Eye of the Bull and one of the four Royal Stars, promises honour "
             "and success when prominent at birth, but demands integrity — it gives as freely "
             "as it takes when principles are violated."},
    # ── Vedic ────────────────────────────────────────────────────────────────
    {"id": "brihat_1", "tradition": "vedic",
     "text": "The Moon in the nakshatra of Rohini bestows a pleasant appearance, "
             "eloquence, and love of beauty. The native is fond of luxuries and art."},
    {"id": "brihat_2", "tradition": "vedic",
     "text": "Saturn in the seventh bhava causes delay in marriage but, if exalted or in own sign, "
             "grants a partner of endurance and loyalty. The native learns union through patience."},
    {"id": "brihat_3", "tradition": "vedic",
     "text": "Ashwini nakshatra (0°–13°20' Aries) is ruled by the twin physicians of the gods, "
             "the Ashvins. Its symbol is a horse's head. Those born under Ashwini are swift, "
             "pioneering healers with the gift of rapid transformation and renewal."},
    {"id": "brihat_4", "tradition": "vedic",
     "text": "The Sun in Aries in the sidereal zodiac occupies its sign of exaltation at 10° Aries. "
             "Such a Sun grants tremendous vitality, leadership, and the courage of the first — "
             "the soul who steps forward when others wait."},
    {"id": "brihat_5", "tradition": "vedic",
     "text": "Pisces (Meena) in the Vedic tradition is the final rashi, the sign of moksha. "
             "Jupiter's own house, it bestows wisdom, devotion, and the gift of transcendence. "
             "Those with strong Pisces placements are drawn to the spiritual path in every tradition."},
    # ── Chinese ──────────────────────────────────────────────────────────────
    {"id": "bazi_1", "tradition": "chinese",
     "text": "Wood Day Master craves growth, creativity, and recognition. "
             "They bend like bamboo — flexible yet rooted — and thrive when given space to expand."},
    {"id": "bazi_2", "tradition": "chinese",
     "text": "The Rat year brings intelligence, adaptability, and hidden reserves. "
             "Those born in Rat years find opportunities where others see obstacles."},
    {"id": "bazi_3", "tradition": "chinese",
     "text": "The Fire Tiger (1986) is the most magnetic of all Tigers — charismatic, "
             "restless, visionary, and irresistibly drawn to the next horizon. "
             "Fire feeds the Tiger's natural courage into a roaring, inspiring flame."},
    {"id": "bazi_4", "tradition": "chinese",
     "text": "Tiger people challenge authority and resist constraint. Their purpose is to "
             "lead, to protect the weak, and to break the patterns that hold others captive. "
             "They are born rebels with noble hearts — generosity runs deeper than their pride."},
    {"id": "bazi_5", "tradition": "chinese",
     "text": "The Metal Snake (2001) is precise, strategic, and deeply intuitive. "
             "Snakes shed their skin to become anew — in the Metal element, this renewal "
             "takes a calculated, artistic, and quietly determined form."},
    # ── Mayan ────────────────────────────────────────────────────────────────
    {"id": "mayan_1", "tradition": "mayan",
     "text": "Kin Ben (Reed/Corn) carries the staff of the sky-walker. "
             "Ben souls are spiritual messengers who bridge heaven and earth."},
    {"id": "mayan_2", "tradition": "mayan",
     "text": "The Tzolk'in is the 260-day sacred calendar formed by 20 day-signs and 13 tones. "
             "At birth each soul receives a kin — a cosmic address that encodes mission, gift, "
             "and the quality of energy available in this lifetime."},
    {"id": "mayan_3", "tradition": "mayan",
     "text": "Etznab (Flint/Mirror) reflects truth without mercy. Those born under Etznab "
             "carry the obsidian blade of clarity — they cut through illusion and show reality "
             "as it is, not as we wish it to be."},
    # ── Egyptian ─────────────────────────────────────────────────────────────
    {"id": "egyptian_1", "tradition": "egyptian",
     "text": "The decan of Sopdet (Sirius) rising heralds the Nile flood and renewal. "
             "Souls born under Sopdet carry the star's gift of precise timing and divine purpose."},
    {"id": "egyptian_2", "tradition": "egyptian",
     "text": "The 36 decans divide the sky into watchers — each a deity governing 10 days. "
             "To know one's decan ruler is to know one's divine patron, the god who accompanies "
             "the soul from birth through the Duat and into the Fields of Aaru."},
    {"id": "egyptian_3", "tradition": "egyptian",
     "text": "Ra's daily journey across the sky mirrors the soul's passage through incarnation. "
             "Born at sunrise — the moment of Ra's triumph — such souls carry the light of "
             "perpetual beginning and the courage to face each new dawn."},
    # ── Celtic ───────────────────────────────────────────────────────────────
    {"id": "celtic_1", "tradition": "celtic",
     "text": "The Rowan tree (Luis) rules those born in late January through February. "
             "Rowan people are gifted with insight, protection, and the power of discernment."},
    {"id": "celtic_2", "tradition": "celtic",
     "text": "The Willow (Saille) governs April 15 through May 12. Willow people are deeply "
             "intuitive, drawn to water and the cycles of nature. They heal through feeling, "
             "bend without breaking, and carry the wisdom of dreams and the unconscious."},
    {"id": "celtic_3", "tradition": "celtic",
     "text": "The Hawthorn (Huath, May 13–June 9) is the tree of contradiction: hope and "
             "misfortune, love and loss. Hawthorn souls thrive in paradox and see beauty "
             "precisely where others find only thorns."},
    {"id": "celtic_4", "tradition": "celtic",
     "text": "Beltane (May 1) marks the threshold between spring and summer, the peak of "
             "the Celtic wheel of fire. Souls born in late April approach Beltane carrying "
             "the full momentum of spring — creation at its most vital and unstoppable."},
    {"id": "celtic_5", "tradition": "celtic",
     "text": "The Ash tree (Nion) connects the nine worlds in Norse-Celtic lore as Yggdrasil. "
             "Those born under the Ash carry the axis mundi within — mediators between realms, "
             "natural connectors of heaven, earth, and the underworld."},
    # ── Zoroastrian ──────────────────────────────────────────────────────────
    {"id": "zoroa_1", "tradition": "zoroastrian",
     "text": "Spenta Armaiti, the Holy Devotion, governs the earth and those who tend it. "
             "Her month Spandarmad (Esfand) blesses those born in it with fidelity and serenity."},
    {"id": "zoroa_2", "tradition": "zoroastrian",
     "text": "Tishtrya, the star Sirius, presides over spring rains and abundance. "
             "He battles Apaosa the demon of drought, symbolising the soul's victory over fear."},
    {"id": "zoroa_3", "tradition": "zoroastrian",
     "text": "Ardibehesht (Asha Vahishta) is the Amesha Spenta of Truth and Cosmic Order — "
             "the most holy of months, beginning April 20. Those born at its dawn are consecrated "
             "to truth as a life-purpose; they cannot bear deception in themselves or others."},
    {"id": "zoroa_4", "tradition": "zoroastrian",
     "text": "Asha is the Zoroastrian principle of cosmic order, truth, and righteousness. "
             "Every soul born under its influence carries a profound sense of what is right "
             "and an almost painful sensitivity to injustice and falsehood."},
    {"id": "zoroa_5", "tradition": "zoroastrian",
     "text": "The four season stars mark the cardinal directions of the sky: Tishtrya (Sirius) "
             "in the east, Vanant (Vega) in the west, Satavaesa (Fomalhaut) in the south, "
             "Hapto-iringa (Ursa Major) in the north. Together they guard the celestial vault."},
    # ── Universal / fixed stars ───────────────────────────────────────────────
    {"id": "universal_1", "tradition": "western",
     "text": "11:11 — The master number 11 vibrates at the frequency of initiation and "
             "spiritual awakening. Those born at 11:11 stand at a perpetual gateway — "
             "between the visible and invisible, the human and the divine."},
    {"id": "universal_2", "tradition": "western",
     "text": "The cusp of Aries and Taurus is the hinge of the zodiacal year — the point "
             "where pure creative fire grounds itself into matter. Souls born here carry "
             "both the initiative of the pioneer and the patience of the builder."},
]

# ── TF-IDF ────────────────────────────────────────────────────────────────────

def _tokenise(text: str) -> list[str]:
    import re
    return re.findall(r"[a-z]+", text.lower())

def _build_tfidf(docs: list[dict]) -> tuple[list[dict], dict]:
    from collections import Counter
    N = len(docs)
    df: dict[str, int] = {}
    vectors = []
    for d in docs:
        tokens = _tokenise(d["text"])
        tf = Counter(tokens)
        vectors.append(tf)
        for t in set(tokens):
            df[t] = df.get(t, 0) + 1
    idf = {t: math.log(N / v + 1) + 1 for t, v in df.items()}
    return vectors, idf

def _cosine(a: dict, b: dict) -> float:
    common = set(a) & set(b)
    if not common:
        return 0.0
    dot = sum(a[k] * b.get(k, 0.0) for k in common)
    na  = math.sqrt(sum(v * v for v in a.values()))
    nb  = math.sqrt(sum(v * v for v in b.values()))
    return dot / (na * nb + 1e-9)

def rag_retrieve(query: str, docs: list[dict], top_k: int = 3,
                 tradition: Optional[str] = None) -> list[dict]:
    vectors, idf = _build_tfidf(docs)
    q_tokens = _tokenise(query)
    from collections import Counter
    q_tf = Counter(q_tokens)
    q_vec = {t: q_tf[t] * idf.get(t, 1.0) for t in q_tokens}
    scores = []
    for i, (d, v) in enumerate(zip(docs, vectors)):
        if tradition and d.get("tradition") not in (tradition, "western"):
            continue
        d_vec = {t: v[t] * idf.get(t, 1.0) for t in v}
        scores.append((i, _cosine(q_vec, d_vec)))
    scores.sort(key=lambda x: -x[1])
    return [docs[i] for i, _ in scores[:top_k]]

# ── Memory ────────────────────────────────────────────────────────────────────

def memory_load(profile: str, limit: int = 12) -> list[dict]:
    if not MEMORY.exists():
        return []
    entries = []
    with MEMORY.open() as f:
        for line in f:
            try:
                e = json.loads(line)
                if e.get("profile") == profile:
                    entries.append(e)
            except json.JSONDecodeError:
                pass
    return entries[-limit:]

def memory_append(profile: str, query: str, response: str) -> None:
    MEMORY.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "ts": datetime.now(timezone.utc).isoformat(),
        "profile": profile,
        "query": query,
        "response": response[:400],
    }
    with MEMORY.open("a") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")

# ── Profiles ──────────────────────────────────────────────────────────────────

_PROFILES = {
    "paulien": {
        "name": "Paulien",
        "dob": "1996-03-13 09:00 CET",
        "location": "Hasselt, Belgium",
        "western_sun": "Pisces",
        "western_moon": "Scorpio",
        "western_asc": "Taurus",
        "chinese_year": "Rat",
        "chinese_element": "Fire Rat",
        "mayan_kin": "Ben (Reed)",
        "vedic_sun": "Aquarius",
        "zoroa_month": "Esfand (Spenta Armaiti)",
        "celtic_tree": "Ash",
    },
    "nurse": {
        "name": "Nurse",
        "dob": "2001-10-12 07:00 CEST",
        "location": "Turnhout, Belgium",
        "western_sun": "Libra",
        "western_moon": "Gemini",
        "western_asc": "Virgo",
        "chinese_year": "Snake",
        "chinese_element": "Metal Snake",
        "mayan_kin": "Etznab (Flint)",
        "vedic_sun": "Virgo",
        "zoroa_month": "Mehr (Mithra)",
        "celtic_tree": "Ivy",
    },
    "bernd": {
        "name": "Bernd",
        "dob": "2000-02-23 15:00 CET",
        "location": "Sint-Truiden, Belgium",
        "western_sun": "Pisces",
        "western_moon": "Aries",
        "western_asc": "Leo",
        "chinese_year": "Dragon",
        "chinese_element": "Metal Dragon",
        "mayan_kin": "Chicchan (Serpent)",
        "vedic_sun": "Aquarius",
        "zoroa_month": "Esfand (Spenta Armaiti)",
        "celtic_tree": "Rowan",
    },
    "kiliaan": {
        "name": "Kiliaan",
        "dob": "1986-04-20 11:11 CEST (09:11 UTC)",
        "location": "Leuven, Belgium (50.8798°N 4.7005°E)",
        "parents": "Ingrid & Walter",
        "western_sun": "Taurus 0.3° (Aries-Taurus cusp energy)",
        "western_moon": "Virgo ~5° (waxing gibbous phase)",
        "western_asc": "Cancer 19.0°",
        "western_mc": "Pisces 19.8°",
        "chinese_year": "Fire Tiger",
        "chinese_element": "Fire Tiger — 1986",
        "mayan_kin": "approx. Tzolk'in day ~Kan (Seed)",
        "vedic_sun": "Aries 6.7° (Ashwini nakshatra — the healer twins)",
        "zoroa_month": "Ardibehesht 1st day (Asha Vahishta — Truth & Order)",
        "celtic_tree": "Willow (Saille) — April 15 to May 12",
        "birth_time_note": "11:11 = Master Number gateway; born at dawn of Ardibehesht",
    },
}

# ── Culture frames ─────────────────────────────────────────────────────────────

_CULTURE_FRAMES = {
    "western": "Respond through the lens of Hellenistic and modern Western astrology: "
               "planetary dignities, house meanings, aspects, and the tropical zodiac.",
    "vedic": "Respond through Jyotish (Vedic astrology): sidereal zodiac, nakshatras, "
             "divisional charts, and karma/dharma framework.",
    "chinese": "Respond through Ba Zi (Four Pillars) and the Chinese five-element system: "
               "year/month/day/hour pillars, Heavenly Stems, Earthly Branches.",
    "mayan": "Respond through the Tzolk'in (260-day sacred calendar): kin number, day sign "
             "(uinal), galactic tone, and the 13-day trecena.",
    "egyptian": "Respond through the Ancient Egyptian decanal system: 36 decans, deity rulers, "
                "the Duat (underworld), and stellar theology of the Nile tradition.",
    "celtic": "Respond through the Celtic tree calendar: ogham alphabet, tree totem, "
              "animal spirit, and seasonal festivals (Samhain, Imbolc, Beltane, Lughnasadh).",
    "zoroastrian": "Respond through Zoroastrian Fasli calendar cosmology: Avestan month names, "
                   "day Yazatas, Amesha Spentas, the four season stars, and the concept of Asha "
                   "(cosmic order/truth) vs Druj (deception/chaos).",
}

# ── Penta-mind prompt builder ─────────────────────────────────────────────────

def build_penta_prompt(
    profile_key: str,
    query: str,
    tradition: str = "western",
) -> str:
    p = _PROFILES.get(profile_key)
    if p is None:
        raise ValueError(f"Unknown profile: {profile_key}. "
                         f"Available: {', '.join(_PROFILES)}")

    # Layer 1: RAG passages
    passages = rag_retrieve(query, _CORPUS, top_k=3, tradition=tradition)
    corpus_block = "\n".join(f"[{r['id']}] {r['text']}" for r in passages)

    # Layer 2: Memory
    memories = memory_load(profile_key, limit=6)
    memory_block = ""
    if memories:
        memory_block = "\n".join(
            f"- ({m['ts'][:10]}) Q: {m['query'][:60]}... A: {m['response'][:80]}..."
            for m in memories
        )
    else:
        memory_block = "(no prior readings)"

    # Layer 3: Chart context
    ctx_lines = [f"{k}: {v}" for k, v in p.items() if k != "name"]
    ctx_block = "\n".join(ctx_lines)

    # Layer 4: Culture frame
    culture_frame = _CULTURE_FRAMES.get(tradition, _CULTURE_FRAMES["western"])

    # Assemble the five-layer prompt
    prompt = f"""You are AETHER, the esoteric oracle of Paulien's Sky — an AI astrologer versed in seven traditions.

═══════════════════════════════════════════════════════
LAYER 1 — CORPUS (classical wisdom passages via RAG)
═══════════════════════════════════════════════════════
{corpus_block}

═══════════════════════════════════════════════════════
LAYER 2 — MEMORY (prior readings for {p['name']})
═══════════════════════════════════════════════════════
{memory_block}

═══════════════════════════════════════════════════════
LAYER 3 — BIRTH CONTEXT for {p['name']}
═══════════════════════════════════════════════════════
{ctx_block}

═══════════════════════════════════════════════════════
LAYER 4 — TRADITION FRAME ({tradition.upper()})
═══════════════════════════════════════════════════════
{culture_frame}

═══════════════════════════════════════════════════════
LAYER 5 — QUERY from {p['name']}
═══════════════════════════════════════════════════════
{query}

─────────────────────────────────────────────────────
Synthesise all five layers into a reading of 2–4 paragraphs.
Weave the classical passages naturally. Reference specific placements.
Speak with the authority of the stars and the warmth of an elder guide.
"""
    return prompt

# ── Claude API call ────────────────────────────────────────────────────────────

def call_claude(prompt: str, api_key: str) -> str:
    import anthropic
    client = anthropic.Anthropic(api_key=api_key)
    msg = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )
    return msg.content[0].text

# ── CLI ───────────────────────────────────────────────────────────────────────

def main() -> None:
    try:
        from rich.console import Console
        from rich.panel import Panel
        from rich.text import Text
        console = Console()
        rich_available = True
    except ImportError:
        rich_available = False

    def out(text: str, title: str = "") -> None:
        if rich_available:
            console.print(Panel(text, title=title, border_style="bright_magenta"))
        else:
            print(f"\n{'─'*60}\n{title}\n{'─'*60}\n{text}\n")

    parser = argparse.ArgumentParser(
        description="AETHER Penta-Mind — five-layer esoteric oracle")
    parser.add_argument("--profile", default="paulien",
                        choices=list(_PROFILES),
                        help="Which profile to read for")
    parser.add_argument("--query", default="What is my soul's deepest calling?",
                        help="The question to ask the oracle")
    parser.add_argument("--culture", default="western",
                        choices=list(_CULTURE_FRAMES),
                        help="Tradition frame to use")
    parser.add_argument("--list-traditions", action="store_true",
                        help="List available traditions and exit")
    parser.add_argument("--no-api", action="store_true",
                        help="Print prompt only, do not call Claude API")
    args = parser.parse_args()

    if args.list_traditions:
        for k, v in _CULTURE_FRAMES.items():
            print(f"\n{k.upper()}:\n  {v[:80]}...")
        return

    prompt = build_penta_prompt(args.profile, args.query, args.culture)

    if args.no_api:
        out(prompt, title="AETHER PENTA-MIND PROMPT")
        return

    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not api_key:
        print("[AETHER] No ANTHROPIC_API_KEY set — printing prompt only.\n"
              "Set the key via: export ANTHROPIC_API_KEY=sk-ant-...")
        out(prompt, title="AETHER PENTA-MIND PROMPT")
        return

    if rich_available:
        with console.status("[bold magenta]AETHER is consulting the stars…"):
            response = call_claude(prompt, api_key)
    else:
        print("AETHER is consulting the stars…")
        response = call_claude(prompt, api_key)

    out(response,
        title=f"✦ AETHER — {args.profile.capitalize()} / {args.culture.upper()}")
    memory_append(args.profile, args.query, response)


if __name__ == "__main__":
    main()
