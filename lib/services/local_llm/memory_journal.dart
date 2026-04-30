import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MemoryEntry {
  final String date;
  final String summary;
  final String fullText;
  final String culture;

  const MemoryEntry({
    required this.date,
    required this.summary,
    required this.fullText,
    required this.culture,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'summary': summary,
    'full': fullText,
    'culture': culture,
  };

  factory MemoryEntry.fromJson(Map<String, dynamic> j) => MemoryEntry(
    date: j['date'] as String,
    summary: j['summary'] as String,
    fullText: j['full'] as String,
    culture: j['culture'] as String? ?? 'western',
  );
}

class MemoryJournal {
  static const _maxEntries = 30;
  static const _summaryLength = 120; // chars

  static MemoryJournal? _instance;
  static MemoryJournal get instance => _instance ??= MemoryJournal._();
  MemoryJournal._();

  List<MemoryEntry> _entries = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final file = await _journalFile();
      if (await file.exists()) {
        final lines = await file.readAsLines();
        _entries = lines
            .where((l) => l.trim().isNotEmpty)
            .map((l) => MemoryEntry.fromJson(
                jsonDecode(l) as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    _loaded = true;
  }

  Future<void> append(String fullText, {String culture = 'western'}) async {
    await _ensureLoaded();

    final summary = _summarize(fullText);
    final entry = MemoryEntry(
      date: _todayString(),
      summary: summary,
      fullText: fullText,
      culture: culture,
    );

    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries = _entries.take(_maxEntries).toList();
    }

    await _persist();
  }

  Future<List<MemoryEntry>> recents({int limit = 5}) async {
    await _ensureLoaded();
    return _entries.take(limit).toList();
  }

  Future<void> clear() async {
    _entries = [];
    final f = await _journalFile();
    if (await f.exists()) await f.delete();
  }

  Future<void> deleteEntry(String date) async {
    _entries.removeWhere((e) => e.date == date);
    await _persist();
  }

  // Condense long text to a summary line for PSYCHE injection
  String _summarize(String text) {
    final clean = text.replaceAll('\n', ' ').trim();
    if (clean.length <= _summaryLength) return clean;
    return '${clean.substring(0, _summaryLength - 1)}…';
  }

  Future<void> _persist() async {
    try {
      final file = await _journalFile();
      final lines = _entries.map((e) => jsonEncode(e.toJson())).join('\n');
      await file.writeAsString(lines);
    } catch (_) {}
  }

  Future<File> _journalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/aether_memory.jsonl');
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-'
        '${n.day.toString().padLeft(2,'0')}';
  }
}
