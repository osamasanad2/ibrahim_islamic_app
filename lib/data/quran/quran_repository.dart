import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'ayah_model.dart';
import 'surah_meta.dart';

class QuranRepository {
  final Dio dio;
  List<SurahMeta>? _cachedSurahs;

  QuranRepository(this.dio);

  Future<List<SurahMeta>> getSurahList() async {
    if (_cachedSurahs != null) return _cachedSurahs!;

    final json = await rootBundle.loadString('assets/quran/surah_list.json');
    final list = jsonDecode(json) as List;
    _cachedSurahs = list.map((e) => SurahMeta.fromJson(e as Map<String, dynamic>)).toList();
    return _cachedSurahs!;
  }

  Future<List<AyahModel>> getSurahContent(int surahNumber) async {
    final res = await dio.get(
      'https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,en.asad',
    );
    final editions = res.data['data'] as List;
    final arabic = (editions[0]['ayahs'] as List);
    final english = (editions[1]['ayahs'] as List);
    final surahData = editions[0] as Map<String, dynamic>;
    final surahNumberInQuran = ((surahData['surah'] as Map)['number'] as int?) ?? surahNumber;

    return List.generate(arabic.length, (i) {
      final numberInSurah = arabic[i]['numberInSurah'] as int;
      final numberInQuran = arabic[i]['number'] as int;
      return AyahModel(
        numberInSurah: numberInSurah,
        numberInQuran: numberInQuran,
        text: arabic[i]['text'] as String,
        translation: english[i]['text'] as String?,
        surahNumber: surahNumberInQuran,
      );
    });
  }

  Future<List<dynamic>> getPageAyahs(int page) async {
    final res = await dio.get('https://api.alquran.cloud/v1/page/$page/quran-uthmani');
    return res.data['data']['ayahs'] as List;
  }

  Future<String> getTafsir(int surahNumber, int ayahNumber) async {
    final res = await dio.get(
      'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/ar.muyassar',
    );
    return res.data['data']['text'] as String;
  }

  Future<Map<String, dynamic>> getTafsirWithAyah(int surahNumber, int ayahNumber) async {
    final res = await dio.get(
      'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/ar.muyassar',
    );
    final data = res.data['data'] as Map<String, dynamic>;
    return {
      'tafsir': data['text'] as String,
      'ayah': data['ayah'] ?? '',
    };
  }
}
