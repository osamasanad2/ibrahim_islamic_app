import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/quran/asbab_entry.dart';
import '../../../data/quran/quran_providers.dart';

class AsbabSurahDetailScreen extends ConsumerWidget {
  final int surahNumber;
  final String surahName;
  final AsbabEntry? initialEntry;

  const AsbabSurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialEntry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generalAsync = ref.watch(surahAsbabProvider(surahNumber));
    final allAsync = ref.watch(asbabBookProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: Text(surahName),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: generalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (_, __) => const Center(
          child: Text(
            'تعذر تحميل البيانات',
            style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 18),
          ),
        ),
        data: (generalEntry) {
          if (generalEntry == null && initialEntry == null) {
            return const Center(
              child: Text(
                'لا توجد معلومات متاحة',
                style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 18),
              ),
            );
          }

          final entry = generalEntry ?? initialEntry;

          return allAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
            error: (_, __) => _DetailContent(entry: entry!, specificEntries: []),
            data: (allEntries) {
              final specific = allEntries
                  .where((e) => e.surahNumber == surahNumber && e.type == 'specific')
                  .toList();
              return _DetailContent(entry: entry!, specificEntries: specific);
            },
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final AsbabEntry entry;
  final List<AsbabEntry> specificEntries;

  const _DetailContent({required this.entry, required this.specificEntries});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: const Text(
                        'سبب النزول العام',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (entry.source != null) ...[
                      const SizedBox(width: AppDimensions.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldMuted,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                        child: Text(
                          entry.source!,
                          style: const TextStyle(
                            color: AppColors.textOnDarkMuted,
                            fontFamily: 'Inter',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                const Divider(color: AppColors.goldMuted),
                const SizedBox(height: AppDimensions.md),
                Text(
                  entry.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    height: 2.0,
                  ),
                ),
              ],
            ),
          ),
          if (specificEntries.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.xl),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                const Text(
                  'أسباب نزول خاصة بآيات محددة',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            ...specificEntries.map((e) => _SpecificAyahCard(entry: e)),
          ],
        ],
      ),
    );
  }
}

class _SpecificAyahCard extends StatelessWidget {
  final AsbabEntry entry;

  const _SpecificAyahCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.goldMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              'الآية ${entry.ayahNumber}',
              style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Amiri',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            entry.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontFamily: 'Amiri',
              fontSize: 14,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}
