import 'package:flutter_test/flutter_test.dart';
import 'package:ibrahim/core/utils/prayer_calculator.dart';

void main() {
  group('PrayerCalculator', () {
    test('calculates prayer times for Mecca coordinates', () {
      final result = PrayerCalculator.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2026, 6, 1),
      );

      expect(result.fajr, isNotNull);
      expect(result.dhuhr, isNotNull);
      expect(result.asr, isNotNull);
      expect(result.maghrib, isNotNull);
      expect(result.isha, isNotNull);

      // Fajr should be before Dhuhr
      expect(result.fajr.isBefore(result.dhuhr), isTrue);
      // Dhuhr should be before Maghrib
      expect(result.dhuhr.isBefore(result.maghrib), isTrue);
      // Maghrib should be before Isha
      expect(result.maghrib.isBefore(result.isha), isTrue);
    });

    test('returns correct nextPrayerName', () {
      final result = PrayerCalculator.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2026, 6, 1),
      );

      expect(result.nextPrayerName, isNotEmpty);
    });

    test('prayer times are in ascending order', () {
      final result = PrayerCalculator.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2026, 6, 1),
      );

      expect(result.fajr.isBefore(result.sunrise), isTrue);
      expect(result.sunrise.isBefore(result.dhuhr), isTrue);
      expect(result.dhuhr.isBefore(result.asr), isTrue);
      expect(result.asr.isBefore(result.maghrib), isTrue);
      expect(result.maghrib.isBefore(result.isha), isTrue);
    });

    test('works with different date', () {
      final summer = PrayerCalculator.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2026, 6, 21),
      );

      final winter = PrayerCalculator.calculate(
        latitude: 21.4225,
        longitude: 39.8262,
        date: DateTime(2026, 12, 21),
      );

      // Summer days are longer — Fajr should be earlier in summer
      // (Actually for Mecca near equator this difference is small)
      expect(summer.fajr, isNot(equals(winter.fajr)));
    });
  });
}
