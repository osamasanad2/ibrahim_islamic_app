import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/quran/quran_providers.dart';
import '../../../data/quran/surah_meta.dart';

class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);
    final surahs = surahsAsync.valueOrNull ?? [];
    final resultsAsync = ref.watch(searchQuranProvider(_query));

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('البحث في القرآن'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16),
              decoration: InputDecoration(
                hintText: 'ابحث عن كلمة أو آية...',
                hintStyle: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 16),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textOnDarkMuted),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.navyLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: const BorderSide(color: AppColors.goldMuted),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
              onSubmitted: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, color: AppColors.goldMuted, size: 64),
                        const SizedBox(height: AppDimensions.lg),
                        const Text(
                          'ابحث في القرآن الكريم',
                          style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 18),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        const Text(
                          'أدخل كلمة أو جملة للبحث',
                          style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : resultsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    error: (e, _) => Center(
                      child: Text('حدث خطأ: $e', style: const TextStyle(color: Colors.red, fontFamily: 'Amiri')),
                    ),
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, color: AppColors.textOnDarkMuted, size: 48),
                              const SizedBox(height: AppDimensions.md),
                              const Text(
                                'لا نتائج',
                                style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18),
                              ),
                              const SizedBox(height: AppDimensions.sm),
                              Text(
                                'لا توجد آيات تحتوي على "$_query"',
                                style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                            child: Text(
                              '${results.length} نتيجة للبحث عن "$_query"',
                              style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Amiri', fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final r = results[index];
                                final surah = surahs.firstWhere(
                                  (s) => s.number == r['surah'],
                                  orElse: () => SurahMeta(number: r['surah'] as int, nameArabic: 'سورة ${r['surah']}', nameEnglish: '', nameTransliteration: '', ayahs: 0, revelationType: '', startPage: 0),
                                );
                                return _SearchResultCard(
                                  surahName: surah.nameArabic,
                                  surahNumber: r['surah'] as int,
                                  ayahNumber: r['ayah'] as int,
                                  text: r['text'] as String,
                                  query: _query,
                                  translation: r['translation'] as String?,
                                  matchIn: r['matchIn'] as String?,
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String? translation;
  final String query;
  final String? matchIn;

  const _SearchResultCard({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.query,
    this.translation,
    this.matchIn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/surah-reader', extra: {'surah': surahNumber, 'ayah': ayahNumber, 'surahName': surahName}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(color: AppColors.goldMuted, shape: BoxShape.circle),
                  child: Center(
                    child: Text('$ayahNumber',
                      style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(surahName,
                  style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (matchIn == 'translation')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
                    ),
                    child: const Text('ترجمة', style: TextStyle(color: AppColors.goldLight, fontFamily: 'Inter', fontSize: 9)),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, color: AppColors.goldMuted, size: 12),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            _HighlightedText(text: text, query: query),
            if (translation != null && translation!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(translation!,
                style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 11, height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  static String _stripDiacritics(String s) {
    return s.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
  }

  static String _normalize(String s) {
    return _stripDiacritics(s)
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ئ', 'ي')
        .replaceAll('ؤ', 'و');
  }

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, height: 1.6));
    }

    final nText = _normalize(text);
    final nQuery = _normalize(query);
    final idx = nText.indexOf(nQuery);

    if (idx == -1) {
      return Text(text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, height: 1.6));
    }

    String variants(String c) {
      if (c == 'ا') return '[اأإآٱ]';
      if (c == 'ي') return '[يىئ]';
      if (c == 'ه') return '[هة]';
      if (c == 'و') return '[وؤ]';
      return RegExp.escape(c);
    }

    final pattern = StringBuffer();
    for (var i = 0; i < nQuery.length; i++) {
      if (i > 0) pattern.write(r'[\u064B-\u0652\u0670]*');
      pattern.write(variants(nQuery[i]));
    }
    final match = RegExp(pattern.toString()).firstMatch(text);

    if (match == null) {
      return Text(text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, height: 1.6));
    }

    final before = text.substring(0, match.start);
    final matched = text.substring(match.start, match.end);
    final after = text.substring(match.end);

    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, height: 1.6),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: matched,
            style: const TextStyle(backgroundColor: Color(0x40D4AF37), color: Color(0xFFFFD700)),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
