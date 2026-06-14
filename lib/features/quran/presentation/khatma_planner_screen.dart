import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/storage/local_storage.dart';

const int _totalPages = 604;
const int _totalJuz = 30;
const List<int> _juzPageStart = [
  1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
  202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
  402, 422, 442, 462, 482, 502, 522, 542, 562, 582,
];

int _pageToJuz(int page) {
  for (int i = _totalJuz - 1; i >= 0; i--) {
    if (page >= _juzPageStart[i]) { return i + 1; }
  }
  return 1;
}

String _juzRangeText(int start, int end) {
  if (start == end) return 'الجزء $start';
  return 'الجزء $start - $end';
}

String _pageRangeText(int start, int end) {
  if (start == end) return 'الصفحة $start';
  return 'الصفحات $start - $end';
}

class _KhatmaPlan {
  final int totalDays;
  final DateTime startDate;
  final List<int> completedDays;

  const _KhatmaPlan({
    required this.totalDays,
    required this.startDate,
    required this.completedDays,
  });

  Map<String, dynamic> toJson() => {
    'totalDays': totalDays,
    'startDate': startDate.toIso8601String(),
    'completedDays': completedDays,
  };

  factory _KhatmaPlan.fromJson(Map<String, dynamic> json) => _KhatmaPlan(
    totalDays: json['totalDays'] as int,
    startDate: DateTime.parse(json['startDate'] as String),
    completedDays: List<int>.from(json['completedDays'] as List),
  );

  double get progress => totalDays > 0 ? completedDays.length / totalDays : 0;

  int get currentDayIndex {
    final diff = DateTime.now().difference(startDate).inDays;
    return diff.clamp(0, totalDays - 1);
  }

  int get streak {
    if (completedDays.isEmpty) return 0;
    final sorted = List<int>.from(completedDays)..sort();
    int count = 1;
    for (int i = sorted.length - 2; i >= 0; i--) {
      if (sorted[i] == sorted[i + 1] - 1) {
        count++;
      } else { break; }
    }
    return count;
  }

  String? get milestone {
    final p = progress;
    if (p >= 1.0) return '🎉 تهانينا! أكملت الختمة';
    if (p >= 0.75) return '🌟 ربع الأخير — واصل القراءة!';
    if (p >= 0.5) return '💪 نصف الختمة — استمر!';
    if (p >= 0.25) return '✨ ربع الختمة — بارك الله فيك!';
    if (p >= 0.1) return '🌱 بداية موفقة — استمر!';
    return null;
  }

  ({int juzStart, int juzEnd, int pageStart, int pageEnd}) dailyReading(
    int dayIndex,
  ) {
    final pagesPerDay = _totalPages / totalDays;
    final rawStart = dayIndex * pagesPerDay;
    final rawEnd = (dayIndex + 1) * pagesPerDay;
    final pageStart = rawStart.floor() + 1;
    final pageEnd = rawEnd.ceil().clamp(1, _totalPages);
    final juzStart = _pageToJuz(pageStart);
    final juzEnd = _pageToJuz(pageEnd);
    return (
      juzStart: juzStart,
      juzEnd: juzEnd,
      pageStart: pageStart,
      pageEnd: pageEnd,
    );
  }

  int get actualDaysTaken {
    if (completedDays.isEmpty) return 0;
    final sorted = List<int>.from(completedDays)..sort();
    return sorted.last - sorted.first + 1;
  }

  bool isDayComplete(int dayIndex) => completedDays.contains(dayIndex);

  int get remainingDays => totalDays - completedDays.length;
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _ArcPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final bgPaint = Paint()
      ..color = AppColors.goldMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, bgPaint);

    if (progress > 0) {
      final gradient = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: const [AppColors.goldLight, AppColors.gold],
      );
      final progressPaint = Paint()
        ..shader = gradient.createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

class _GradientCircularProgress extends StatelessWidget {
  final double progress;

  const _GradientCircularProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    const size = 180.0;
    const strokeWidth = 12.0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(progress: progress, strokeWidth: strokeWidth),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Inter',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'مكتمل',
                style: TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontFamily: 'Amiri',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KhatmaPlannerScreen extends ConsumerStatefulWidget {
  const KhatmaPlannerScreen({super.key});

  @override
  ConsumerState<KhatmaPlannerScreen> createState() =>
      _KhatmaPlannerScreenState();
}

class _KhatmaPlannerScreenState extends ConsumerState<KhatmaPlannerScreen> {
  final LocalStorage _storage = LocalStorage();
  double _setupDays = 30;
  _KhatmaPlan? _plan;
  String? _lastMilestone;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  void _loadPlan() {
    final raw = _storage.getString('khatma_plan');
    if (raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        setState(() => _plan = _KhatmaPlan.fromJson(json));
      } catch (_) {}
    }
  }

