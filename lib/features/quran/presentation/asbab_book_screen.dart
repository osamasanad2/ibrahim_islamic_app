import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/quran/asbab_entry.dart';
import '../../../data/quran/quran_providers.dart';
import '../../../data/quran/surah_meta.dart';

class AsbabBookScreen extends ConsumerWidget {
  const AsbabBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(asbabBookProvider);
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('كتاب أسباب النزول'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: surahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (_, __) => const Center(
          child: Text(
            'تعذر تحميل البيانات',
            style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 18),
          ),
        ),
        data: (surahs) => async.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (_, __) => const Center(
            child: Text(
              'تعذر تحميل الكتاب',
              style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 18),
            ),
          ),
          data: (entries) => _BookContent(surahs: surahs, entries: entries),
        ),
      ),
    );
  }
}

class _BookContent extends StatelessWidget {
  final List<SurahMeta> surahs;
  final List<AsbabEntry> entries;

  const _BookContent({required this.surahs, required this.entries});

  @override
  Widget build(BuildContext context) {
    final generalEntries = entries.where((e) => e.type == 'general').toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _BookHeader(surahCount: surahs.length, entryCount: generalEntries.length),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'فهرس السور',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                const Divider(color: AppColors.goldMuted),
                const SizedBox(height: AppDimensions.sm),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final surah = surahs[index];
              final entry = generalEntries.where((e) => e.surahNumber == surah.number).firstOrNull;
              return _SurahCard(surah: surah, entry: entry);
            },
            childCount: surahs.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xxl)),
      ],
    );
  }
}

class _BookHeader extends StatelessWidget {
  final int surahCount;
  final int entryCount;

  const _BookHeader({required this.surahCount, required this.entryCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.goldMuted, AppColors.navyLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(Icons.menu_book, color: AppColors.gold, size: 36),
          ),
          const SizedBox(height: AppDimensions.md),
          const Text(
            'كتاب أسباب النزول',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnDark,
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          const Text(
            'للإمام أبي الحسن علي بن أحمد الواحدي',
            style: TextStyle(color: AppColors.goldMuted, fontFamily: 'Inter', fontSize: 14),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: const Text(
              'القرن الخامس الهجري',
              style: TextStyle(
                color: AppColors.gold,
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          const Text(
            'كتاب يذكر فيه المؤلف أسباب نزول القرآن الكريم لكل سورة وآية، '
            'مستنداً إلى الأحاديث النبوية والآثار عن الصحابة والتابعين. '
            'يعد من أشهر المصنفات في علم أسباب النزول وأقدمها.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnDarkMuted,
              fontFamily: 'Amiri',
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          const Divider(color: AppColors.goldMuted),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Text(
                '$surahCount سورة - $entryCount مدخلاً',
                style: const TextStyle(
                  color: AppColors.goldMuted,
                  fontFamily: 'Amiri',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final SurahMeta surah;
  final AsbabEntry? entry;

  const _SurahCard({required this.surah, this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          onTap: () {
            context.push('/asbab-surah', extra: {
              'surah': surah.number,
              'surahName': surah.nameArabic,
              'entry': entry?.toJson(),
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سورة ${surah.nameArabic}',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: AppColors.textOnDark,
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                        style: const TextStyle(
                          color: AppColors.goldMuted,
                          fontFamily: 'Amiri',
                          fontSize: 12,
                        ),
                      ),
                      if (entry != null) ...[
                        const SizedBox(height: AppDimensions.sm),
                        Text(
                          entry!.text,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textOnDarkMuted,
                            fontFamily: 'Amiri',
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left, color: AppColors.goldMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
