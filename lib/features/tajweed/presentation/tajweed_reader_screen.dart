import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../data/quran/quran_providers.dart';
import '../../../../data/quran/ayah_model.dart';
import '../../../../data/quran/tafsir_edition.dart';
import '../../../features/quran/presentation/widgets/ayah_audio_player.dart';

class TajweedReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final String? surahName;
  const TajweedReaderScreen({
    super.key,
    required this.surahNumber,
    this.surahName,
  });

  @override
  ConsumerState<TajweedReaderScreen> createState() => _TajweedReaderScreenState();
}

class _TajweedReaderScreenState extends ConsumerState<TajweedReaderScreen> {
  bool _tajweedMode = true;

  void _showSurahPicker() {
    final surahsAsync = ref.read(surahListProvider);
    final surahs = surahsAsync.valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('اختر سورة', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 22, fontWeight: FontWeight.w700)),
            const Divider(color: AppColors.goldMuted),
            Expanded(
              child: ListView.builder(
                itemCount: surahs.length,
                itemBuilder: (_, i) {
                  final s = surahs[i];
                  final isCurrent = s.number == widget.surahNumber;
                  return ListTile(
                    leading: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.gold : AppColors.goldMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('${s.number}', style: TextStyle(color: isCurrent ? AppColors.navy : AppColors.gold, fontSize: 11))),
                    ),
                    title: Text(s.nameArabic, style: TextStyle(color: isCurrent ? AppColors.gold : AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16)),
                    subtitle: Text(s.revelationType == 'Meccan' ? 'مكية' : 'مدنية', style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
                    trailing: isCurrent ? const Icon(Icons.check, color: AppColors.gold) : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/tajweed-reader', extra: {'surah': s.number, 'surahName': s.nameArabic});
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tajweed color constants
  static const _maddColor = Color(0xFFE53935);
  static const _ghunnahColor = Color(0xFF4CAF50);
  static const _ikhfaColor = Color(0xFF9C27B0);
  static const _iqlabColor = Color(0xFF008080);
  static const _idghamNoGhunnahColor = Color(0xFFFFEB3B);
  static const _qalqalahColor = Color(0xFF1E88E5);
  static const _tafkhimColor = Color(0xFFFF8F00);

  // Letter sets for tajweed rules
  static const _ikhfaLetters = 'تثجدذزسشصضطظفققك';
  static const _qalqalahLetters = 'قطبجد';
  static const _idghamWithGhunnahLetters = 'ينمو';
  static const _idghamWithoutGhunnahLetters = 'رل';
  static const _heavyLetters = 'خصضطظغق';

  bool _isCombiningMark(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 0x064B && code <= 0x0652) ||
        code == 0x0653 ||
        code == 0x0670 ||
        code == 0x06DF ||
        code == 0x06E1 ||
        code == 0x06ED;
  }

  int? _nextRealLetterIndex(String text, int start) {
    for (int i = start; i < text.length; i++) {
      if (!_isCombiningMark(text[i]) && text[i] != ' ') return i;
    }
    return null;
  }

  bool _hasSukunAfter(String text, int index) {
    for (int i = 1; i <= 3 && index + i < text.length; i++) {
      final ch = text[index + i];
      if (ch == 'ْ' || ch == '۟' || ch == 'ۡ') return true;
      if (!_isCombiningMark(ch)) break;
    }
    return false;
  }

  bool _hasTanweenAfter(String text, int index) {
    for (int i = 1; i <= 3 && index + i < text.length; i++) {
      final ch = text[index + i];
      if (ch == 'ً' || ch == 'ٍ' || ch == 'ٌ') return true;
      if (!_isCombiningMark(ch)) break;
    }
    return false;
  }

  Color? _getNoonSakinahRuleColor(String nextLetter) {
    if (_idghamWithGhunnahLetters.contains(nextLetter)) return _ghunnahColor;
    if (_idghamWithoutGhunnahLetters.contains(nextLetter)) return _idghamNoGhunnahColor;
    if (nextLetter == 'ب') return _iqlabColor;
    if (_ikhfaLetters.contains(nextLetter)) return _ikhfaColor;
    return null;
  }

  Color? _determineTanweenColor(String text, int tanweenIdx) {
    final tanweenChar = text[tanweenIdx];
    int searchStart = tanweenIdx + 1;
    // Skip the seat alif for tanween fatha: letter + FATHATAN + (ا or ى)
    if (tanweenChar == 'ً' && searchStart < text.length) {
      int skip = searchStart;
      while (skip < text.length && _isCombiningMark(text[skip])) {
        skip++;
      }
      if (skip < text.length && (text[skip] == 'ا' || text[skip] == 'ى')) {
        searchStart = skip + 1;
      }
    }
    // Check for immediate iqlab marker after tanween
    if (searchStart < text.length && text[searchStart] == 'ۢ') return _iqlabColor;
    // Check for small low meem after tanween kasra
    if (searchStart < text.length &&
        (tanweenChar == 'ٍ' || tanweenChar == 'ٌ') &&
        text[searchStart] == 'ۭ') {
      searchStart++;
    }
    final int? nextLetterIdx = _nextRealLetterIndex(text, searchStart);
    if (nextLetterIdx != null) {
      final ruleColor = _getNoonSakinahRuleColor(text[nextLetterIdx]);
      if (ruleColor != null) return ruleColor;
    }
    return null;
  }

  bool _isRaaHeavy(String text, int index) {
    // Check vowel on the raa itself
    for (int i = 1; i <= 3 && index + i < text.length; i++) {
      final c = text[index + i];
      if (c == 'َ' || c == 'ُ') return true;
      if (c == 'ِ') return false;
      if (!_isCombiningMark(c)) break;
    }
    // Raa with sukun: check preceding vowel
    if (_hasSukunAfter(text, index)) {
      for (int i = 1; i <= 4 && index - i >= 0; i++) {
        final c = text[index - i];
        if (c == 'َ' || c == 'ُ') return true;
        if (c == 'ِ') {
          // Preceded by kasra: check if the letter carrying it is heavy
          for (int j = index - i - 1; j >= 0; j--) {
            if (!_isCombiningMark(text[j]) && text[j] != ' ') {
              if (_heavyLetters.contains(text[j])) return true;
              break;
            }
          }
          return false;
        }
        if (!_isCombiningMark(c) && c != ' ') break;
      }
    }
    return false;
  }

  Color? _getTajweedColor(String text, int index) {
    final char = text[index];

    // === UTHMANI SPECIAL MARKS ===
    if (char == 'ۢ') return _iqlabColor;
    if (char == 'ۥ' || char == 'ۦ') return _maddColor;
    if (char == 'ۭ') {
      if (index > 0 && 'ًٌٍ'.contains(text[index - 1])) {
        return _determineTanweenColor(text, index - 1);
      }
      return _ikhfaColor;
    }

    // === SHADDAH MARK ===
    if (char == 'ّ') {
      if (index > 0) {
        final prev = text[index - 1];
        if (prev == 'ن' || prev == 'م') return _ghunnahColor;
        if (prev == 'ر' || prev == 'ل') return _idghamNoGhunnahColor;
      }
      return null;
    }

    // === TANWEEN MARKS ===
    if (char == 'ً' || char == 'ٍ' || char == 'ٌ') {
      return _determineTanweenColor(text, index);
    }

    // === SUKUN MARKS ===
    if (char == 'ْ' || char == '۟' || char == 'ۡ') {
      if (index > 0 && _qalqalahLetters.contains(text[index - 1])) {
        return _qalqalahColor;
      }
      return null;
    }

    // === NOON/MEEM WITH SHADDAH (look ahead) ===
    if ((char == 'ن' || char == 'م') &&
        index + 1 < text.length &&
        text[index + 1] == 'ّ') {
      return _ghunnahColor;
    }

    // === NOON SAKINAH (explicit noon + sukun) ===
    if (char == 'ن' && _hasSukunAfter(text, index)) {
      final int? nextLetterIdx = _nextRealLetterIndex(text, index + 2);
      if (nextLetterIdx != null) {
        final ruleColor = _getNoonSakinahRuleColor(text[nextLetterIdx]);
        if (ruleColor != null) return ruleColor;
      }
    }

    // === LETTER WITH TANWEEN ===
    if (_hasTanweenAfter(text, index)) {
      final Color? tanweenColor = _determineTanweenColor(text, index + 1);
      if (tanweenColor != null) return tanweenColor;
    }

    // === TANWEEN SEAT ALIF (ا after tanween fatha) ===
    if (char == 'ا' && index > 0 && text[index - 1] == 'ً') {
      final Color? seatColor = _determineTanweenColor(text, index - 1);
      if (seatColor != null) return seatColor;
    }

    // === TAFKHIM: Lam in "الله" ===
    if (char == 'ل' &&
        index + 2 < text.length &&
        text[index + 1] == 'ل' &&
        text[index + 2] == 'ه') {
      return _tafkhimColor;
    }
    if (char == 'ه' &&
        index >= 2 &&
        text[index - 1] == 'ل' &&
        text[index - 2] == 'ل') {
      return _tafkhimColor;
    }

    // === TAFKHIM: Heavy Raa ===
    if (char == 'ر' && _isRaaHeavy(text, index)) return _tafkhimColor;

    // === QALQALAH ===
    if (_qalqalahLetters.contains(char) && _hasSukunAfter(text, index)) {
      return _qalqalahColor;
    }

    // === MADD LETTERS (lowest priority) ===
    if (char == 'ا' || char == 'و' || char == 'ي') return _maddColor;

    return null;
  }

  List<TextSpan> _buildTajweedSpans(String text) {
    if (text.isEmpty) return [const TextSpan(text: '')];
    final spans = <TextSpan>[];
    int start = 0;
    Color? currentColor = _getTajweedColor(text, 0);
    for (int i = 1; i < text.length; i++) {
      final color = _getTajweedColor(text, i);
      if (color != currentColor) {
        spans.add(TextSpan(
          text: text.substring(start, i),
          style: currentColor != null ? TextStyle(color: currentColor) : null,
        ));
        start = i;
        currentColor = color;
      }
    }
    spans.add(TextSpan(
      text: text.substring(start),
      style: currentColor != null ? TextStyle(color: currentColor) : null,
    ));
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final ayahsAsync = ref.watch(surahContentProvider(widget.surahNumber));
    final storage = LocalStorage();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: Text(
          widget.surahName ?? 'سورة رقم ${widget.surahNumber}',
          style: const TextStyle(
            color: AppColors.textOnDark,
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navy,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showSurahPicker,
            icon: const Icon(Icons.list, color: AppColors.goldMuted),
            tooltip: 'قائمة السور',
          ),
          IconButton(
            onPressed: () => setState(() => _tajweedMode = !_tajweedMode),
            icon: Icon(
              _tajweedMode ? Icons.text_fields : Icons.colorize,
              color: AppColors.gold,
            ),
            tooltip: _tajweedMode ? 'إظهار النص فقط' : 'إظهار التجويد',
          ),
        ],
      ),
      body: ayahsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'تعذّر تحميل السورة',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontFamily: 'Amiri',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(surahContentProvider(widget.surahNumber)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: AppColors.navy),
                ),
              ),
            ],
          ),
        ),
        data: (ayahs) => ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.lg),
          itemCount: ayahs.length + (_tajweedMode ? 1 : 0),
          itemBuilder: (context, index) {
            if (_tajweedMode && index == 0) {
              return _TajweedLegend();
            }
            final ayah = ayahs[_tajweedMode ? index - 1 : index];
            return _TajweedAyahCard(
              ayah: ayah,
              surahNumber: widget.surahNumber,
              storage: storage,
              tajweedMode: _tajweedMode,
              buildTajweedSpans: _buildTajweedSpans,
            );
          },
        ),
      ),
    );
  }
}

