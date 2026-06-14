import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/di/providers.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/daily_hadith.dart';
import '../../../core/utils/daily_suggestion.dart';
import 'dart:async';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/prayer_calculator.dart';
import 'widgets/progress_tracker_row.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/continue_reading_card.dart';
import 'widgets/recent_activity_section.dart';

final dailyVerseProvider = FutureProvider<DailyVerse>((ref) async {
  return DailyVerseSelector.getDailyVerse();
});

final dailyHadithProvider = FutureProvider<DailyHadith>((ref) async {
  return DailyHadithSelector.getDailyHadith();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _dayNames = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  static const _hijriMonths = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(prayerScheduleProvider);
    final verseAsync = ref.watch(dailyVerseProvider);
    final hadithAsync = ref.watch(dailyHadithProvider);
    final storage = LocalStorage();
    final now = DateTime.now();
    final today = HijriCalendar.now();
    final dayName = _dayNames[now.weekday - 1];
    final hijriMonth = _hijriMonths[today.hMonth - 1];
    final suggestion = DailySuggestion.getForToday();

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppDimensions.sm),

                  // ========== DATE + PRAYER ROW ==========
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => context.push('/calendar'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: AppDimensions.sm),
                            decoration: BoxDecoration(
                              color: AppColors.navyLight,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              border: Border.all(color: AppColors.goldMuted),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.gold, size: 14),
                                const SizedBox(height: 2),
                                Text(dayName, style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 11, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text('${today.hDay} $hijriMonth', style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 10)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        flex: 5,
                        child: scheduleAsync.when(
                          loading: () => Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.navyLight,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold))),
                          ),
                          error: (_, __) => Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.navyLight,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            child: const Center(child: Icon(Icons.error_outline, color: AppColors.goldMuted)),
                          ),
                          data: (schedule) => _CompactPrayerCard(schedule: schedule),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),

                  // ========== SUGGESTION OF THE DAY (compact) ==========
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.navyLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.goldMuted),
                    ),
                    child: Row(
                      children: [
                        Text(suggestion.icon ?? '🌟', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            suggestion.text,
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),

                  // ========== AYAH OF THE DAY (compact) ==========
                  verseAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (verse) => _CompactVerseCard(verse: verse),
                  ),
                  if (verseAsync.hasValue) const SizedBox(height: AppDimensions.xs),

                  // ========== HADITH OF THE DAY (compact) ==========
                  hadithAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (hadith) => _CompactHadithCard(hadith: hadith),
                  ),
                  if (hadithAsync.hasValue) const SizedBox(height: AppDimensions.sm),

                  // ========== QUICK ACTIONS ==========
                  const QuickActionsGrid(),
                  const SizedBox(height: AppDimensions.sm),

                  // ========== CONTINUE READING ==========
                  const ContinueReadingCard(),
                  const SizedBox(height: AppDimensions.sm),

                  // ========== RECENTLY USED ==========
                  const RecentActivitySection(),
                  const SizedBox(height: AppDimensions.sm),

                  // ========== PROGRESS ==========
                  ProgressTrackerRow(storage: storage),
                  const SizedBox(height: AppDimensions.lg),

                  // ========== MOOD SECTION ==========
                  _buildMoodSection(context),
                  const SizedBox(height: AppDimensions.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection(BuildContext context) {
    const moods = [
      ('😰', 'قلق'),
      ('🙏', 'شاكر'),
      ('😢', 'حزين'),
      ('😊', 'سعيد'),
      ('😴', 'متعب'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('كيف تشعر الآن؟',
          style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => context.push('/dua'),
                child: Container(
                  width: 56,
                  margin: const EdgeInsets.only(left: AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.navyLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: AppColors.goldMuted),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(moods[i].$1, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(moods[i].$2,
                        style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.sm, AppDimensions.lg, AppDimensions.xs),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: Image.asset('assets/images/app_icon.png', height: 32, width: 32),
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('إبراهيم',
                style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w700, height: 1.2)),
              Text('رفيقك الديني',
                style: TextStyle(color: AppColors.goldLight, fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, height: 1.2)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/surah-audio'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.headphones, color: AppColors.gold, size: 18),
            ),
          ),
          const SizedBox(width: AppDimensions.xs),
          GestureDetector(
            onTap: () => context.push('/global-search'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.search, color: AppColors.gold, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPrayerCard extends StatefulWidget {
  final PrayerScheduleModel schedule;
  const _CompactPrayerCard({required this.schedule});

  @override
  State<_CompactPrayerCard> createState() => _CompactPrayerCardState();
}

class _CompactPrayerCardState extends State<_CompactPrayerCard> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _update();
    });
  }

  void _update() {
    setState(() {
      _remaining = widget.schedule.timeUntilNextPrayer;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/prayer-times'),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB8973C), AppColors.gold, Color(0xFFE8C97A)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
        child: Row(
          children: [
            const Icon(Icons.mosque, color: AppColors.navy, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.schedule.nextPrayerName,
                    style: const TextStyle(color: AppColors.navy, fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'متبقي ${_formatDuration(_remaining)}',
                    style: const TextStyle(color: AppColors.navy, fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.navy, size: 12),
          ],
        ),
      ),
    );
  }
}

class _CompactVerseCard extends StatelessWidget {
  final DailyVerse verse;
  const _CompactVerseCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, color: AppColors.gold, size: 13),
              const SizedBox(width: 4),
              Text('آية اليوم', style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '﴿ ${verse.arabic} ﴾',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 16, height: 1.6, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 2),
          Text(
            '— سورة ${verse.surah}، الآية ${verse.ayah}',
            style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Amiri', fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CompactHadithCard extends StatelessWidget {
  final DailyHadith hadith;
  const _CompactHadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat, color: AppColors.gold, size: 13),
              const SizedBox(width: 4),
              Text('حديث اليوم — ${hadith.number}', style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(hadith.source, style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Inter', fontSize: 9)),
          ),
          const SizedBox(height: 4),
          Text(
            'عن ${hadith.narrator} رضي الله عنه قال:',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Amiri', fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '«${hadith.arabic}»',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 4),
          Container(height: 1, decoration: const BoxDecoration(color: AppColors.goldMuted)),
          const SizedBox(height: 4),
          Text(
            hadith.translation,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}


