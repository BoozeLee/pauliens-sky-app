/// AETHER Session Memory
///
/// In-memory conversation memory for the current session.
/// No file I/O — works on web (Vercel) without platform-specific code.
library aether_memory;

class AetherMemoryEntry {
  final String text;
  final String culture;
  final DateTime timestamp;

  AetherMemoryEntry({
    required this.text,
    required this.culture,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get summary {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= 120) return clean;
    return '${clean.substring(0, 119)}…';
  }
}

class AetherMemory {
  static final AetherMemory instance = AetherMemory._();
  AetherMemory._();

  final List<AetherMemoryEntry> _entries = [];
  static const int _maxEntries = 30;

  /// Add a new memory entry
  void addEntry(String text, String culture) {
    _entries.insert(0, AetherMemoryEntry(text: text, culture: culture));
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
  }

  /// Get recent memory entries
  List<AetherMemoryEntry> recents({int limit = 5}) {
    return _entries.take(limit).toList();
  }

  /// Get all entries
  List<AetherMemoryEntry> get entries => List.unmodifiable(_entries);

  /// Clear all memory
  void clear() {
    _entries.clear();
  }

  /// Remove a specific entry
  void removeEntry(int index) {
    if (index >= 0 && index < _entries.length) {
      _entries.removeAt(index);
    }
  }

  /// Get memory count
  int get length => _entries.length;

  /// Check if memory is empty
  bool get isEmpty => _entries.isEmpty;

  /// Get formatted memory string for prompt injection
  String toPromptString({int limit = 5}) {
    final recent = recents(limit: limit);
    if (recent.isEmpty) return '';

    final buf = StringBuffer();
    buf.writeln('[Session memory]');
    for (final entry in recent) {
      buf.writeln('• ${entry.summary}');
    }
    return buf.toString();
  }
}
