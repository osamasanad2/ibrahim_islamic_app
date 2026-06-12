import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/quran/quran_providers.dart';
import '../../../data/quran/surah_meta.dart';

final bookmarksListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final storage = LocalStorage();
  final bookmarks = storage.getBookmarks();
  if (bookmarks.isEmpty) return [];

  final repo = ref.read(quranRepositoryProvider);
  final surahs = await repo.getSurahList();
  final results = <Map<String, dynamic>>[];

  for (final refStr in bookmarks) {
    final parts = refStr.split(':');
    if (parts.length != 2) continue;
    final sn = int.tryParse(parts[0]);
    final an = int.tryParse(parts[1]);
    if (sn == null || an == null) continue;

    final ayah = await repo.getAyahByReference(sn, an);
    final surah = surahs.firstWhere(
      (s) => s.number == sn,
      orElse: () => SurahMeta(number: sn, nameArabic: 'سورة $sn', nameEnglish: '', nameTransliteration: '', ayahs: 0, revelationType: '', startPage: 0),
    );

    results.add({
      'surah': sn,
      'ayah': an,
      'text': ayah?['text'] ?? '',
      'surahName': surah.nameArabic,
      'ref': refStr,
    });
  }
  return results;
});

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('العلامات المرجعية'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('خطأ: $e', style: const TextStyle(color: Colors.red, fontFamily: 'Amiri')),
        ),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.goldMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldMuted),
                    ),
                    child: const Icon(Icons.bookmark_border, color: AppColors.gold, size: 40),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  const Text(
                    'لا توجد علامات مرجعية',
                    style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 20),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  const Text(
                    'اضغط على أيقونة bookmark بجانب آية لحفظها',
                    style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.lg),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final b = bookmarks[index];
              return _BookmarkCard(
                surahName: b['surahName'] as String,
                surahNumber: b['surah'] as int,
                ayahNumber: b['ayah'] as int,
                text: b['text'] as String,
                refStr: b['ref'] as String,
              );
            },
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatefulWidget {
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String refStr;

  const _BookmarkCard({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.refStr,
  });

  @override
  State<_BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<_BookmarkCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = true;
  }

  void _remove() {
    LocalStorage().removeBookmark(widget.refStr);
    setState(() => _isBookmarked = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إزالة الآية ${widget.ayahNumber} من ${widget.surahName}',
          style: const TextStyle(fontFamily: 'Amiri')),
        backgroundColor: AppColors.navyLight,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBookmarked) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/surah-reader', extra: {'surah': widget.surahNumber, 'ayah': widget.ayahNumber, 'surahName': widget.surahName}),
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
                    child: Text('${widget.ayahNumber}',
                      style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(widget.surahName,
                  style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: _remove,
                  child: const Icon(Icons.bookmark_remove, color: AppColors.goldMuted, size: 20),
                ),
              ],
            ),
            if (widget.text.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(widget.text,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}
