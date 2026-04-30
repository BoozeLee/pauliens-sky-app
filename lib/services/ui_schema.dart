import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Data models ────────────────────────────────────────────────────────────

class NavTabDef {
  final String id;
  final String labelEn;
  final String labelNl;
  final String iconOutlined;
  final String iconFilled;
  final Color accent;
  final int index;
  const NavTabDef({
    required this.id, required this.labelEn, required this.labelNl,
    required this.iconOutlined, required this.iconFilled,
    required this.accent, required this.index,
  });
}

class TraditionDef {
  final String id;
  final String cultureId;
  final String labelEn;
  final String labelNl;
  final String symbol;
  final Color accent;
  final String artAsset;
  final List<Color> cardGradient;
  final double borderRadius;
  final String descriptionEn;
  final String descriptionNl;
  final int tabIndex;
  final String starColor;
  final int starDensity;
  final double glyphSize;
  final double glyphOpacity;
  const TraditionDef({
    required this.id, required this.cultureId,
    required this.labelEn, required this.labelNl,
    required this.symbol, required this.accent,
    required this.artAsset, required this.cardGradient,
    required this.borderRadius, required this.descriptionEn,
    required this.descriptionNl, required this.tabIndex,
    required this.starColor, required this.starDensity,
    required this.glyphSize, required this.glyphOpacity,
  });
}

class AppPalette {
  final Color background;
  final Color surface;
  final Color card;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Map<String, Color> accents;
  const AppPalette({
    required this.background, required this.surface, required this.card,
    required this.divider, required this.textPrimary,
    required this.textSecondary, required this.textMuted,
    required this.accents,
  });
  Color accent(String key) =>
      accents[key] ?? accents['lavender'] ?? const Color(0xFFB39DDB);
}

class StarFieldDef {
  final int starCount;
  final Color baseColor;
  final double minRadius;
  final double maxRadius;
  final int twinkleSpeedMs;
  const StarFieldDef({
    required this.starCount, required this.baseColor,
    required this.minRadius, required this.maxRadius,
    required this.twinkleSpeedMs,
  });
}

class ZodiacWheelDef {
  final Color tropicalColor;
  final Color siderealColor;
  final double planetDotSize;
  final double dividerOpacity;
  const ZodiacWheelDef({
    required this.tropicalColor, required this.siderealColor,
    required this.planetDotSize, required this.dividerOpacity,
  });
}

class AiScreenDef {
  final Color localColor;
  final Color claudeColor;
  final Color geminiColor;
  final Color bubbleUserColor;
  final Color bubbleAssistantColor;
  final String thinkingEn;
  final String thinkingNl;
  const AiScreenDef({
    required this.localColor, required this.claudeColor,
    required this.geminiColor, required this.bubbleUserColor,
    required this.bubbleAssistantColor,
    required this.thinkingEn, required this.thinkingNl,
  });
}

// ── Loader ─────────────────────────────────────────────────────────────────

class UiSchema {
  static UiSchema? _instance;
  static UiSchema get instance {
    assert(_instance != null, 'UiSchema.load() not yet called');
    return _instance!;
  }

  final AppPalette palette;
  final List<NavTabDef> navTabs;
  final List<TraditionDef> traditions;
  final StarFieldDef starField;
  final ZodiacWheelDef zodiacWheel;
  final AiScreenDef aiScreen;
  final Map<String, dynamic> raw;

  const UiSchema._({
    required this.palette, required this.navTabs,
    required this.traditions, required this.starField,
    required this.zodiacWheel, required this.aiScreen,
    required this.raw,
  });

