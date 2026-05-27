class BirthContext {
  final DateTime utcTime;
  final DateTime? localTime;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? personName;
  final bool birthTimeKnown;
  final bool isSyntheticTime;
  final String? timeZoneName;
  final String? timeNote;

  const BirthContext({
    required this.utcTime,
    this.localTime,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.personName,
    this.birthTimeKnown = true,
    this.isSyntheticTime = false,
    this.timeZoneName,
    this.timeNote,
  });

  BirthContext copyWith({
    DateTime? utcTime,
    DateTime? localTime,
    double? latitude,
    double? longitude,
    String? locationName,
    String? personName,
    bool? birthTimeKnown,
    bool? isSyntheticTime,
    String? timeZoneName,
    String? timeNote,
  }) {
    return BirthContext(
      utcTime: utcTime ?? this.utcTime,
      localTime: localTime ?? this.localTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      personName: personName ?? this.personName,
      birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
      isSyntheticTime: isSyntheticTime ?? this.isSyntheticTime,
      timeZoneName: timeZoneName ?? this.timeZoneName,
      timeNote: timeNote ?? this.timeNote,
    );
  }

  Map<String, dynamic> toJson() => {
    'utcTime': utcTime.toIso8601String(),
    'localTime': localTime?.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'personName': personName,
    'birthTimeKnown': birthTimeKnown,
    'isSyntheticTime': isSyntheticTime,
    'timeZoneName': timeZoneName,
    'timeNote': timeNote,
  };

  factory BirthContext.fromJson(Map<String, dynamic> json) => BirthContext(
    utcTime: DateTime.parse(json['utcTime'] as String),
    localTime: json['localTime'] == null
        ? null
        : DateTime.parse(json['localTime'] as String),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    locationName: json['locationName'] as String?,
    personName: json['personName'] as String?,
    birthTimeKnown: json['birthTimeKnown'] as bool? ?? true,
    isSyntheticTime: json['isSyntheticTime'] as bool? ?? false,
    timeZoneName: json['timeZoneName'] as String?,
    timeNote: json['timeNote'] as String?,
  );

  String? validate() {
    if (latitude < -90 || latitude > 90) {
      return 'Latitude must be between -90 and 90 degrees.';
    }
    if (longitude < -180 || longitude > 180) {
      return 'Longitude must be between -180 and 180 degrees.';
    }
    return null;
  }
}