class _TajweedLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const legends = [
      (color: Color(0xFFE53935), label: 'مد'),
      (color: Color(0xFF4CAF50), label: 'غنة/إدغام بغنة'),
      (color: Color(0xFF9C27B0), label: 'إخفاء'),
      (color: Color(0xFF008080), label: 'إقلاب'),
      (color: Color(0xFFFFEB3B), label: 'إدغام بغير غنة'),
      (color: Color(0xFF1E88E5), label: 'قلقلة'),
      (color: Color(0xFFFF8F00), label: 'تفخيم'),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: legends.map((l) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: l.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              l.label,
              style: TextStyle(
                color: l.color,
                fontFamily: 'Amiri',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
}

class _TajweedAyahCard extends StatefulWidget {
  final AyahModel ayah;
  final int surahNumber;
  final LocalStorage storage;
  final bool tajweedMode;
  final List<TextSpan> Function(String) buildTajweedSpans;

  const _TajweedAyahCard({
    required this.ayah,
    required this.surahNumber,
    required this.storage,
    required this.tajweedMode,
    required this.buildTajweedSpans,
  });

  @override
  State<_TajweedAyahCard> createState() => _TajweedAyahCardState();
}

class _TajweedAyahCardState extends State<_TajweedAyahCard> {
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
      builder: (ctx) => _TajweedTafsirSheet(
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
        border: Border.all(color: AppColors.goldMuted, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.goldMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.ayah.numberInSurah}',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showTafsir(context),
                    icon: const Icon(
                      Icons.menu_book,
                      color: AppColors.goldMuted,
                      size: 20,
                    ),
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
          widget.tajweedMode
              ? RichText(
                  text: TextSpan(
                    children: widget.buildTajweedSpans(widget.ayah.text),
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontFamily: 'Amiri',
                      fontSize: 24,
                      height: 2.2,
                    ),
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                )
              : Text(
                  widget.ayah.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    height: 2.2,
                  ),
                ),
          if (widget.ayah.translation != null) ...[
            const SizedBox(height: AppDimensions.md),
            const Divider(color: AppColors.goldMuted),
            const SizedBox(height: AppDimensions.sm),
            Text(
              widget.ayah.translation!,
              style: const TextStyle(
                color: AppColors.textOnDarkMuted,
                fontFamily: 'Inter',
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TajweedTafsirSheet extends ConsumerStatefulWidget {
  final int surah;
  final int ayah;
  final String ayahText;
  const _TajweedTafsirSheet({
    required this.surah,
    required this.ayah,
    required this.ayahText,
  });

  @override
  ConsumerState<_TajweedTafsirSheet> createState() => _TajweedTafsirSheetState();
}

class _TajweedTafsirSheetState extends ConsumerState<_TajweedTafsirSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tabLabels = ['التفسير', 'أسباب النزول'];

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppDimensions.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'سورة رقم ${widget.surah} • آية رقم ${widget.ayah}',
            style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            widget.ayahText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                _TajweedMultiTafsirTab(
                  surah: widget.surah,
                  ayah: widget.ayah,
                ),
                _TajweedAsbabTab(
                  surah: widget.surah,
                  ayah: widget.ayah,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TajweedMultiTafsirTab extends ConsumerStatefulWidget {
  final int surah;
  final int ayah;
  const _TajweedMultiTafsirTab({required this.surah, required this.ayah});

  @override
  ConsumerState<_TajweedMultiTafsirTab> createState() => _TajweedMultiTafsirTabState();
}

class _TajweedMultiTafsirTabState extends ConsumerState<_TajweedMultiTafsirTab> {
  TafsirEdition _selected = TafsirEdition.muyassar;

  @override
  Widget build(BuildContext context) {
    const editions = TafsirEdition.values;
    final async = ref.watch(multiTafsirProvider((
      surah: widget.surah,
      ayah: widget.ayah,
      edition: _selected,
    )));

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.gold : AppColors.navyLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(
                        color: selected ? AppColors.gold : AppColors.goldMuted,
                      ),
                    ),
                    child: Text(
                      e.name,
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
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              ),
              error: (_, __) => const Text(
                'تعذر تحميل التفسير',
                style: TextStyle(color: Colors.red, fontFamily: 'Amiri'),
              ),
              data: (data) => data.isEmpty
                  ? const Text(
                      'غير متصل — التفسير غير متاح حالياً',
                      style: TextStyle(
                        color: AppColors.textOnDarkMuted,
                        fontFamily: 'Amiri',
                      ),
                    )
                  : Text(
                      data,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: AppColors.textOnDark,
                        fontFamily: 'Amiri',
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TajweedAsbabTab extends ConsumerWidget {
  final int surah;
  final int ayah;
  const _TajweedAsbabTab({required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(asbabProvider((surah: surah, ayah: ayah)));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        ),
        error: (_, __) => const Text(
          'تعذر تحميل سبب النزول',
          style: TextStyle(color: Colors.red, fontFamily: 'Amiri'),
        ),
        data: (text) => text.isEmpty
            ? const Text(
                'لا يوجد سبب نزول مسجّل لهذه الآية',
                style: TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontFamily: 'Amiri',
                ),
              )
            : Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.navyLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: AppColors.goldMuted.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontFamily: 'Amiri',
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ),
      ),
    );
  }
}
