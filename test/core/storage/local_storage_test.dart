import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ibrahim/core/storage/local_storage.dart';
import 'dart:io';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ibrahim_test_');
    Hive.init(tempDir.path);
    await LocalStorage.init(path: tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    tempDir.deleteSync(recursive: true);
  });

  group('LocalStorage', () {
    test('saves and retrieves prayer status', () async {
      final storage = LocalStorage();
      await storage.savePrayerStatus('fajr', true);
      await storage.savePrayerStatus('isha', false);

      expect(storage.getPrayerStatus('fajr'), isTrue);
      expect(storage.getPrayerStatus('isha'), isFalse);
    });

    test('default prayer status is false', () {
      final storage = LocalStorage();
      expect(storage.getPrayerStatus('unknown'), isFalse);
    });

    test('getTodayPrayerCount returns correct count', () async {
      final storage = LocalStorage();
      expect(storage.getTodayPrayerCount(), equals(0));

      await storage.savePrayerStatus('fajr', true);
      await storage.savePrayerStatus('dhuhr', true);

      expect(storage.getTodayPrayerCount(), equals(2));
    });

    test('saves and retrieves settings', () async {
      final storage = LocalStorage();
      await storage.saveString('theme', 'dark');
      await storage.saveBool('notifications', true);

      expect(storage.getString('theme'), equals('dark'));
      expect(storage.getString('unknown'), equals(''));
      expect(storage.getBool('notifications'), isTrue);
      expect(storage.getBool('unknown'), isFalse);
    });

    test('saves and retrieves Quran page', () async {
      final storage = LocalStorage();
      expect(storage.getQuranPage(), equals(1));

      await storage.saveQuranPage(42);
      expect(storage.getQuranPage(), equals(42));
    });

    test('manages bookmarks', () async {
      final storage = LocalStorage();
      expect(storage.getBookmarks(), isEmpty);

      await storage.addBookmark('1:1');
      await storage.addBookmark('2:255');

      expect(storage.getBookmarks().length, equals(2));
      expect(storage.isBookmarked('1:1'), isTrue);

      await storage.removeBookmark('1:1');
      expect(storage.getBookmarks().length, equals(1));
      expect(storage.isBookmarked('1:1'), isFalse);
    });

    test('duplicate bookmark is not added', () async {
      final storage = LocalStorage();
      await storage.addBookmark('36:1');
      await storage.addBookmark('36:1');

      expect(storage.getBookmarks().length, equals(1));
    });

    test('manages azkar progress', () async {
      final storage = LocalStorage();
      expect(storage.getAzkarProgress('morning'), equals(0));

      await storage.saveAzkarProgress('morning', 10);
      expect(storage.getAzkarProgress('morning'), equals(10));
    });

    test('manages spiritual level', () async {
      final storage = LocalStorage();
      expect(storage.getSpiritualLevel(), equals(0));

      await storage.saveSpiritualLevel(3);
      expect(storage.getSpiritualLevel(), equals(3));
    });
  });
}
