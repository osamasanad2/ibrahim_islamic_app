import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/recent_activity_service.dart';

enum UserMood { anxious, grateful, sad, happy, fearful, sick, tired, hopeful }

class Dua {
  final int id;
  final String arabic;
  final String translation;
  final String reference;
  final String category;
  final List<String> tags;

  const Dua({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.reference,
    required this.category,
    required this.tags,
  });

  factory Dua.fromJson(Map<String, dynamic> json) => Dua(
        id: json['id'] as int,
        arabic: json['arabic'] as String,
        translation: json['translation'] as String,
        reference: json['reference'] as String,
        category: json['category'] as String,
        tags: (json['tags'] as List).cast<String>(),
      );
}

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> with TickerProviderStateMixin {
  List<Dua> _allDuas = [];
  List<Dua> _filtered = [];
  List<String> _categories = [];
  String _selectedCategory = 'الكل';
  UserMood? _selectedMood;
  bool _loading = true;
  late TabController _tabController;

  final Map<UserMood, Map<String, dynamic>> _moodData = {
    UserMood.anxious:  {'emoji': '😰', 'label': 'قلق', 'tags': ['anxiety', 'worry', 'stress']},
    UserMood.grateful: {'emoji': '🙏', 'label': 'شاكر', 'tags': ['gratitude', 'shukr', 'praise']},
    UserMood.sad:      {'emoji': '😢', 'label': 'حزين', 'tags': ['sadness', 'grief', 'loss']},
    UserMood.happy:    {'emoji': '😊', 'label': 'سعيد', 'tags': ['grateful', 'happy', 'praise']},
    UserMood.fearful:  {'emoji': '😨', 'label': 'خائف', 'tags': ['fearful', 'anxiety', 'ruqyah']},
    UserMood.sick:     {'emoji': '🤒', 'label': 'مريض', 'tags': ['sick', 'illness', 'healing', 'ruqyah']},
    UserMood.tired:    {'emoji': '😴', 'label': 'متعب', 'tags': ['tired', 'anxiety', 'stress']},
    UserMood.hopeful:  {'emoji': '⭐', 'label': 'متفائل', 'tags': ['hopeful', 'general', 'gratitude']},
  };

  @override
  void initState() {
    super.initState();
    recordActivity(id: 'dua', title: 'الأدعية والأذكار', subtitle: 'من القرآن والسنة', route: '/dua', icon: '🤲');
    _loadDuas();
  }

  Future<void> _loadDuas() async {
    final str = await rootBundle.loadString('assets/dua/duas.json');
    final data = json.decode(str) as Map<String, dynamic>;
    final rawCategories = (data['categories'] as List).cast<String>();
    final duas = (data['duas'] as List)
        .map((e) => Dua.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _allDuas = duas;
      _categories = ['الكل', ...rawCategories];
      _filtered = duas;
      _loading = false;
      _tabController = TabController(length: _categories.length, vsync: this);
      _tabController.addListener(_onTabChanged);
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
        _applyFilters();
      });
    }
  }

  void _selectCategory(String category) {
    final index = _categories.indexOf(category);
    if (index >= 0) {
      _tabController.animateTo(index);
    }
  }

  void _selectMood(UserMood? mood) {
    setState(() {
      _selectedMood = _selectedMood == mood ? null : mood;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Dua> result = _allDuas;

    if (_selectedCategory != 'الكل') {
      result = result.where((d) => d.category == _selectedCategory).toList();
    }

    if (_selectedMood != null) {
      final tags = (_moodData[_selectedMood]!['tags'] as List).cast<String>();
      result = result.where((d) => d.tags.any(tags.contains)).toList();
    }

    _filtered = result;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('الأدعية'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _buildCategoryTabs(),
                  _buildMoodChips(),
                  if (_selectedMood != null || _selectedCategory != 'الكل')
                    _buildFilterInfo(),
                  Expanded(child: _buildDuaList()),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.gold,
        indicatorWeight: 3,
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.textOnDarkMuted,
        labelStyle: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 14,
        ),
        tabAlignment: TabAlignment.start,
        tabs: _categories.map((cat) => Tab(text: cat)).toList(),
      ),
    );
  }

  Widget _buildMoodChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _moodData.entries.map((e) {
            final selected = _selectedMood == e.key;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => _selectMood(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.gold : AppColors.navyLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? AppColors.gold : AppColors.goldMuted),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value['emoji'] as String,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        e.value['label'] as String,
                        style: TextStyle(
                          color: selected
                              ? AppColors.navy
                              : AppColors.textOnDark,
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            '${_filtered.length} دعاء',
            style: const TextStyle(
              color: AppColors.goldLight,
              fontFamily: 'Inter',
              fontSize: 12,
            ),
          ),
          const Spacer(),
          if (_selectedCategory != 'الكل')
            GestureDetector(
              onTap: () => _selectCategory('الكل'),
              child: const Text(
                'إظهار الكل',
                style: TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Amiri',
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDuaList() {
    if (_filtered.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أدعية في هذه الفئة',
          style: TextStyle(
            color: AppColors.textOnDarkMuted,
            fontFamily: 'Amiri',
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      itemBuilder: (context, index) => _DuaCard(dua: _filtered[index]),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final Dua dua;
  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dua.arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 19,
              height: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dua.translation,
            style: const TextStyle(
              color: AppColors.textOnDarkMuted,
              fontFamily: 'Inter',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dua.reference,
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontFamily: 'Amiri',
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dua.category,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontFamily: 'Amiri',
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
