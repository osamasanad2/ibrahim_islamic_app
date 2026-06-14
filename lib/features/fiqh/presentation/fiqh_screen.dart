import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class FiqhScreen extends StatefulWidget {
  const FiqhScreen({super.key});

  @override
  State<FiqhScreen> createState() => _FiqhScreenState();
}

class _FiqhScreenState extends State<FiqhScreen> {
  List<Map<String, dynamic>> _chapters = [];
  bool _loading = true;
  int? _expandedChapter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final str = await rootBundle.loadString('assets/fiqh/fiqh_ibadat.json');
    final data = json.decode(str) as List;
    setState(() {
      _chapters = data.cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('فقه العبادات'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.lg),
              itemCount: _chapters.length,
              itemBuilder: (context, i) {
                final chapter = _chapters[i];
                final isExpanded = _expandedChapter == i;
                final sections = (chapter['sections'] as List).cast<Map<String, dynamic>>();
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.navyLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: isExpanded ? AppColors.gold : AppColors.goldMuted,
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _expandedChapter = isExpanded ? null : i),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.lg),
                          child: Row(
                            children: [
                              Text(chapter['icon'] as String? ?? '📖', style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: AppDimensions.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(chapter['title'] as String,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontFamily: 'Amiri',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (chapter['description'] != null && (chapter['description'] as String).isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(chapter['description'] as String,
                                        style: const TextStyle(
                                          color: AppColors.textOnDarkMuted,
                                          fontFamily: 'Amiri',
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Badge(
                                label: Text('${sections.length}', style: const TextStyle(fontSize: 11, color: AppColors.navy)),
                                backgroundColor: AppColors.gold,
                                textColor: AppColors.navy,
                              ),
                              const SizedBox(width: AppDimensions.sm),
                              Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: _buildChapterContent(sections),
                        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChapterContent(List<Map<String, dynamic>> sections) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, 0, AppDimensions.lg, AppDimensions.lg),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.sm),
      itemBuilder: (context, i) {
        final section = sections[i];
        return _SectionContent(
          title: section['title'] as String,
          content: section['content'] as String,
        );
      },
    );
  }
}

class _SectionContent extends StatelessWidget {
  final String title;
  final String content;
  const _SectionContent({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(content,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.textOnDarkMuted,
              fontFamily: 'Amiri',
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
