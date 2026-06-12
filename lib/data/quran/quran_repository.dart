import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'ayah_model.dart';
import 'surah_meta.dart';
import 'word_meaning.dart';
import 'tafsir_edition.dart';

class QuranRepository {
  final Dio dio;
  List<SurahMeta>? _cachedSurahs;
  List<dynamic>? _fullQuran;
  Map<int, int>? _ayahOffsets;

  QuranRepository(this.dio);

  Future<List<SurahMeta>> getSurahList() async {
    if (_cachedSurahs != null) return _cachedSurahs!;

    final json = await rootBundle.loadString('assets/quran/surah_list.json');
    final list = jsonDecode(json) as List;
    _cachedSurahs = list.map((e) => SurahMeta.fromJson(e as Map<String, dynamic>)).toList();
    return _cachedSurahs!;
  }

  Future<void> _loadFullQuran() async {
    if (_fullQuran != null) return;
    final json = await rootBundle.loadString('assets/quran/quran_full.json');
    _fullQuran = jsonDecode(json) as List;
    _ayahOffsets = {};
    int offset = 1;
    for (final surah in _fullQuran!) {
      final sn = surah['number'] as int;
      final ayahs = surah['ayahs'] as List;
      _ayahOffsets![sn] = offset;
      offset += ayahs.length;
    }
  }

  Future<List<AyahModel>> getSurahContent(int surahNumber) async {
    try {
      return await _getSurahContentLocal(surahNumber);
    } catch (_) {
      return _getSurahContentApi(surahNumber);
    }
  }

  Future<List<AyahModel>> _getSurahContentLocal(int surahNumber) async {
    await _loadFullQuran();
    final surah = _fullQuran!.firstWhere(
      (s) => s['number'] == surahNumber,
    ) as Map<String, dynamic>;
    final ayahs = surah['ayahs'] as List;
    final offset = _ayahOffsets![surahNumber]!;

    return List.generate(ayahs.length, (i) {
      return AyahModel(
        numberInSurah: ayahs[i]['number'] as int,
        numberInQuran: offset + i,
        text: ayahs[i]['text'] as String,
        translation: ayahs[i]['translation_en'] as String?,
        surahNumber: surahNumber,
      );
    });
  }

  Future<List<AyahModel>> _getSurahContentApi(int surahNumber) async {
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
    try {
      final res = await dio.get(
        'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/ar.muyassar',
      );
      return res.data['data']['text'] as String;
    } catch (_) {
      return '';
    }
  }

  Future<String> getTafsirByEdition(int surahNumber, int ayahNumber, TafsirEdition edition) async {
    try {
      final res = await dio.get(
        'https://api.quran.com/api/v4/tafsirs/${edition.id}/by_ayah/$surahNumber:$ayahNumber',
      );
      final tafsir = res.data['tafsir'] as Map<String, dynamic>;
      String text = tafsir['text'] as String? ?? '';
      text = text.replaceAll(RegExp(r'<[^>]*>'), '');
      text = text.replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&amp;', '&');
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
      return text;
    } catch (_) {
      return '';
    }
  }

  Future<Map<String, dynamic>> getTafsirWithAyah(int surahNumber, int ayahNumber) async {
    try {
      final res = await dio.get(
        'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahNumber/ar.muyassar',
      );
      final data = res.data['data'] as Map<String, dynamic>;
      return {
        'tafsir': data['text'] as String,
        'ayah': data['ayah'] ?? '',
      };
    } catch (_) {
      return {'tafsir': '', 'ayah': ''};
    }
  }

  static String _normalize(String s) {
    return s
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و');
  }

  Future<List<Map<String, dynamic>>> searchQuran(String query) async {
    await _loadFullQuran();
    final results = <Map<String, dynamic>>[];
    final q = query.trim();
    if (q.isEmpty) return results;
    final nq = _normalize(q);

    try {
      for (final surah in _fullQuran!) {
        final sn = surah['number'] as int;
        final ayahs = surah['ayahs'] as List;
        for (final ayah in ayahs) {
          final text = ayah['text'] as String;
          final translation = ayah['translation_en'] as String? ?? '';

          if (_normalize(text).contains(nq)) {
            results.add({
              'surah': sn,
              'ayah': ayah['number'] as int,
              'text': text,
              'translation': translation,
              'matchIn': 'arabic',
            });
          } else if (translation.isNotEmpty && translation.toLowerCase().contains(q.toLowerCase())) {
            results.add({
              'surah': sn,
              'ayah': ayah['number'] as int,
              'text': text,
              'translation': translation,
              'matchIn': 'translation',
            });
          }
        }
      }
    } catch (_) {}

    return results;
  }

  Future<List<WordMeaning>> getWordMeanings(int surahNumber, int ayahNumber) async {
    try {
      final res = await dio.get(
        'https://api.quran.com/api/v4/verses/by_key/$surahNumber:$ayahNumber',
        queryParameters: {
          'words': 'true',
          'word_fields': 'text_uthmani,translation',
        },
      );
      final verse = res.data['verse'] as Map<String, dynamic>;
      final words = verse['words'] as List;
      return words.map((w) => WordMeaning.fromJson(w as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<String> getAsbabAlNuzul(int surahNumber, int ayahNumber) async {
    try {
      final json = await rootBundle.loadString('assets/tafsir/asbab_al_nuzul.json');
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data['$surahNumber:$ayahNumber'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<Map<String, dynamic>?> getAyahByReference(int surahNumber, int ayahNumber) async {
    await _loadFullQuran();
    try {
      final surah = _fullQuran!.firstWhere((s) => s['number'] == surahNumber);
      final ayahs = surah['ayahs'] as List;
      final ayah = ayahs.firstWhere((a) => a['number'] == ayahNumber);
      return {
        'surah': surahNumber,
        'ayah': ayahNumber,
        'text': ayah['text'] as String,
        'translation': ayah['translation_en'] as String?,
      };
    } catch (_) {
      return null;
    }
  }
}
