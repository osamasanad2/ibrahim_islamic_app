import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../data/quran/quran_providers.dart';
import '../../../../data/quran/ayah_model.dart';
import '../../../../data/quran/tafsir_edition.dart';
import '../../../data/quran/surah_meta.dart';
import 'widgets/ayah_audio_player.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final SurahMeta surah;
  final int? initialAyah;
  const SurahReaderScreen({super.key, required this.surah, this.initialAyah});

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final _keys = <int, GlobalKey>{};

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(surahContentProvider(widget.surah.number));
    final storage = LocalStorage();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: Text(widget.surah.nameArabic),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('تعذّر تحميل السورة', style: TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 20)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(surahContentProvider(widget.surah.number)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.navy)),
              ),
            ],
          ),
        ),
        data: (ayahs) {
          for (final a in ayahs) {
            _keys.putIfAbsent(a.numberInSurah, () => GlobalKey());
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.initialAyah == null) return;
            final key = _keys[widget.initialAyah];
            if (key?.currentContext != null) {
              Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            }
          });
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.lg),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];
              return _AyahCard(
                key: _keys[ayah.numberInSurah],
                ayah: ayah,
                surahNumber: widget.surah.number,
                storage: storage,
                isTarget: widget.initialAyah != null && ayah.numberInSurah == widget.initialAyah,
              );
            },
          );
        },
      ),
    );
  }
}

class _AyahCard extends StatefulWidget {
  final AyahModel ayah;
  final int surahNumber;
  final LocalStorage storage;
  final bool isTarget;
  _AyahCard({super.key, required this.ayah, required this.surahNumber, required this.storage, this.isTarget = false});

  @override
  State<_AyahCard> createState() => _AyahCardState();
}

class _AyahCardState extends State<_AyahCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.storage.isBookmarked('${widget.surahNumber}:${widget.ayah.numberInSurah}');
  }

  void _toggleBookmark() {
    final key = '${widget.surahNumber}:${widget.ayah.numberInSurah}';
    if (_isBookmarked) {
      widget.storage.removeBookmark(key);
    } else {
      widget.storage.addBookmark(key);
    }
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _showTafsir(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _TafsirSheet(
        surah: widget.surahNumber,
        ayah: widget.ayah.numberInSurah,
        ayahText: widget.ayah.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: widget.isTarget ? AppColors.goldMuted.withValues(alpha: 0.15) : AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: widget.isTarget ? AppColors.gold : AppColors.goldMuted, width: widget.isTarget ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.goldMuted, shape: BoxShape.circle),
                child: Center(
                  child: Text('${widget.ayah.numberInSurah}',
                    style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: AppColors.gold, size: 20),
                  ),
                  IconButton(
                    onPressed: () => _showTafsir(context),
                    icon: const Icon(Icons.menu_book, color: AppColors.goldMuted, size: 20),
                    tooltip: 'التفسير',
                  ),
                  AyahAudioPlayer(
                    surahNumber: widget.surahNumber,
                    ayahNumber: widget.ayah.numberInSurah,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            widget.ayah.text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 24, height: 2.2),
          ),
          if (widget.ayah.translation != null) ...[
            const SizedBox(height: AppDimensions.md),
            const Divider(color: AppColors.goldMuted),
            const SizedBox(height: AppDimensions.sm),
            Text(
              widget.ayah.translation!,
              style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 13, fontStyle: FontStyle.italic, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

class _TafsirSheet extends ConsumerStatefulWidget {
  final int surah;
  final int ayah;
  final String ayahText;
  const _TafsirSheet({required this.surah, required this.ayah, required this.ayahText});

  @override
  ConsumerState<_TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends ConsumerState<_TafsirSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabLabels = ['التفسير', 'معاني الكلمات', 'أسباب النزول'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimensions.sm),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppDimensions.md),
          Text('سورة رقم ${widget.surah} • آية رقم ${widget.ayah}', style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
          const SizedBox(height: AppDimensions.sm),
          Text(widget.ayahText, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimensions.md),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textOnDarkMuted,
            labelStyle: const TextStyle(fontFamily: 'Amiri', fontSize: 12),
            tabs: tabLabels.map((l) => Tab(text: l)).toList(),
            isScrollable: true,
          ),
          const Divider(color: AppColors.goldMuted, height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MultiTafsirTab(surah: widget.surah, ayah: widget.ayah),
                _WordMeaningsTab(surah: widget.surah, ayah: widget.ayah),
                _AsbabTab(surah: widget.surah, ayah: widget.ayah),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiTafsirTab extends ConsumerStatefulWidget {
  final int surah;
  final int ayah;
  const _MultiTafsirTab({required this.surah, required this.ayah});

  @override
  ConsumerState<_MultiTafsirTab> createState() => _MultiTafsirTabState();
}

class _MultiTafsirTabState extends ConsumerState<_MultiTafsirTab> {
  TafsirEdition _selected = TafsirEdition.muyassar;

  @override
  Widget build(BuildContext context) {
    final editions = TafsirEdition.values;
    final async = ref.watch(multiTafsirProvider((surah: widget.surah, ayah: widget.ayah, edition: _selected)));

    return Column(
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: editions.map((e) {
              final selected = e == _selected;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selected = e),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.gold : AppColors.navyLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: selected ? AppColors.gold : AppColors.goldMuted),
                    ),
                    child: Text(e.name,
                      style: TextStyle(
                        color: selected ? AppColors.navy : AppColors.goldMuted,
                        fontFamily: 'Amiri',
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: async.when(
              loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(color: AppColors.gold))),
              error: (_, __) => const Text('تعذر تحميل التفسير', style: TextStyle(color: Colors.red, fontFamily: 'Amiri')),
              data: (data) => data.isEmpty
                  ? const Text('غير متصل — التفسير غير متاح حالياً', style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri'))
                  : Text(data, textAlign: TextAlign.justify, textDirection: TextDirection.rtl,
                      style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 15, height: 1.6)),
            ),
          ),
        ),
      ],
    );
  }
}

class _WordMeaningsTab extends ConsumerWidget {
  final int surah;
  final int ayah;
  const _WordMeaningsTab({required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wordMeaningsProvider((surah: surah, ayah: ayah)));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: async.when(
        loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(color: AppColors.gold))),
        error: (_, __) => const Text('تعذر تحميل معاني الكلمات', style: TextStyle(color: Colors.red, fontFamily: 'Amiri')),
        data: (words) {
          if (words.isEmpty) {
            return const Text('غير متصل — معاني الكلمات غير متاحة حالياً', style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri'));
          }
          return Column(
            children: words.map((w) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: AppColors.goldMuted, shape: BoxShape.circle),
                    child: Center(child: Text('${w.position}', style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 12),
                  Text(w.arabic, textDirection: TextDirection.rtl, style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
                    ),
                    child: Text(w.translation, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Inter', fontSize: 11)),
                  ),
                ],
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

class _AsbabTab extends ConsumerWidget {
  final int surah;
  final int ayah;
  const _AsbabTab({required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(asbabProvider((surah: surah, ayah: ayah)));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: async.when(
        loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: CircularProgressIndicator(color: AppColors.gold))),
        error: (_, __) => const Text('تعذر تحميل سبب النزول', style: TextStyle(color: Colors.red, fontFamily: 'Amiri')),
        data: (text) => text.isEmpty
            ? const Text('لا يوجد سبب نزول مسجّل لهذه الآية', style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri'))
            : Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.navyLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.3)),
                ),
                child: Text(text, textAlign: TextAlign.justify, textDirection: TextDirection.rtl,
                    style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 15, height: 1.6)),
              ),
      ),
    );
  }
}
