import 'package:flutter/material.dart';

enum CultureId { western, babylonian, chinese, vedic, mayan, egyptian, celtic, zoroastrian }

extension CultureIdExt on CultureId {
  String get displayName => switch (this) {
    CultureId.western => 'Western',
    CultureId.babylonian => 'Babylonian',
    CultureId.chinese => 'Chinese',
    CultureId.vedic => 'Vedic',
    CultureId.mayan => 'Mayan',
    CultureId.egyptian => 'Egyptian',
    CultureId.celtic => 'Celtic',
    CultureId.zoroastrian => 'Zoroastrian',
  };

  String get emoji => switch (this) {
    CultureId.western => '♈',
    CultureId.babylonian => '𒀭',
    CultureId.chinese => '龍',
    CultureId.vedic => '🕉',
    CultureId.mayan => '☀',
    CultureId.egyptian => '𓂀',
    CultureId.celtic => '🌿',
    CultureId.zoroastrian => '🔥',
  };

  Color get accentColor => switch (this) {
    CultureId.western => const Color(0xFF00F5FF),
    CultureId.babylonian => const Color(0xFFFF8C69),
    CultureId.chinese => const Color(0xFFFF6EFF),
    CultureId.vedic => const Color(0xFF39FF7E),
    CultureId.mayan => const Color(0xFFFFE84D),
    CultureId.egyptian => const Color(0xFFFFB347),
    CultureId.celtic => const Color(0xFF7EC8E3),
    CultureId.zoroastrian => const Color(0xFFFF9944),
  };
}

class CultureEntry {
  final String label;
  final String value;
  final String? description;

  const CultureEntry({required this.label, required this.value, this.description});
}

class CultureChart {
  final CultureId id;
  final List<CultureEntry> entries;
  final List<String> keyInsights;
  final String? sunSign;
  final String? moonSign;
  final String? ascendantSign;

  const CultureChart({
    required this.id,
    required this.entries,
    this.keyInsights = const [],
    this.sunSign,
    this.moonSign,
    this.ascendantSign,
  });
}
