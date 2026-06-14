import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/storage/local_storage.dart';

class _Challenge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int target;
  final String unit;
  const _Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.unit,
  });
}

class _Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  const _Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class _FriendEntry {
  final String name;
  final String avatarLetter;
  final int pages;
  final int streak;
  final int khatmas;
  final bool isUser;
  const _FriendEntry({
    required this.name,
    required this.avatarLetter,
    required this.pages,
    required this.streak,
    required this.khatmas,
    this.isUser = false,
  });
}

const _challenges = [
  _Challenge(
    id: 'khatma_30',
    title: 'ختمة القرآن في 30 يوم',
    description: 'اختِتام قراءة القرآن الكريم كاملاً خلال 30 يوماً بمعدل 20 صفحة يومياً',
    icon: Icons.menu_book,
    target: 604,
    unit: 'صفحة',
  ),
  _Challenge(
    id: 'kahf',
    title: 'قراءة سورة الكهف كل جمعة',
    description: 'قراءة سورة الكهف يوم الجمعة اقتداءً بسنة النبي ﷺ',
    icon: Icons.book,
    target: 52,
    unit: 'جمعة',
  ),
  _Challenge(
    id: 'hadith_40',
    title: '40 حديثاً نبويّاً',
    description: 'حفظ أربعين حديثاً من أحاديث النبي صلى الله عليه وسلم في مختلف أبواب الدين',
    icon: Icons.chat_bubble_outline,
    target: 40,
    unit: 'حديث',
  ),
  _Challenge(
    id: 'ward_daily',
    title: 'ورد يومي من القرآن',
    description: 'المواظبة على ورد يومي من القرآن الكريم لا يقل عن صفحة واحدة',
    icon: Icons.auto_stories,
    target: 30,
    unit: 'يوم',
  ),
  _Challenge(
    id: 'white_days',
    title: 'صيام الأيام البيض',
    description: 'صيام الثالث عشر والرابع عشر والخامس عشر من كل شهر هجري',
    icon: Icons.wb_sunny_outlined,
    target: 12,
    unit: 'شهر',
  ),
];

const _achievements = [
  _Achievement(
    id: 'khatma',
    title: 'الختمة الأولى',
    description: 'أكمل ختمة قرآن كامل',
    emoji: '🏆',
  ),
  _Achievement(
    id: 'muthabir',
    title: 'المثابر',
    description: '7 أيام متتالية من القراءة',
    emoji: '🔥',
  ),
  _Achievement(
    id: 'abid',
    title: 'العابد',
    description: '30 يوماً متتالياً من القراءة',
    emoji: '🌙',
  ),
  _Achievement(
    id: 'hafidh',
    title: 'الحافظ',
    description: 'حفظ سورة كاملة من القرآن',
    emoji: '📖',
  ),
  _Achievement(
    id: 'qari',
    title: 'القارئ',
    description: 'قراءة 100 صفحة من القرآن',
    emoji: '📚',
  ),
  _Achievement(
    id: 'saim',
    title: 'الصائم',
    description: 'صيام الأيام البيض كاملة',
    emoji: '🤲',
  ),
  _Achievement(
    id: 'dhakir',
    title: 'الذاكر',
    description: 'إتمام 1000 ذكر',
    emoji: '📿',
  ),
];

