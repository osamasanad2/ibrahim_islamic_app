import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class HadithModel {
  final int id;
  final int number;
  final String category;
  final String arabic;
  final String fullArabic;
  final String translation;
  final String narrator;
  final String source;

  const HadithModel({
    required this.id,
    required this.number,
    required this.category,
    required this.arabic,
    required this.fullArabic,
    required this.translation,
    required this.narrator,
    required this.source,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
        id: json['id'] as int,
        number: json['number'] as int,
        category: json['category'] as String? ?? '',
        arabic: json['arabic'] as String,
        fullArabic: json['full_arabic'] as String? ?? (json['arabic'] as String),
        translation: json['translation'] as String,
        narrator: json['narrator'] as String,
        source: json['source'] as String,
      );
}

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  List<HadithModel> _hadiths = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final str = await rootBundle.loadString('assets/hadith/hadith_40.json');
    final data = json.decode(str) as Map<String, dynamic>;
    setState(() {
      _hadiths = (data['hadiths'] as List)
          .map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('الأربعون النووية'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.lg),
              itemCount: _hadiths.length,
              itemBuilder: (context, i) => _HadithCard(hadith: _hadiths[i]),
            ),
    );
  }
}

class _HadithCard extends StatefulWidget {
  final HadithModel hadith;
  const _HadithCard({required this.hadith});

  @override
  State<_HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<_HadithCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.hadith;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  'الحديث ${h.number}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  h.source,
                  style: const TextStyle(
                    color: AppColors.goldMuted,
                    fontFamily: 'Inter',
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عَنْ ${h.narrator} قَالَ:',
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  '«${h.fullArabic.replaceAll('"', '').replaceAll('"', '')}»',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 2.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          if (_expanded) ...[
            const Divider(color: AppColors.goldMuted),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'الشرح: ${h.translation}',
              style: const TextStyle(
                color: AppColors.textOnDarkMuted,
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
          ],
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.goldMuted),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'إخفاء الشرح' : 'عرض الشرح',
                      style: const TextStyle(
                        color: AppColors.goldMuted,
                        fontFamily: 'Amiri',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.goldMuted, size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
