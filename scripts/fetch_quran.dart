// Run: dart scripts/fetch_quran.dart
// Fetches all 114 surahs from alquran.cloud API and saves as a bundled JSON.

import 'dart:convert';
import 'dart:io';

final dio = _DioSim();

void main() async {
  print('Fetching surah list...');
  final res = await dio.get('https://api.alquran.cloud/v1/surah');
  final surahList = res['data'] as List;

  final allSurahs = <Map<String, dynamic>>[];

  for (final surah in surahList) {
    final number = surah['number'];
    print('Fetching surah $number...');

    final contentRes = await dio.get(
      'https://api.alquran.cloud/v1/surah/$number/editions/quran-uthmani,en.asad',
    );
    final editions = contentRes['data'] as List;
    final arabicAyahs = (editions[0]['ayahs'] as List);
    final englishAyahs = (editions[1]['ayahs'] as List);

    final ayahs = <Map<String, dynamic>>[];
    for (int i = 0; i < arabicAyahs.length; i++) {
      final a = arabicAyahs[i];
      final e = englishAyahs[i];
      ayahs.add({
        'number': a['number'],
        'numberInSurah': a['numberInSurah'],
        'text': a['text'],
        'translation': e['text'],
        'page': a['page'],
        'juz': a['juz'],
        'hizbQuarter': a['hizbQuarter'],
        'sajda': a['sajda'],
      });
    }

    allSurahs.add({
      'number': surah['number'],
      'name': surah['name'],
      'englishName': surah['englishName'],
      'englishNameTranslation': surah['englishNameTranslation'],
      'revelationType': surah['revelationType'],
      'ayahs': ayahs,
    });
  }

  final output = const JsonEncoder.withIndent('  ').convert(allSurahs);
  final file = File('assets/quran/quran_full.json');
  file.writeAsStringSync(output);
  print('Done! Saved ${allSurahs.length} surahs to assets/quran/quran_full.json');
  print('Total ayahs: ${allSurahs.fold<int>(0, (sum, s) => sum + (s['ayahs'] as List).length)}');
}

class _DioSim {
  Future<Map<String, dynamic>> get(String url) async {
    final process = await Process.run(
      'curl',
      ['-s', url],
      runInShell: true,
    );
    if (process.exitCode != 0) {
      throw Exception('Failed to fetch $url: ${process.stderr}');
    }
    return jsonDecode(process.stdout as String) as Map<String, dynamic>;
  }
}
