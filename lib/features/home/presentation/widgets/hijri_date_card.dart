import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class HijriDateCard extends StatefulWidget {
  const HijriDateCard({super.key});

  @override
  State<HijriDateCard> createState() => _HijriDateCardState();
}

class _HijriDateCardState extends State<HijriDateCard> {
  late HijriCalendar _today;

  static const _dayNames = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  static const _hijriMonths = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];
  static const _miladiMonths = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

  @override
  void initState() {
    super.initState();
    _today = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayName = _dayNames[now.weekday - 1];
    final hijriMonth = _hijriMonths[_today.hMonth - 1];
    final miladiMonth = _miladiMonths[now.month - 1];

    return GestureDetector(
      onTap: () => context.push('/calendar'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.goldMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.calendar_month, color: AppColors.gold, size: 22),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dayName $_today.hDay $hijriMonth $_today.hYear هـ',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${now.day} $miladiMonth ${now.year}م',
                    style: const TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontFamily: 'Amiri',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.goldMuted, size: 12),
          ],
        ),
      ),
    );
  }
}
