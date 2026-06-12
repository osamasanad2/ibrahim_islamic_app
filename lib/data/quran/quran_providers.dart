import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import 'ayah_model.dart';
import 'quran_repository.dart';
import 'surah_meta.dart';
import 'word_meaning.dart';
import 'tafsir_edition.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(ref.read(dioProvider));
});

final surahListProvider = FutureProvider<List<SurahMeta>>((ref) async {
  return ref.read(quranRepositoryProvider).getSurahList();
});

final surahContentProvider = FutureProvider.family<List<AyahModel>, int>((ref, surahNumber) async {
  return ref.read(quranRepositoryProvider).getSurahContent(surahNumber);
});

final pageAyahsProvider = FutureProvider.family<List<dynamic>, int>((ref, page) async {
  return ref.read(quranRepositoryProvider).getPageAyahs(page);
});

final tafsirProvider = FutureProvider.family<String, ({int surah, int ayah})>((ref, params) async {
  return ref.read(quranRepositoryProvider).getTafsir(params.surah, params.ayah);
});

final multiTafsirProvider = FutureProvider.family<String, ({int surah, int ayah, TafsirEdition edition})>((ref, params) async {
  return ref.read(quranRepositoryProvider).getTafsirByEdition(params.surah, params.ayah, params.edition);
});

final wordMeaningsProvider = FutureProvider.family<List<WordMeaning>, ({int surah, int ayah})>((ref, params) async {
  return ref.read(quranRepositoryProvider).getWordMeanings(params.surah, params.ayah);
});

final asbabProvider = FutureProvider.family<String, ({int surah, int ayah})>((ref, params) async {
  return ref.read(quranRepositoryProvider).getAsbabAlNuzul(params.surah, params.ayah);
});

final searchQuranProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  return ref.read(quranRepositoryProvider).searchQuran(query);
});
