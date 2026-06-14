import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/quran/quran_providers.dart';
import '../../../data/quran/surah_meta.dart';

class TajweedIndexScreen extends ConsumerStatefulWidget {
  const TajweedIndexScreen({super.key});

  @override
  ConsumerState<TajweedIndexScreen> createState() => _TajweedIndexScreenState();
}

class _TajweedIndexScreenState extends ConsumerState<TajweedIndexScreen> {
  List<SurahMeta> _filtered = [];
  bool _loaded = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final surahs = ref.read(surahListProvider).valueOrNull ?? [];
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? surahs
          : surahs.where((s) =>
              s.nameArabic.contains(q) ||
              s.nameEnglish.toLowerCase().contains(q) ||
              s.number.toString() == q).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('المصحف الملون بالتجويد'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearch(),
          Expanded(
            child: surahsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: AppColors.textOnDarkMuted, size: 48),
                    const SizedBox(height: AppDimensions.md),
                    const Text('تعذّر تحميل السور', style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 20)),
                    const SizedBox(height: AppDimensions.md),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(surahListProvider),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                      child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.navy)),
                    ),
                  ],
                ),
              ),
              data: (surahs) {
                if (!_loaded) {
                  _filtered = surahs;
                  _loaded = true;
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final surah = _filtered[index];
                    return _TajweedSurahTile(surah: surah);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: TextField(
        controller: _searchCtrl,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16),
        decoration: InputDecoration(
          hintText: 'ابحث عن سورة...',
          hintStyle: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: AppColors.gold),
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
      ),
    );
  }
}

class _TajweedSurahTile extends StatelessWidget {
  final SurahMeta surah;
  const _TajweedSurahTile({required this.surah});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/tajweed-reader', extra: {'surah': surah.number, 'surahName': surah.nameArabic}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.goldMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameArabic,
                    style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${surah.ayahs} آية',
                    style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 11),
                  ),
                ],
              ),
            ),
            Text(
              surah.nameEnglish,
              style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 12),
            ),
            const SizedBox(width: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Text(
                'تجويد',
                style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
