class LocationSuggestion {
  final String name;
  final double latitude;
  final double longitude;
  final String timeZoneName;

  const LocationSuggestion({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.timeZoneName,
  });
}

class LocationLookup {
  static const _catalog = <LocationSuggestion>[
    LocationSuggestion(
      name: 'Hasselt, Belgium',
      latitude: 50.9311,
      longitude: 5.3378,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Leuven, Belgium',
      latitude: 50.8798,
      longitude: 4.7005,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Brussels, Belgium',
      latitude: 50.8503,
      longitude: 4.3517,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Antwerp, Belgium',
      latitude: 51.2194,
      longitude: 4.4025,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Ghent, Belgium',
      latitude: 51.0543,
      longitude: 3.7174,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Turnhout, Belgium',
      latitude: 51.3225,
      longitude: 4.9436,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Sint-Truiden, Belgium',
      latitude: 50.8167,
      longitude: 5.1833,
      timeZoneName: 'Europe/Brussels',
    ),
    LocationSuggestion(
      name: 'Amsterdam, Netherlands',
      latitude: 52.3676,
      longitude: 4.9041,
      timeZoneName: 'Europe/Amsterdam',
    ),
    LocationSuggestion(
      name: 'Rotterdam, Netherlands',
      latitude: 51.9244,
      longitude: 4.4777,
      timeZoneName: 'Europe/Amsterdam',
    ),
    LocationSuggestion(
      name: 'Utrecht, Netherlands',
      latitude: 52.0907,
      longitude: 5.1214,
      timeZoneName: 'Europe/Amsterdam',
    ),
  ];

  static LocationSuggestion? lookup(String input) {
    final query = input.trim().toLowerCase();
    if (query.isEmpty) return null;

    for (final suggestion in _catalog) {
      final name = suggestion.name.toLowerCase();
      if (name == query || name.startsWith(query) || name.contains(query)) {
        return suggestion;
      }
    }
    return null;
  }

  static List<LocationSuggestion> fuzzySearch(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    return _catalog.where((s) => s.name.toLowerCase().contains(q)).toList();
  }
}
