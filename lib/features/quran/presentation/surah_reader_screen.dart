import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../data/quran/quran_providers.dart';
import '../../../../data/quran/ayah_model.dart';
import '../../../data/quran/surah_meta.dart';
import 'widgets/ayah_audio_player.dart';

class SurahReaderScreen extends ConsumerWidget {
  final SurahMeta surah;
  const SurahReaderScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(surahContentProvider(surah.number));
    final storage = LocalStorage();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: Text(surah.nameArabic),
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
                onPressed: () => ref.invalidate(surahContentProvider(surah.number)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.navy)),
              ),
            ],
          ),
        ),
        data: (ayahs) => ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.lg),
          itemCount: ayahs.length,
          itemBuilder: (context, index) => _AyahCard(
            ayah: ayahs[index],
            surahNumber: surah.number,
            storage: storage,
          ),
        ),
      ),
    );
  }
}

class _AyahCard extends StatefulWidget {
  final AyahModel ayah;
  final int surahNumber;
  final LocalStorage storage;
  const _AyahCard({required this.ayah, required this.surahNumber, required this.storage});

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
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldMuted),
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

class _TafsirSheet extends ConsumerWidget {
  final int surah;
  final int ayah;
  final String ayahText;
  const _TafsirSheet({required this.surah, required this.ayah, required this.ayahText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tafsirAsync = ref.watch(tafsirProvider((surah: surah, ayah: ayah)));

    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppDimensions.xl),
          Text('سورة رقم $surah • آية رقم $ayah', style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
          const SizedBox(height: AppDimensions.md),
          Text(ayahText, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(color: AppColors.goldMuted, height: 32),
          const Text('التفسير الميسر', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimensions.md),
          tafsirAsync.when(
            loading: () => const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator(color: AppColors.gold)),
            error: (_, __) => const Text('تعذر تحميل التفسير', style: TextStyle(color: Colors.red, fontFamily: 'Amiri')),
            data: (tafsir) => tafsir.isEmpty
                ? const Text('غير متصل — التفسير غير متاح حالياً', style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri'))
                : Text(tafsir, textAlign: TextAlign.justify, textDirection: TextDirection.rtl,
                    style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16, height: 1.6)),
          ),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}
