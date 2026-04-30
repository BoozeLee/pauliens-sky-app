class BirthContext {
  final DateTime utcTime;
  final double latitude;
  final double longitude;
  final String? locationName;
  final String? personName;

  const BirthContext({
    required this.utcTime,
    required this.latitude,
    required this.longitude,
    this.locationName,
    this.personName,
  });

  BirthContext copyWith({
    DateTime? utcTime,
    double? latitude,
    double? longitude,
    String? locationName,
    String? personName,
  }) {
    return BirthContext(
      utcTime: utcTime ?? this.utcTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      personName: personName ?? this.personName,
    );
  }

  Map<String, dynamic> toJson() => {
    'utcTime': utcTime.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'personName': personName,
  };

  factory BirthContext.fromJson(Map<String, dynamic> json) => BirthContext(
    utcTime: DateTime.parse(json['utcTime'] as String),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    locationName: json['locationName'] as String?,
    personName: json['personName'] as String?,
  );
}
