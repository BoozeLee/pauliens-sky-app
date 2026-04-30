import 'dart:convert';
import 'birth_context.dart';

class Profile {
  final String id;
  final String name;
  final BirthContext birthContext;
  final bool isDefault;

  const Profile({
    required this.id,
    required this.name,
    required this.birthContext,
    this.isDefault = false,
  });

  // Paulien's birth profile — 13 March 1996
  // Birth time set to noon UTC as default until user provides exact time.
  // Birth city: to be confirmed by user; using Amsterdam (52.37, 4.90) as default.
  static final paulien = Profile(
    id: 'paulien',
    name: 'Paulien',
    isDefault: true,
    birthContext: BirthContext(
      utcTime: DateTime.utc(1996, 3, 13, 12, 0, 0),
      latitude: 52.3676,
      longitude: 4.9041,
      locationName: 'Amsterdam, Netherlands',
      personName: 'Paulien',
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'birthContext': birthContext.toJson(),
    'isDefault': isDefault,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    birthContext: BirthContext.fromJson(json['birthContext'] as Map<String, dynamic>),
    isDefault: json['isDefault'] as bool? ?? false,
  );

  String toJsonString() => jsonEncode(toJson());
}
