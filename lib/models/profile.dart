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

  // Paulien — 13 March 1996, Hasselt, Belgium
  // Birth time unknown → synthetic noon local (CET = UTC+1 → 11:00 UTC)
  // Hasselt: 50.9311°N, 5.3378°E
  static final paulien = Profile(
    id: 'paulien',
    name: 'Paulien',
    isDefault: true,
    birthTimeKnown: false,
    birthContext: BirthContext(
      utcTime: DateTime.utc(1996, 3, 13, 11, 0, 0), // noon CET
      latitude: 50.9311,
      longitude: 5.3378,
      locationName: 'Hasselt, Belgium',
      personName: 'Paulien',
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
