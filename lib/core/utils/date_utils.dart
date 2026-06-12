import 'package:flutter/services.dart';
import 'dart:convert';

/// نموذج الآية اليومية
class DailyVerse {
  final String arabic;
  final String translation;
  final String surah;
  final String surahEn;
  final dynamic ayah;
  final int surahNumber;

  const DailyVerse({
    required this.arabic,
    required this.translation,
    required this.surah,
    required this.surahEn,
    required this.ayah,
    required this.surahNumber,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      arabic: json['arabic'] as String,
      translation: json['translation'] as String,
      surah: json['surah'] as String,
      surahEn: json['surah_en'] as String,
      ayah: json['ayah'],
      surahNumber: json['surah_number'] as int,
    );
  }
}

/// يختار آية يومية بناءً على الفترة الزمنية (كل 6 ساعات)
class DailyVerseSelector {
  static List<DailyVerse>? _verses;

  static Future<DailyVerse> getDailyVerse() async {
    if (_verses == null) await _loadVerses();
    final periodIndex = _sixHourPeriodIndex(DateTime.now());
    final index = periodIndex % _verses!.length;
    return _verses![index];
  }

  static Future<void> _loadVerses() async {
    final jsonStr =
        await rootBundle.loadString('assets/quran/quran_ar.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final list = data['daily_verses'] as List;
    _verses = list.map((e) => DailyVerse.fromJson(e as Map<String, dynamic>)).toList();
  }

  static int _sixHourPeriodIndex(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final period = date.hour ~/ 6;
    return dayOfYear * 4 + period;
  }
}