  Future<void> _savePlan() async {
    if (_plan == null) return;
    await _storage.saveString('khatma_plan', jsonEncode(_plan!.toJson()));
  }

  void _startPlan() {
    final days = _setupDays.toInt();
    final plan = _KhatmaPlan(
      totalDays: days,
      startDate: DateTime.now(),
      completedDays: [],
    );
    setState(() => _plan = plan);
    _storage.saveString('khatma_plan', jsonEncode(plan.toJson()));
  }

  Future<void> _toggleDay(int dayIndex) async {
    if (_plan == null) return;
    final completed = List<int>.from(_plan!.completedDays);
    if (completed.contains(dayIndex)) {
      completed.remove(dayIndex);
    } else {
      completed.add(dayIndex);
      completed.sort();
    }
    final updated = _KhatmaPlan(
      totalDays: _plan!.totalDays,
      startDate: _plan!.startDate,
      completedDays: completed,
    );
    setState(() => _plan = updated);
    await _savePlan();

    final msg = updated.milestone;
    if (msg != null && msg != _lastMilestone) {
      _lastMilestone = msg;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.navyLight,
          ),
        );
      }
    }
  }

  void _resetPlan() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyLight,
        title: const Text(
          'بدء ختمة جديدة',
          style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri'),
        ),
        content: const Text(
          'سيتم حذف التقدم الحالي. هل أنت متأكد؟',
          style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textOnDarkMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _storage.saveString('khatma_plan', '');
              setState(() {
                _plan = null;
                _lastMilestone = null;
              });
            },
            child: const Text(
              'تأكيد',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  void _shareProgress() {
    if (_plan == null) return;
    final pct = (_plan!.progress * 100).toStringAsFixed(1);
    final text = '📖 ختمتي القرآنية\n'
        'الإنجاز: $pct%\n'
        'الأيام المنجزة: ${_plan!.completedDays.length} من ${_plan!.totalDays}\n'
        'المثابرة: ${_plan!.streak} أيام متتالية\n'
        '${_plan!.milestone ?? "بارك الله في جهودك"}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text(
          'مخطط الختمة',
          style: TextStyle(fontFamily: 'Amiri'),
        ),
        backgroundColor: AppColors.navy,
        elevation: 0,
        actions: [
          if (_plan != null) ...[
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.gold),
              tooltip: 'مشاركة التقدم',
              onPressed: _shareProgress,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.gold),
              tooltip: 'ختمة جديدة',
              onPressed: _resetPlan,
            ),
          ],
        ],
      ),
      body: _plan == null ? _buildSetupPhase() : _buildTrackingPhase(),
    );
  }

  Widget _buildSetupPhase() {
    final pagesPerDay = (_totalPages / _setupDays).ceil();
    final juzPerDay = (_totalJuz / _setupDays).ceil();
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'كم يوماً تريد لختم القرآن؟',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          Center(
            child: Text(
              '${_setupDays.toInt()} يوماً',
              style: const TextStyle(
                color: AppColors.white,
                fontFamily: 'Inter',
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Slider(
            value: _setupDays,
            min: 3,
            max: 90,
            divisions: 87,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.goldMuted,
            onChanged: (val) => setState(() => _setupDays = val),
          ),
          const SizedBox(height: AppDimensions.xxl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.xl),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: Border.all(color: AppColors.goldMuted),
            ),
            child: Column(
              children: [
                const Text(
                  'خطة القراءة اليومية',
                  style: TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontFamily: 'Amiri',
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$juzPerDay',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Inter',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    const Text(
                      'أجزاء يومياً',
                      style: TextStyle(
                        color: AppColors.white,
                        fontFamily: 'Amiri',
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  'بمعدل $pagesPerDay صفحة في اليوم',
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                ),
              ),
              child: const Text(
                'بدء الختمة',
                style: TextStyle(
                  color: AppColors.navy,
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingPhase() {
    final plan = _plan!;
    final currentDay = plan.currentDayIndex;
    final total = plan.totalDays;
    final completed = plan.completedDays.length;
    final remaining = plan.remainingDays;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.lg,
        AppDimensions.xxl,
      ),
      itemCount: total + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildProgressHeader(plan, completed, total, remaining);
        }
        if (index == 1) {
          return _buildActions(plan, currentDay);
        }
        final dayIndex = index - 2;
        return _buildDayTile(plan, dayIndex, currentDay);
      },
    );
  }

  Widget _buildProgressHeader(
    _KhatmaPlan plan,
    int completed,
    int total,
    int remaining,
  ) {
    return Column(
      children: [
        const SizedBox(height: AppDimensions.md),
        Center(
          child: _GradientCircularProgress(progress: plan.progress),
        ),
        const SizedBox(height: AppDimensions.xl),
        Row(
          children: [
            _StatBox(label: 'إجمالي الأيام', value: '$total'),
            _StatBox(label: 'الأيام المنجزة', value: '$completed'),
            _StatBox(label: 'الأيام المتبقية', value: '$remaining'),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.md,
            horizontal: AppDimensions.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.goldMuted),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppColors.gold, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'سلسلة القراءة: ${plan.streak} أيام متتالية',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (plan.milestone != null && plan.progress < 1.0) ...[
          const SizedBox(height: AppDimensions.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(
              plan.milestone!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontFamily: 'Amiri',
                fontSize: 16,
              ),
            ),
          ),
        ],
        if (plan.progress >= 1.0) ...[
          const SizedBox(height: AppDimensions.lg),
          _buildCelebration(plan),
        ],
        const SizedBox(height: AppDimensions.lg),
      ],
    );
  }

  Widget _buildCelebration(_KhatmaPlan plan) {
    final completionDate =
        plan.startDate.add(Duration(days: plan.actualDaysTaken));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, AppColors.goldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: AppDimensions.md),
          const Text(
            'تمت الختمة بنجاح!',
            style: TextStyle(
              color: AppColors.navy,
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'تاريخ الإكمال: ${completionDate.year}/${completionDate.month}/${completionDate.day}',
            style: const TextStyle(
              color: AppColors.navy,
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'عدد الأيام: ${plan.actualDaysTaken} يوماً',
            style: const TextStyle(
              color: AppColors.navy,
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Text(
              'اللهم ارحمني بالقرآن العظيم، واجعله لي إماماً ونوراً وهدى ورحمة، اللهم ذكرني منه ما نسيت، وعلمني منه ما جهلت، وارزقني تلاوته آناء الليل وأطراف النهار، واجعله لي حجة يا رب العالمين',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.navy,
                fontFamily: 'Amiri',
                fontSize: 14,
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(_KhatmaPlan plan, int currentDay) {
    final reading = plan.dailyReading(currentDay);
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/mushaf'),
            icon: const Icon(Icons.menu_book, color: AppColors.navy),
            label: Text(
              'قراءة اليوم: ${_pageRangeText(reading.pageStart, reading.pageEnd)}',
              style: const TextStyle(
                color: AppColors.navy,
                fontFamily: 'Amiri',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'قائمة القراءة اليومية',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
      ],
    );
  }

  Widget _buildDayTile(_KhatmaPlan plan, int dayIndex, int currentDay) {
    final isCurrentDay = dayIndex == currentDay;
    final isComplete = plan.isDayComplete(dayIndex);
    final reading = plan.dailyReading(dayIndex);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isCurrentDay ? AppColors.gold : AppColors.goldMuted,
            width: isCurrentDay ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => _toggleDay(dayIndex),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentDay
                        ? AppColors.gold.withValues(alpha: 0.2)
                        : AppColors.goldMuted,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrentDay
                          ? AppColors.gold
                          : AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${dayIndex + 1}',
                      style: TextStyle(
                        color: isCurrentDay
                            ? AppColors.gold
                            : AppColors.textOnDarkMuted,
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
                        _juzRangeText(reading.juzStart, reading.juzEnd),
                        style: TextStyle(
                          color: isCurrentDay
                              ? AppColors.gold
                              : AppColors.textOnDark,
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _pageRangeText(reading.pageStart, reading.pageEnd),
                        style: const TextStyle(
                          color: AppColors.textOnDarkMuted,
                          fontFamily: 'Inter',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentDay)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: const Text(
                      'اليوم',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Amiri',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(width: AppDimensions.sm),
                GestureDetector(
                  onTap: () => _toggleDay(dayIndex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isComplete ? AppColors.gold : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isComplete ? AppColors.gold : AppColors.goldMuted,
                        width: 2,
                      ),
                    ),
                    child: isComplete
                        ? const Icon(Icons.check, color: AppColors.navy, size: 18)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textOnDarkMuted,
                fontFamily: 'Amiri',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
