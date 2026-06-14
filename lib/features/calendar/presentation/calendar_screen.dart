import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/recent_activity_service.dart';

class IslamicEvent {
  final int month;
  final int day;
  final String name;
  final String type;
  final IconData icon;

  const IslamicEvent({
    required this.month,
    required this.day,
    required this.name,
    required this.type,
    required this.icon,
  });

  Color get color {
    switch (type) {
      case 'holiday':
        return AppColors.gold;
      case 'religious':
        return AppColors.success;
      case 'significant':
        return AppColors.warning;
      default:
        return AppColors.textOnDarkMuted;
    }
  }
}

const List<IslamicEvent> _allEvents = [
  IslamicEvent(month: 1, day: 1, name: 'رأس السنة الهجرية', type: 'holiday', icon: Icons.celebration_outlined),
  IslamicEvent(month: 1, day: 2, name: 'بداية العام الهجري الجديد', type: 'significant', icon: Icons.today_outlined),
  IslamicEvent(month: 1, day: 10, name: 'يوم عاشوراء', type: 'religious', icon: Icons.water_drop_outlined),
  IslamicEvent(month: 3, day: 12, name: 'المولد النبوي الشريف', type: 'holiday', icon: Icons.favorite_outlined),
  IslamicEvent(month: 7, day: 27, name: 'الإسراء والمعراج', type: 'religious', icon: Icons.flight_outlined),
  IslamicEvent(month: 8, day: 15, name: 'ليلة النصف من شعبان', type: 'religious', icon: Icons.nights_stay_outlined),
  IslamicEvent(month: 9, day: 1, name: 'بداية شهر رمضان المبارك', type: 'religious', icon: Icons.star_outlined),
  IslamicEvent(month: 9, day: 10, name: 'وفاة السيدة خديجة رضي الله عنها', type: 'significant', icon: Icons.volunteer_activism_outlined),
  IslamicEvent(month: 9, day: 17, name: 'غزوة بدر الكبرى', type: 'significant', icon: Icons.shield_outlined),
  IslamicEvent(month: 9, day: 21, name: 'فتح مكة', type: 'significant', icon: Icons.location_city_outlined),
  IslamicEvent(month: 9, day: 27, name: 'ليلة القدر', type: 'religious', icon: Icons.auto_awesome_outlined),
  IslamicEvent(month: 9, day: 30, name: 'الاعتكاف', type: 'religious', icon: Icons.mosque_outlined),
  IslamicEvent(month: 10, day: 1, name: 'عيد الفطر المبارك', type: 'holiday', icon: Icons.celebration_outlined),
  IslamicEvent(month: 10, day: 2, name: 'ثاني أيام عيد الفطر', type: 'holiday', icon: Icons.celebration_outlined),
  IslamicEvent(month: 10, day: 3, name: 'ثالث أيام عيد الفطر', type: 'holiday', icon: Icons.celebration_outlined),
  IslamicEvent(month: 12, day: 9, name: 'يوم عرفة', type: 'religious', icon: Icons.location_on_outlined),
  IslamicEvent(month: 12, day: 10, name: 'عيد الأضحى المبارك', type: 'holiday', icon: Icons.celebration_outlined),
  IslamicEvent(month: 12, day: 11, name: 'أيام التشريق', type: 'religious', icon: Icons.wb_sunny_outlined),
  IslamicEvent(month: 12, day: 12, name: 'أيام التشريق', type: 'religious', icon: Icons.wb_sunny_outlined),
  IslamicEvent(month: 12, day: 13, name: 'أيام التشريق', type: 'religious', icon: Icons.wb_sunny_outlined),
  IslamicEvent(month: 12, day: 18, name: 'عيد الغدير', type: 'religious', icon: Icons.handshake_outlined),
];

final List<String> _weekdayNames = [
  'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
];