const _mockFriends = [
  _FriendEntry(name: 'إبراهيم', avatarLetter: 'إ', pages: 520, streak: 30, khatmas: 5),
  _FriendEntry(name: 'ياسين', avatarLetter: 'ي', pages: 450, streak: 25, khatmas: 4),
  _FriendEntry(name: 'أسامة', avatarLetter: 'أ', pages: 312, streak: 18, khatmas: 3),
  _FriendEntry(name: 'مريم', avatarLetter: 'م', pages: 267, streak: 9, khatmas: 2),
  _FriendEntry(name: 'نور', avatarLetter: 'ن', pages: 189, streak: 12, khatmas: 1),
];

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocalStorage _storage = LocalStorage();
  final Set<String> _joinedChallenges = {};
  final Set<String> _unlockedAchievements = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    for (final c in _challenges) {
      final raw = _storage.getString('challenge_${c.id}');
      if (raw.isNotEmpty) {
        try {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          if (data['joined'] == true) _joinedChallenges.add(c.id);
        } catch (_) {}
      }
    }
    for (final a in _achievements) {
      if (_storage.getBool('achievement_${a.id}', defaultValue: false)) {
        _unlockedAchievements.add(a.id);
      }
    }
    setState(() => _loaded = true);
  }

  int _getStreak() {
    final raw = _storage.getString('streak_days');
    return int.tryParse(raw) ?? 0;
  }

  double _challengeProgress(_Challenge c) {
    if (!_joinedChallenges.contains(c.id)) return 0.0;
    if (c.id == 'khatma_30') {
      return (_storage.getQuranPage() / c.target).clamp(0.0, 1.0);
    }
    if (c.id == 'ward_daily') {
      return (_getStreak() / c.target).clamp(0.0, 1.0);
    }
    final raw = _storage.getString('challenge_${c.id}');
    if (raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final progress = (data['progress'] as num?)?.toDouble() ?? 0.0;
        return (progress / c.target).clamp(0.0, 1.0);
      } catch (_) {}
    }
    return 0.0;
  }

  int _challengeValue(_Challenge c) {
    if (!_joinedChallenges.contains(c.id)) return 0;
    if (c.id == 'khatma_30') return _storage.getQuranPage().clamp(0, c.target);
    if (c.id == 'ward_daily') return _getStreak().clamp(0, c.target);
    final raw = _storage.getString('challenge_${c.id}');
    if (raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        return (data['progress'] as num?)?.toInt() ?? 0;
      } catch (_) {}
    }
    return 0;
  }

  double _achievementProgress(_Achievement a) {
    final pages = _storage.getQuranPage();
    final streak = _getStreak();
    switch (a.id) {
      case 'khatma':
        return (pages / 604).clamp(0.0, 1.0);
      case 'muthabir':
        return (streak / 7).clamp(0.0, 1.0);
      case 'abid':
        return (streak / 30).clamp(0.0, 1.0);
      case 'hafidh':
        return _unlockedAchievements.contains(a.id) ? 1.0 : 0.0;
      case 'qari':
        return (pages / 100).clamp(0.0, 1.0);
      case 'saim':
        return _unlockedAchievements.contains(a.id) ? 1.0 : 0.0;
      case 'dhakir':
        return _unlockedAchievements.contains(a.id) ? 1.0 : 0.0;
      default:
        return 0.0;
    }
  }

  int _achievementCurrent(_Achievement a) {
    final pages = _storage.getQuranPage();
    final streak = _getStreak();
    switch (a.id) {
      case 'khatma':
        return pages.clamp(0, 604);
      case 'muthabir':
        return streak.clamp(0, 7);
      case 'abid':
        return streak.clamp(0, 30);
      case 'qari':
        return pages.clamp(0, 100);
      default:
        return 0;
    }
  }

  int _achievementTarget(_Achievement a) {
    switch (a.id) {
      case 'khatma':
        return 604;
      case 'muthabir':
        return 7;
      case 'abid':
        return 30;
      case 'hafidh':
        return 1;
      case 'qari':
        return 100;
      case 'saim':
        return 1;
      case 'dhakir':
        return 1;
      default:
        return 1;
    }
  }

  void _joinChallenge(_Challenge c) {
    _joinedChallenges.add(c.id);
    _storage.saveString(
      'challenge_${c.id}',
      jsonEncode({'joined': true, 'progress': 0}),
    );
    setState(() {});
  }

  void _shareApp() {
    Share.share(
      'انضم إلي في تطبيق إبراهيم لقراءة القرآن والأذكار والصلاة! '
      'تطبيق إبراهيم - مرافقك الروحي اليومي',
      subject: 'تطبيق إبراهيم',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: AppColors.navy,
        appBar: AppBar(
          backgroundColor: AppColors.navy,
          elevation: 0,
          title: const Text(
            'التكامل الاجتماعي',
            style: TextStyle(fontFamily: 'Amiri'),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'التكامل الاجتماعي',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.navy,
              unselectedLabelColor: AppColors.textOnDarkMuted,
              labelStyle: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'التحديات'),
                Tab(text: 'الإنجازات'),
                Tab(text: 'الأصدقاء'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChallengesTab(),
          _buildAchievementsTab(),
          _buildFriendsTab(),
        ],
      ),
    );
  }

  // ── Challenges Tab ──

  Widget _buildChallengesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      itemCount: _challenges.length,
      itemBuilder: (context, i) => _buildChallengeCard(_challenges[i]),
    );
  }

  Widget _buildChallengeCard(_Challenge c) {
    final joined = _joinedChallenges.contains(c.id);
    final progress = _challengeProgress(c);
    final value = _challengeValue(c);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: joined ? AppColors.gold : AppColors.goldMuted,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.goldMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(c.icon, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.description,
                      style: const TextStyle(
                        color: AppColors.textOnDarkMuted,
                        fontFamily: 'Amiri',
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (joined) ...[
            const SizedBox(height: AppDimensions.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.navy,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$value / ${c.target} ${c.unit}',
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontFamily: 'Inter',
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.sm),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: joined ? null : () => _joinChallenge(c),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                decoration: BoxDecoration(
                  color: joined
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.gold,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Center(
                  child: Text(
                    joined ? 'مشترك ✓' : 'انضم',
                    style: TextStyle(
                      color: joined ? AppColors.gold : AppColors.navy,
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Achievements Tab ──

  Widget _buildAchievementsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppDimensions.md,
        mainAxisSpacing: AppDimensions.md,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, i) => _buildAchievementItem(_achievements[i]),
    );
  }

  Widget _buildAchievementItem(_Achievement a) {
    final unlocked = _unlockedAchievements.contains(a.id);
    final progress = _achievementProgress(a);
    final canUnlock = progress >= 1.0 && !unlocked;

    return GestureDetector(
      onTap: canUnlock
          ? () {
              _unlockedAchievements.add(a.id);
              _storage.saveBool('achievement_${a.id}', true);
              setState(() {});
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: unlocked
                ? AppColors.gold
                : progress > 0
                    ? AppColors.goldMuted
                    : AppColors.goldMuted.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              a.emoji,
              style: TextStyle(
                fontSize: 28,
                color: !unlocked && progress < 0.5
                    ? Colors.grey
                    : null,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              a.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: unlocked ? AppColors.gold : AppColors.textOnDarkMuted,
                fontFamily: 'Amiri',
                fontSize: 11,
                fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.xs),
            if (unlocked)
              const Icon(Icons.check_circle, color: AppColors.gold, size: 16)
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.navy,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.gold),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_achievementCurrent(a)}/${_achievementTarget(a)}',
                    style: const TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontFamily: 'Inter',
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Friends Tab ──

  Widget _buildFriendsTab() {
    final pages = _storage.getQuranPage();
    final streak = _getStreak();
    final khatmas = pages ~/ 604;

    final userEntry = _FriendEntry(
      name: 'أنت',
      avatarLetter: 'أ',
      pages: pages,
      streak: streak,
      khatmas: khatmas,
      isUser: true,
    );

    final all = [userEntry, ..._mockFriends];
    all.sort((a, b) => b.pages.compareTo(a.pages));

    int rank = 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.menu_book,
                  value: '$pages',
                  label: 'صفحة مقروءة',
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department,
                  value: '$streak',
                  label: 'أيام متتالية',
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  value: '$khatmas',
                  label: 'ختمة',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          const Divider(color: AppColors.goldMuted),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'لوحة المتصدرين',
                style: TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: _shareApp,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, color: AppColors.navy, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'دعوة الأصدقاء',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ...all.map((f) => _buildFriendRow(f, rank++)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gold, size: 20),
          const SizedBox(height: AppDimensions.xs),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textOnDarkMuted,
              fontFamily: 'Amiri',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRow(_FriendEntry f, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: f.isUser ? AppColors.goldMuted : AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: f.isUser ? AppColors.gold : AppColors.goldMuted.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: TextStyle(
                color: f.isUser ? AppColors.gold : AppColors.textOnDarkMuted,
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: f.isUser ? AppColors.gold : AppColors.navy,
            child: Text(
              f.avatarLetter,
              style: TextStyle(
                color: f.isUser ? AppColors.navy : AppColors.gold,
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              f.name,
              style: TextStyle(
                color: f.isUser ? AppColors.gold : AppColors.textOnDark,
                fontFamily: 'Amiri',
                fontSize: 14,
                fontWeight: f.isUser ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          _friendStat(f.pages.toString(), 'صفحات'),
          const SizedBox(width: AppDimensions.md),
          _friendStat(f.streak.toString(), 'أيام'),
          const SizedBox(width: AppDimensions.md),
          _friendStat(f.khatmas.toString(), 'ختـم'),
        ],
      ),
    );
  }

  Widget _friendStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gold,
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textOnDarkMuted,
            fontFamily: 'Amiri',
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
