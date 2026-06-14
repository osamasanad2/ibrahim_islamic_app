import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/recent_activity_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../books/data/book_model.dart';

class SeerahScreen extends StatefulWidget {
  const SeerahScreen({super.key});

  @override
  State<SeerahScreen> createState() => _SeerahScreenState();
}

class _SeerahScreenState extends State<SeerahScreen> {
  final BookRepository _repo = BookRepository();
  final LocalStorage _storage = LocalStorage();
  List<Map<String, dynamic>> _seerahBooks = [];
  BookContent? _rahiqueqContent;
  bool _loading = true;
  Set<int> _expandedChapters = {};
  bool _showAllBooks = false;

  static const _seerahCategories = ['السيرة والشمائل', 'السيرة والتاريخ'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final meta = await _repo.loadBooksMeta();
      final contents = await _repo.loadAllContent();

      final seerahBooks = meta.where((b) {
        final cat = b['category'] as String? ?? '';
        return _seerahCategories.any((c) => cat.contains(c));
      }).toList();

      BookContent? rahiq;
      if (contents.containsKey(10)) {
        rahiq = contents[10];
      }

      if (mounted) {
        setState(() {
          _seerahBooks = seerahBooks;
          _rahiqueqContent = rahiq;
          _loading = false;
          if (rahiq != null) {
            final saved = _storage.getBookProgress(10);
            _expandedChapters = saved;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleChapter(int index) {
    setState(() {
      if (_expandedChapters.contains(index)) {
        _expandedChapters.remove(index);
      } else {
        _expandedChapters.add(index);
      }
    });
    _storage.saveBookProgress(10, _expandedChapters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildRahiqHeader()),
                if (_rahiqueqContent != null)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final chapter = _rahiqueqContent!.chapters[index];
                        final expanded = _expandedChapters.contains(index);
                        return _ChapterCard(
                          chapter: chapter,
                          index: index + 1,
                          expanded: expanded,
                          read: _expandedChapters.contains(index),
                          onTap: () => _toggleChapter(index),
                        );
                      },
                      childCount: _rahiqueqContent!.chapters.length,
                    ),
                  ),
                if (_rahiqueqContent != null)
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.md)),
                SliverToBoxAdapter(child: _buildOtherSources()),
                if (_showAllBooks)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = _seerahBooks[index];
                        return _SeerahBookCard(
                          book: book,
                          onTap: () {
                            recordActivity(
                              id: 'book-${book['id']}',
                              title: book['title'] as String? ?? 'كتاب',
                              subtitle: book['author'] as String? ?? '',
                              route: '/book-reader/${book['id']}',
                              icon: '📚',
                            );
                            context.push('/book-reader/${book['id']}');
                          },
                        );
                      },
                      childCount: _seerahBooks.length,
                    ),
                  ),
                if (_showAllBooks)
                  const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.md)),
                const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xxl)),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.sm, AppDimensions.lg, AppDimensions.sm),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(Icons.timeline, color: Color(0xFF2196F3), size: 24),
          ),
          const SizedBox(width: AppDimensions.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('السيرة النبوية',
                style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 22, fontWeight: FontWeight.w700)),
              Text('سيرة خير البشر محمد صلى الله عليه وسلم',
                style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRahiqHeader() {
    if (_rahiqueqContent == null) return const SizedBox.shrink();

    final readCount = _expandedChapters.length;
    final totalChapters = _rahiqueqContent!.chapters.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2C4E), Color(0xFF0F1C3A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: const Icon(Icons.menu_book, color: Color(0xFF2196F3), size: 32),
          ),
          const SizedBox(height: AppDimensions.sm),
          const Text('الرحيق المختوم',
            style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('الشيخ صفي الرحمن المباركفوري',
            style: TextStyle(color: AppColors.goldMuted, fontFamily: 'Inter', fontSize: 12)),
          const SizedBox(height: AppDimensions.sm),
          if (totalChapters > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text('$readCount من $totalChapters فصول',
                  style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Amiri', fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalChapters > 0 ? readCount / totalChapters : 0,
                  backgroundColor: AppColors.navy,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherSources() {
    final others = _seerahBooks.where((b) => b['id'] != 10).toList();
    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.lg, AppDimensions.lg, AppDimensions.sm),
          child: Row(
            children: [
              const Text('مصادر أخرى',
                style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showAllBooks = !_showAllBooks),
                child: Text(
                  _showAllBooks ? 'إخفاء' : 'عرض الكل',
                  style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Inter', fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        if (!_showAllBooks)
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              itemCount: others.length,
              itemBuilder: (context, index) {
                final book = others[index];
                return _MiniBookCard(
                  book: book,
                  onTap: () {
                    recordActivity(
                      id: 'book-${book['id']}',
                      title: book['title'] as String? ?? 'كتاب',
                      subtitle: book['author'] as String? ?? '',
                      route: '/book-reader/${book['id']}',
                      icon: '📚',
                    );
                    context.push('/book-reader/${book['id']}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final BookChapter chapter;
  final int index;
  final bool expanded;
  final bool read;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.index, required this.expanded, required this.read, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sectionCount = chapter.sections.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: expanded ? AppColors.gold : AppColors.goldMuted),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: read ? AppColors.success.withValues(alpha: 0.2) : AppColors.goldMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: read
                          ? const Icon(Icons.check, color: AppColors.success, size: 18)
                          : Text('$index',
                              style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Text(chapter.title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: expanded ? AppColors.gold : AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Text('$sectionCount مباحث',
                    style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 10)),
                  const SizedBox(width: 8),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.goldMuted, size: 20),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(color: AppColors.goldMuted, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: chapter.sections.map((section) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section.title != null && section.title!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                            child: Text(section.title!,
                              style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Amiri', fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        Text(section.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 15, height: 2.0)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;

  const _MiniBookCard({required this.book, required this.onTap});

  IconData _icon(String cat) {
    if (cat.contains('تفسير')) return Icons.menu_book;
    if (cat.contains('حديث')) return Icons.chat;
    if (cat.contains('سيرة') || cat.contains('تاريخ')) return Icons.timeline;
    return Icons.library_books;
  }

  Color _color(String cat) {
    if (cat.contains('تفسير')) return const Color(0xFF4CAF50);
    if (cat.contains('حديث')) return const Color(0xFFFF9800);
    if (cat.contains('سيرة') || cat.contains('تاريخ')) return const Color(0xFF2196F3);
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    final cat = book['category'] as String? ?? '';
    final color = _color(cat);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(left: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Icon(_icon(cat), color: color, size: 20),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(book['title'] as String? ?? '',
              style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(book['author'] as String? ?? '',
              style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Inter', fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SeerahBookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;

  const _SeerahBookCard({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: 4),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.goldMuted),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: const Icon(Icons.menu_book, color: Color(0xFF2196F3), size: 24),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book['title'] as String? ?? '',
                    style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(book['author'] as String? ?? '',
                    style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Inter', fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.goldMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
