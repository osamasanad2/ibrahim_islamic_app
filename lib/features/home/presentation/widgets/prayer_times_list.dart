import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/prayer_calculator.dart';

class PrayerTimesList extends StatelessWidget {
  final PrayerScheduleModel schedule;
  const PrayerTimesList({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      ('الفجر', schedule.fajr, Icons.brightness_3),
      ('الظهر', schedule.dhuhr, Icons.wb_sunny_outlined),
      ('العصر', schedule.asr, Icons.cloud),
      ('المغرب', schedule.maghrib, Icons.wb_twilight),
      ('العشاء', schedule.isha, Icons.nightlight_round),
    ];

    return GestureDetector(
      onTap: () => context.push('/prayer-times'),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.gold, size: 16),
                const SizedBox(width: AppDimensions.xs),
                const Text(
                  'مواقيت الصلاة',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  schedule.nextPrayerName,
                  style: const TextStyle(
                    color: AppColors.goldMuted,
                    fontFamily: 'Amiri',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('التالي',
                    style: TextStyle(color: AppColors.navy, fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Divider(color: AppColors.goldMuted, height: AppDimensions.md),
            ...prayers.map((p) => _buildRow(p.$1, p.$2, p.$3)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String name, DateTime time, IconData icon) {
    final isNext = name == schedule.nextPrayerName;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: isNext ? AppColors.gold : AppColors.textOnDarkMuted, size: 16),
          const SizedBox(width: AppDimensions.sm),
          Text(
            name,
            style: TextStyle(
              color: isNext ? AppColors.gold : AppColors.textOnDark,
              fontFamily: 'Amiri',
              fontSize: 15,
              fontWeight: isNext ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: isNext ? AppColors.gold : AppColors.textOnDark,
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isNext) ...[
            const SizedBox(width: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: const Text('الآن',
                style: TextStyle(color: AppColors.navy, fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}