  static Future<UiSchema> load() async {
    if (_instance != null) return _instance!;
    final jsonStr =
        await rootBundle.loadString('assets/data/ui_schema.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    _instance = _parse(map);
    return _instance!;
  }

  TraditionDef? tradition(String id) =>
      traditions.where((t) => t.id == id).firstOrNull;

  NavTabDef? navTab(String id) =>
      navTabs.where((t) => t.id == id).firstOrNull;

  // ── Parsing ─────────────────────────────────────────────────────────────

  static UiSchema _parse(Map<String, dynamic> m) {
    final app  = m['app'] as Map<String, dynamic>;
    final pal  = app['palette'] as Map<String, dynamic>;
    final acc  = app['accents'] as Map<String, dynamic>;

    final palette = AppPalette(
      background:    _hex(pal['background']),
      surface:       _hex(pal['surface']),
      card:          _hex(pal['card']),
      divider:       _hex(pal['divider']),
      textPrimary:   _hex(pal['text_primary']),
      textSecondary: _hex(pal['text_secondary']),
      textMuted:     _hex(pal['text_muted']),
      accents:       acc.map((k, v) => MapEntry(k, _hex(v as String))),
    );

    final navTabs = (m['nav_tabs'] as List).map((e) {
      final t = e as Map<String, dynamic>;
      return NavTabDef(
        id:          t['id'] as String,
        labelEn:     t['label_en'] as String,
        labelNl:     t['label_nl'] as String,
        iconOutlined:t['icon_outlined'] as String,
        iconFilled:  t['icon_filled'] as String,
        accent:      _hex(t['accent'] as String),
        index:       t['index'] as int,
      );
    }).toList();

    final traditions = (m['traditions'] as List).map((e) {
      final t = e as Map<String, dynamic>;
      final grads = (t['card_gradient'] as List)
          .map((c) => _hex(c as String))
          .toList();
      return TraditionDef(
        id:            t['id'] as String,
        cultureId:     t['culture_id'] as String,
        labelEn:       t['label_en'] as String,
        labelNl:       t['label_nl'] as String,
        symbol:        t['symbol'] as String,
        accent:        _hex(t['accent'] as String),
        artAsset:      t['art_asset'] as String,
        cardGradient:  grads,
        borderRadius:  (t['border_radius'] as num).toDouble(),
        descriptionEn: t['description_en'] as String,
        descriptionNl: t['description_nl'] as String,
        tabIndex:      t['tab_index'] as int,
        starColor:     t['star_color'] as String,
        starDensity:   t['star_density'] as int,
        glyphSize:     (t['glyph_size'] as num).toDouble(),
        glyphOpacity:  (t['glyph_opacity'] as num).toDouble(),
      );
    }).toList();

    final sf = m['star_field'] as Map<String, dynamic>;
    final starField = StarFieldDef(
      starCount:     sf['star_count'] as int,
      baseColor:     _hex(sf['base_color']),
      minRadius:     (sf['min_radius'] as num).toDouble(),
      maxRadius:     (sf['max_radius'] as num).toDouble(),
      twinkleSpeedMs:sf['twinkle_speed_ms'] as int,
    );

    final zw = m['zodiac_wheel'] as Map<String, dynamic>;
    final zodiacWheel = ZodiacWheelDef(
      tropicalColor:  _hex(zw['tropical_color']),
      siderealColor:  _hex(zw['sidereal_color']),
      planetDotSize:  (zw['planet_dot_size'] as num).toDouble(),
      dividerOpacity: (zw['divider_opacity'] as num).toDouble(),
    );

    final ai = m['ai_screen'] as Map<String, dynamic>;
    final aiScreen = AiScreenDef(
      localColor:           _hex(ai['local_color']),
      claudeColor:          _hex(ai['claude_color']),
      geminiColor:          _hex(ai['gemini_color']),
      bubbleUserColor:      _hex(ai['bubble_user_color']),
      bubbleAssistantColor: _hex(ai['bubble_assistant_color']),
      thinkingEn: ai['thinking_label_en'] as String,
      thinkingNl: ai['thinking_label_nl'] as String,
    );

    return UiSchema._(
      palette: palette, navTabs: navTabs, traditions: traditions,
      starField: starField, zodiacWheel: zodiacWheel, aiScreen: aiScreen,
      raw: m,
    );
  }

  static Color _hex(String h) {
    final s = h.replaceFirst('#', '');
    if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
    if (s.length == 8) return Color(int.parse(s, radix: 16));
    return const Color(0xFFB39DDB);
  }
}

// ── Icon resolver ─────────────────────────────────────────────────────────

class SchemaIcons {
  static IconData resolve(String name) => _map[name] ?? Icons.circle_outlined;

  static const _map = {
    'home':                     Icons.home,
    'home_outlined':            Icons.home_outlined,
    'auto_awesome':             Icons.auto_awesome,
    'auto_awesome_outlined':    Icons.auto_awesome_outlined,
    'psychology':               Icons.psychology,
    'psychology_outlined':      Icons.psychology_outlined,
    'explore':                  Icons.explore,
    'explore_outlined':         Icons.explore_outlined,
    'settings':                 Icons.settings,
    'settings_outlined':        Icons.settings_outlined,
    'star':                     Icons.star,
    'star_outlined':            Icons.star_border,
    'lock':                     Icons.lock,
    'lock_outlined':            Icons.lock_outline,
    'person':                   Icons.person,
    'person_outlined':          Icons.person_outline,
    'download':                 Icons.download,
    'download_outlined':        Icons.download_outlined,
  };
}
