import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/notification_service.dart';

class _DhikrPhrase {
  final String title;
  final String body;
  const _DhikrPhrase(this.title, this.body);
}

const _dhikrPhrases = [
  _DhikrPhrase('ﷺ', 'اللهم صلِّ على محمد وعلى آل محمد كما صليت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد'),
  _DhikrPhrase('ﷺ', 'اللهم صلِّ وسلم على نبينا محمد ﷺ'),
  _DhikrPhrase('سبحان الله', 'سبحان الله وبحمده سبحان الله العظيم'),
  _DhikrPhrase('الحمد لله', 'الحمد لله رب العالمين الرحمن الرحيم مالك يوم الدين'),
  _DhikrPhrase('لا إله إلا الله', 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير'),
  _DhikrPhrase('الله أكبر', 'الله أكبر كبيراً والحمد لله كثيراً وسبحان الله بكرة وأصيلاً'),
  _DhikrPhrase('أستغفر الله', 'أستغفر الله الذي لا إله إلا هو الحي القيوم وأتوب إليه'),
  _DhikrPhrase('ﷺ', 'من صلى عليَّ صلاةً صلى الله عليه بها عشراً'),
  _DhikrPhrase('سبحان الله', 'سبحان الله عدد ما خلق، سبحان الله ملء ما خلق'),
  _DhikrPhrase('الحمد لله', 'الحمد لله على كل حال، الحمد لله الذي بنعمته تتم الصالحات'),
  _DhikrPhrase('لا إله إلا الله', 'لا إله إلا الله عدد ما كان وعدد ما سيكون'),
  _DhikrPhrase('ﷺ', 'اللهم صل على سيدنا محمد الفاتح لما أغلق والخاتم لما سبق'),
  _DhikrPhrase('أستغفر الله', 'رب اغفر لي وتب عليَّ إنك أنت التواب الرحيم'),
];

class DhikrRemindersScreen extends ConsumerStatefulWidget {
  const DhikrRemindersScreen({super.key});

  @override
  ConsumerState<DhikrRemindersScreen> createState() => _DhikrRemindersScreenState();
}

class _DhikrRemindersScreenState extends ConsumerState<DhikrRemindersScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _counter = 0;
  bool _notificationsEnabled = true;
  int _intervalMinutes = 15;
  Timer? _rotationTimer;
  Timer? _notificationTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
    _loadSettings();
    _startRotation();
    _startNotificationTimer();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _notificationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('dhikr_notifications') ?? true;
      _intervalMinutes = prefs.getInt('dhikr_interval') ?? 15;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dhikr_notifications', _notificationsEnabled);
    await prefs.setInt('dhikr_interval', _intervalMinutes);
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      _animController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = (_currentIndex + 1) % _dhikrPhrases.length;
        });
        _animController.forward();
      });
    });
  }

  void _startNotificationTimer() {
    _notificationTimer?.cancel();
    if (!_notificationsEnabled) return;
    _notificationTimer = Timer.periodic(
      Duration(minutes: _intervalMinutes),
      (_) => _showDhikrNotification(),
    );
  }

  Future<void> _showDhikrNotification() async {
    final msg = _dhikrPhrases[_currentIndex];
    await NotificationService().showNotification(
      id: 50,
      title: msg.title,
      body: msg.body,
    );
  }

  void _nextPhrase() {
    _animController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _dhikrPhrases.length;
      });
      _animController.forward();
    });
  }

  void _prevPhrase() {
    _animController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex - 1 + _dhikrPhrases.length) % _dhikrPhrases.length;
      });
      _animController.forward();
    });
  }

  void _incrementCounter() {
    setState(() => _counter++);
  }

  void _resetCounter() {
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _dhikrPhrases[_currentIndex];
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('اذكر الله وصلِّ على النبي'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _incrementCounter,
                onLongPress: _resetCounter,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.goldMuted,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              phrase.title,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontFamily: 'Amiri',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.lg),
                          Text(
                            phrase.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textOnDark,
                              fontFamily: 'Amiri',
                              fontSize: 24,
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          GestureDetector(
                            onTap: _incrementCounter,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.goldMuted,
                                border: Border.all(color: AppColors.gold, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '$_counter',
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontFamily: 'Inter',
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          const Text(
                            'اضغط للعد',
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
                ),
              ),
            ),
            _buildControls(),
            _buildSettings(),
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.gold, size: 32),
            onPressed: _prevPhrase,
          ),
          const SizedBox(width: AppDimensions.md),
          Text(
            '${_currentIndex + 1} / ${_dhikrPhrases.length}',
            style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 14),
          ),
          const SizedBox(width: AppDimensions.md),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.gold, size: 32),
            onPressed: _nextPhrase,
          ),
          const SizedBox(width: AppDimensions.lg),
          TextButton.icon(
            onPressed: _resetCounter,
            icon: const Icon(Icons.refresh, color: AppColors.goldMuted, size: 18),
            label: const Text('تصفير', style: TextStyle(color: AppColors.goldMuted, fontFamily: 'Amiri', fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
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
              const Icon(Icons.notifications_outlined, color: AppColors.gold, size: 20),
              const SizedBox(width: AppDimensions.sm),
              const Text('التذكير الدوري', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 15)),
              const Spacer(),
              Switch(
                value: _notificationsEnabled,
                activeColor: AppColors.gold,
                onChanged: (v) {
                  setState(() => _notificationsEnabled = v);
                  _saveSettings();
                  if (v) {
                    _startNotificationTimer();
                  } else {
                    _notificationTimer?.cancel();
                  }
                },
              ),
            ],
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: AppDimensions.xs),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.goldMuted, size: 16),
                const SizedBox(width: AppDimensions.sm),
                const Text('كل', style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 13)),
                const SizedBox(width: AppDimensions.sm),
                DropdownButton<int>(
                  value: _intervalMinutes,
                  dropdownColor: AppColors.navyLight,
                  style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 14),
                  underline: Container(height: 1, color: AppColors.goldMuted),
                  items: const [
                    DropdownMenuItem(value: 5, child: Text('5 دقائق')),
                    DropdownMenuItem(value: 10, child: Text('10 دقائق')),
                    DropdownMenuItem(value: 15, child: Text('15 دقيقة')),
                    DropdownMenuItem(value: 30, child: Text('30 دقيقة')),
                    DropdownMenuItem(value: 60, child: Text('60 دقيقة')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _intervalMinutes = v);
                    _saveSettings();
                    _startNotificationTimer();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
