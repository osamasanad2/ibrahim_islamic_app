import 'dart:convert';
import 'package:flutter/services.dart';

class DailyHadith {
  final int id;
  final int number;
  final String category;
  final String narrator;
  final String source;
  final String arabic;
  final String fullArabic;
  final String translation;

  const DailyHadith({
    required this.id,
    required this.number,
    required this.category,
    required this.narrator,
    required this.source,
    required this.arabic,
    required this.fullArabic,
    required this.translation,
  });

  factory DailyHadith.fromJson(Map<String, dynamic> json) => DailyHadith(
        id: json['id'] as int,
        number: json['number'] as int,
        category: json['category'] as String? ?? '',
        narrator: json['narrator'] as String,
        source: json['source'] as String,
        arabic: json['arabic'] as String,
        fullArabic: json['full_arabic'] as String? ?? (json['arabic'] as String),
        translation: json['translation'] as String,
      );
}

class DailyHadithSelector {
  static List<DailyHadith>? _hadiths;

  static Future<DailyHadith> getDailyHadith() async {
    if (_hadiths == null) await _load();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _hadiths![dayOfYear % _hadiths!.length];
  }

  static Future<void> _load() async {
    final str = await rootBundle.loadString('assets/hadith/hadith_40.json');
    final data = json.decode(str) as Map<String, dynamic>;
    _hadiths = (data['hadiths'] as List)
        .map((e) => DailyHadith.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
