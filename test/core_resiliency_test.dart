import 'package:flutter_test/flutter_test.dart';
import 'package:pauliens_sky/models/birth_context.dart';
import 'package:pauliens_sky/services/location_lookup.dart';

void main() {
  group('BirthContext Validation', () {
    test('should validate correct coordinates', () {
      final context = BirthContext(
        utcTime: DateTime.now(),
        latitude: 50.0,
        longitude: 5.0,
      );
      expect(context.validate(), isNull);
    });

    test('should fail for invalid latitude', () {
      final context = BirthContext(
        utcTime: DateTime.now(),
        latitude: 100.0,
        longitude: 5.0,
      );
      expect(context.validate(), isNotNull);
    });

    test('should fail for invalid longitude', () {
      final context = BirthContext(
        utcTime: DateTime.now(),
        latitude: 50.0,
        longitude: 200.0,
      );
      expect(context.validate(), isNotNull);
    });
  });

  group('LocationLookup Fuzzy Search', () {
    test('should return multiple results for "belgium"', () {
      final results = LocationLookup.fuzzySearch('belgium');
      expect(results.length, greaterThan(1));
    });

    test('should return empty list for no matches', () {
      final results = LocationLookup.fuzzySearch('Mars');
      expect(results, isEmpty);
    });
  });
}