String _arabicMonthName(int month) {
  const names = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];
  return names[month - 1];
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;
  late HijriCalendar _todayHijri;
  int _currentPage = 0;
  int? _selectedDay;

  int _refYear = 0;
  int _refMonth = 0;

  @override
  void initState() {
    super.initState();
    recordActivity(
      id: 'calendar',
      title: 'التقويم',
      subtitle: 'التقويم الهجري والميلادي',
      route: '/calendar',
      icon: '📅',
    );
    HijriCalendar.setLocal('ar');
    _todayHijri = HijriCalendar.now();
    _refYear = _todayHijri.hYear;
    _refMonth = _todayHijri.hMonth;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  (int, int) _getYearMonth(int page) {
    int totalMonths = (_refYear - 1) * 12 + (_refMonth - 1) + page;
    int year = totalMonths ~/ 12 + 1;
    int month = totalMonths % 12 + 1;
    return (year, month);
  }

  int _getDaysInMonth(int year, int month) {
    final c = HijriCalendar();
    return c.getDaysInMonth(year, month);
  }

  int _getFirstDayWeekday(int year, int month) {
    final date = HijriCalendar().hijriToGregorian(year, month, 1);
    return date.weekday % 7;
  }

  bool get _isCurrentMonth {
    final (y, m) = _getYearMonth(_currentPage);
    return y == _todayHijri.hYear && m == _todayHijri.hMonth;
  }

  bool _isToday(int year, int month, int day) {
    return year == _todayHijri.hYear && month == _todayHijri.hMonth && day == _todayHijri.hDay;
  }

  List<IslamicEvent> _eventsForMonth(int year, int month) {
    return _allEvents.where((e) => e.month == month).toList();
  }

  List<IslamicEvent> _eventsForDay(int year, int month, int day) {
    return _allEvents.where((e) => e.month == month && e.day == day).toList();
  }

  void _goToMonth(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToToday() {
    setState(() {
      _currentPage = 0;
      _selectedDay = null;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final (year, month) = _getYearMonth(_currentPage);
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth - AppDimensions.lg * 2 - AppDimensions.sm * 6) / 7;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('التقويم الهجري'),
        backgroundColor: AppColors.navy,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!_isCurrentMonth)
            TextButton.icon(
              onPressed: _goToToday,
              icon: const Icon(Icons.today, color: AppColors.gold, size: 20),
              label: const Text(
                'اليوم',
                style: TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Amiri',
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildHeader(year, month),
              _buildWeekdayRow(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, page) {
                    final (y, m) = _getYearMonth(page);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                      child: Column(
                        children: [
                          _buildMonthGrid(y, m, cellSize),
                          const SizedBox(height: AppDimensions.md),
                          _buildEventsSection(y, m),
                          const SizedBox(height: AppDimensions.xl),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int year, int month) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, AppDimensions.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _goToMonth(_currentPage - 1),
            icon: const Icon(Icons.chevron_right, color: AppColors.gold, size: 28),
            tooltip: 'الشهر السابق',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_arabicMonthName(month)} $year',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  _gregorianDateString(year, month),
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontFamily: 'Amiri',
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _goToMonth(_currentPage + 1),
            icon: const Icon(Icons.chevron_left, color: AppColors.gold, size: 28),
            tooltip: 'الشهر التالي',
          ),
        ],
      ),
    );
  }

  String _gregorianDateString(int year, int month) {
    try {
      final c = HijriCalendar();
      final firstGreg = c.hijriToGregorian(year, month, 1);
      final lastGreg = c.hijriToGregorian(year, month, _getDaysInMonth(year, month));
      const miladiMonths = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
      ];
      if (firstGreg.month == lastGreg.month) {
        return '${firstGreg.day} - ${lastGreg.day} ${miladiMonths[firstGreg.month - 1]} ${firstGreg.year}م';
      } else {
        return '${firstGreg.day} ${miladiMonths[firstGreg.month - 1]} - ${lastGreg.day} ${miladiMonths[lastGreg.month - 1]} ${firstGreg.year}م';
      }
    } catch (_) {
      return '';
    }
  }

  Widget _buildWeekdayRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: List.generate(7, (i) {
          return Expanded(
            child: Text(
              _weekdayNames[i],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontFamily: 'Amiri',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthGrid(int year, int month, double cellSize) {
    final daysInMonth = _getDaysInMonth(year, month);
    final firstWeekday = _getFirstDayWeekday(year, month);
    final eventsForMonth = _eventsForMonth(year, month);
    final eventDays = eventsForMonth.map((e) => e.day).toSet();

    final rows = <Widget>[];
    final totalCells = firstWeekday + daysInMonth;
    final numRows = (totalCells / 7).ceil();

    for (int row = 0; row < numRows; row++) {
      final rowCells = <Widget>[];
      for (int col = 0; col < 7; col++) {
        final cellIndex = row * 7 + col;
        final day = cellIndex - firstWeekday + 1;

        if (day < 1 || day > daysInMonth) {
          rowCells.add(SizedBox(width: cellSize, height: cellSize + 10));
        } else {
          rowCells.add(_buildDayCell(year, month, day, cellSize, eventDays.contains(day)));
        }
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.xs),
          child: Row(
            children: rowCells,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildDayCell(int year, int month, int day, double cellSize, bool hasEvents) {
    final isToday = _isToday(year, month, day);
    final isSelected = _selectedDay == day;
    final dayEvents = _eventsForDay(year, month, day);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = _selectedDay == day ? null : day;
        });
      },
      child: Container(
        width: cellSize,
        height: cellSize + 10,
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.gold
              : isSelected
                  ? AppColors.goldMuted
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: isSelected
              ? Border.all(color: AppColors.gold, width: 1.5)
              : isToday
                  ? Border.all(color: AppColors.goldLight, width: 1)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                color: isToday
                    ? AppColors.navy
                    : AppColors.textOnDark,
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (hasEvents)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayEvents.length > 3
                      ? [
                          _eventDot(AppColors.gold),
                          _eventDot(AppColors.success),
                          _eventDot(AppColors.warning),
                        ]
                      : dayEvents.take(3).map((e) => _eventDot(e.color)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _eventDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildEventsSection(int year, int month) {
    final events = _selectedDay != null
        ? _eventsForDay(year, month, _selectedDay!)
        : _eventsForMonth(year, month);

    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Text(
          _selectedDay != null
              ? 'لا توجد مناسبات في هذا اليوم'
              : 'لا توجد مناسبات في هذا الشهر',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textOnDarkMuted,
            fontFamily: 'Amiri',
            fontSize: 16,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event, color: AppColors.gold, size: 20),
            const SizedBox(width: AppDimensions.sm),
            Text(
              _selectedDay != null
                    ? 'مناسبات يوم $_selectedDay'
                  : 'المناسبات الإسلامية',
              style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_selectedDay != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDay = null),
                child: const Padding(
                  padding: EdgeInsets.only(right: AppDimensions.md),
                  child: Icon(Icons.close, color: AppColors.textOnDarkMuted, size: 18),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        ...events.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(IslamicEvent event) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border(
          left: BorderSide(color: event.color, width: 3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(event.icon, color: event.color, size: 18),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontFamily: 'Amiri',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${event.day} ${_arabicMonthName(event.month)}',
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontFamily: 'Amiri',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: AppDimensions.xs),
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Text(
              event.type == 'holiday'
                  ? 'إجازة'
                  : event.type == 'religious'
                      ? 'ديني'
                      : 'مناسبة',
              style: TextStyle(
                color: event.color,
                fontFamily: 'Amiri',
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
