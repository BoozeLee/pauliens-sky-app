import 'dart:convert';
import 'birth_context.dart';

class Profile {
  final String id;
  final String name;
  final BirthContext birthContext;
  final bool isDefault;
  final bool birthTimeKnown;

  const Profile({
    required this.id,
    required this.name,
    required this.birthContext,
    this.isDefault = false,
    this.birthTimeKnown = true,
  });

  // Paulien — 13 March 1996, 09:00 CET (UTC+1) → 08:00 UTC, Hasselt, Belgium
  // Hasselt: 50.9311°N, 5.3378°E
  static final paulien = Profile(
    id: 'paulien',
    name: 'Paulien',
    isDefault: true,
    birthTimeKnown: true,
    birthContext: BirthContext(
      utcTime: DateTime.utc(1996, 3, 13, 8, 0, 0),
      latitude: 50.9311,
      longitude: 5.3378,
      locationName: 'Hasselt, Belgium',
      personName: 'Paulien',
    ),
  );

  // Nurse — 12 October 2001, 07:00 CEST (UTC+2) → 05:00 UTC, Turnhout, Belgium
  // Turnhout: 51.3225°N, 4.9436°E  (Oct 12 is still CEST in BE)
  static final nurse = Profile(
    id: 'nurse',
    name: 'Nurse',
    isDefault: false,
    birthTimeKnown: true,
    birthContext: BirthContext(
      utcTime: DateTime.utc(2001, 10, 12, 5, 0, 0),
      latitude: 51.3225,
      longitude: 4.9436,
      locationName: 'Turnhout, Belgium',
      personName: 'Nurse',
    ),
  );

  // Bernd — 23 February 2000, 15:00 CET (UTC+1) → 14:00 UTC, Sint-Truiden, Belgium
  // Sint-Truiden: 50.8167°N, 5.1833°E  (Feb is CET in BE)
  static final bernd = Profile(
    id: 'bernd',
    name: 'Bernd',
    isDefault: false,
    birthTimeKnown: true,
    birthContext: BirthContext(
      utcTime: DateTime.utc(2000, 2, 23, 14, 0, 0),
      latitude: 50.8167,
      longitude: 5.1833,
      locationName: 'Sint-Truiden, Belgium',
      personName: 'Bernd',
    ),
  );

  // Kiliaan — 20 April 1986, 11:11 CEST (UTC+2) → 09:11 UTC, Leuven, Belgium
  // Leuven: 50.8798°N, 4.7005°E  (April 1986: CEST started March 30, 1986)
  // ASC: Cancer 19°  MC: Pisces 19°  Sun: Taurus 0.3°  Vedic: Aries 6.7° (Ashwini)
  // Chinese: Fire Tiger  Celtic: Willow (Saille)  Zoroastrian: Ardibehesht 1st day
  // Parents: Ingrid & Walter
  static final kiliaan = Profile(
    id: 'kiliaan',
    name: 'Kiliaan',
    isDefault: false,
    birthTimeKnown: true,
    birthContext: BirthContext(
      utcTime: DateTime.utc(1986, 4, 20, 9, 11, 0),
      latitude: 50.8798,
      longitude: 4.7005,
      locationName: 'Leuven, Belgium',
      personName: 'Kiliaan',
    ),
  );

  Profile copyWith({
    String? name,
    BirthContext? birthContext,
    bool? birthTimeKnown,
  }) => Profile(
    id: id,
    name: name ?? this.name,
    birthContext: birthContext ?? this.birthContext,
    isDefault: isDefault,
    birthTimeKnown: birthTimeKnown ?? this.birthTimeKnown,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birthContext': birthContext.toJson(),
    'isDefault': isDefault,
    'birthTimeKnown': birthTimeKnown,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    birthContext: BirthContext.fromJson(json['birthContext'] as Map<String, dynamic>),
    isDefault: json['isDefault'] as bool? ?? false,
    birthTimeKnown: json['birthTimeKnown'] as bool? ?? true,
  );

  String toJsonString() => jsonEncode(toJson());
}
