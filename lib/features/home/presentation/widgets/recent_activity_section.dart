import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/services/recent_activity_service.dart';

class RecentActivitySection extends ConsumerWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);

    if (activities.isEmpty) return const SizedBox.shrink();

    final displayList = activities.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مؤخراً',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        ...displayList.map((a) => _ActivityItem(activity: a)),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final RecentActivity activity;
  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (activity.extra != null && activity.extra!.isNotEmpty) {
          context.push(activity.route, extra: activity.extra);
        } else {
          context.push(activity.route);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Row(
          children: [
            Text(activity.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (activity.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        activity.subtitle,
                        style: const TextStyle(
                          color: AppColors.textOnDarkMuted,
                          fontFamily: 'Inter',
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textOnDarkMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
