import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/recent_activity_service.dart';
import '../../../core/utils/quran_audio.dart';
import '../../../data/quran/quran_providers.dart';
import '../../../data/quran/ayah_model.dart';
import '../../../data/quran/surah_meta.dart';
import '../../../core/storage/local_storage.dart';

class QuranMushafScreen extends ConsumerStatefulWidget {
  final int initialPage;
  const QuranMushafScreen({super.key, this.initialPage = 0});

  @override
  ConsumerState<QuranMushafScreen> createState() => _QuranMushafScreenState();
}

class _QuranMushafScreenState extends ConsumerState<QuranMushafScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  final _storage = LocalStorage();
  bool _showControls = true;
  bool _isNightMode = false;
  bool _textMode = false;
  int _bookmarkedPage = 0;
  int _sessionResumePage = 1;
  List<Map<String, dynamic>>? _surahPages;
  String _reciterKey = 'afs';

  // مشغّل صوت المصحف المحلي
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  int _playingSurah = 0;

  @override
  void initState() {
    super.initState();
    recordActivity(id: 'mushaf', title: 'المصحف الشريف', subtitle: 'قراءة القرآن', route: '/mushaf', icon: '📖');
    final lastPage = _storage.getQuranPage();
    _currentPage = widget.initialPage > 0 ? widget.initialPage : lastPage;
    _sessionResumePage = _currentPage;
    _pageController = PageController(initialPage: _currentPage - 1);
    _isNightMode = _storage.getBool('mushaf_night_mode', defaultValue: false);
    _textMode = _storage.getBool('mushaf_text_mode', defaultValue: false);
    _bookmarkedPage = _storage.getQuranBookmark();
    _loadSurahPages();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _saveLastPage(int page) {
    _storage.saveQuranPage(page);
  }

  void _toggleNightMode() {
    setState(() {
      _isNightMode = !_isNightMode;
      _storage.saveBool('mushaf_night_mode', _isNightMode);
    });
  }

  void _toggleTextMode() {
    setState(() {
      _textMode = !_textMode;
      _storage.saveBool('mushaf_text_mode', _textMode);
    });
  }

  void _onPageChanged(int idx) {
    final page = idx + 1;
    setState(() => _currentPage = page);
    _saveLastPage(page);
  }

  void _goToNextPage() {
    if (_currentPage < 605) {
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pageController.animateToPage(
        _currentPage - 2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleBookmark() {
    setState(() {
      _bookmarkedPage = _bookmarkedPage == _currentPage ? 0 : _currentPage;
      _sessionResumePage = _currentPage;
      _storage.saveQuranBookmark(_bookmarkedPage);
    });
    if (_bookmarkedPage == _currentPage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الصفحة كعلامة مرجعية', style: TextStyle(fontFamily: 'Amiri')),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadSurahPages() async {
    final str = await rootBundle.loadString('assets/quran/surah_pages.json');
    final data = json.decode(str) as List;
    _surahPages = data.cast<Map<String, dynamic>>();
  }

  int _getSurahForPage(int page) {
    if (_surahPages == null) return 1;
    int surah = 1;
    for (final entry in _surahPages!) {
      final surahNum = entry['surah'] as int;
      final surahPage = entry['page'] as int;
      if (surahPage <= page) {
        surah = surahNum;
      } else {
        break;
      }
    }
    return surah;
  }

  static const _surahNames = [
    '', 'الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام','الأعراف','الأنفال','التوبة','يونس',
    'هود','يوسف','الرعد','إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه',
    'الأنبياء','الحج','المؤمنون','النور','الفرقان','الشعراء','النمل','القصص','العنكبوت','الروم',
    'لقمان','السجدة','الأحزاب','سبأ','فاطر','يس','الصافات','ص','الزمر','غافر',
    'فصلت','الشورى','الزخرف','الدخان','الجاثية','الأحقاف','محمد','الفتح','الحجرات','ق',
    'الذاريات','الطور','النجم','القمر','الرحمن','الواقعة','الحديد','المجادلة','الحشر','الممتحنة',
    'الصف','الجمعة','المنافقون','التغابن','الطلاق','التحريم','الملك','القلم','الحاقة','المعارج',
    'نوح','الجن','المزمل','المدثر','القيامة','الإنسان','المرسلات','النبأ','النازعات','عبس',
    'التكوير','الانفطار','المطففين','الانشقاق','البروج','الطارق','الأعلى','الغاشية','الفجر','البلد',
    'الشمس','الليل','الضحى','الشرح','التين','العلق','القدر','البينة','الزلزلة','العاديات',
    'القارعة','التكاثر','العصر','الهمزة','الفيل','قريش','الماعون','الكوثر','الكافرون','النصر',
    'المسد','الإخلاص','الفلق','الناس',
  ];

  String _getSurahName(int surah) {
    if (surah < 1 || surah > 114) return 'سورة $surah';
    return _surahNames[surah];
  }

  Future<void> _togglePlaySurah() async {
    if (_isLoading) return;
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        final surah = _getSurahForPage(_currentPage);
        if (_playingSurah != surah) {
          // سورة جديدة — أعد تحميل الرابط
          final url = QuranAudio.getSurahUrl(surah, reciterCode: _reciterKey);
          await _audioPlayer.setUrl(url);
          _playingSurah = surah;
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر تشغيل الصوت، تأكد من اتصالك بالإنترنت', style: TextStyle(fontFamily: 'Amiri')),
            backgroundColor: AppColors.navyLight,
          ),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    _playingSurah = 0;
  }

  String _reciterName() =>
      QuranAudio.reciters.entries.firstWhere((e) => e.value.code == _reciterKey).key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isNightMode ? const Color(0xFF121212) : const Color(0xFFFDF7E7),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: PageView.builder(
              controller: _pageController,
              itemCount: 605,
              reverse: true,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, idx) {
                if (idx == 604) {
                  return _DuaKhatmPage(isNightMode: _isNightMode);
                }
                if (_textMode) {
                  return _TextMushafPage(
                    pageNumber: idx + 1,
                    isNightMode: _isNightMode,
                  );
                }
                return _MushafPage(
                  pageNumber: idx + 1,
                  isNightMode: _isNightMode,
                );
              },
            ),
          ),
          _buildSideArrows(),
          if (_showControls) _buildTopBar(),
          if (_showControls) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSideArrows() {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_showControls,
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            children: [
              GestureDetector(
                onTap: _currentPage > 1 ? _goToPreviousPage : null,
                child: Container(
                  width: 56,
                  alignment: Alignment.center,
                  child: _currentPage > 1
                      ? Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.navigate_before, color: Colors.white, size: 28),
                        )
                      : null,
                ),
              ),
              const Expanded(child: SizedBox()),
              GestureDetector(
                onTap: _currentPage < 605 ? _goToNextPage : null,
                child: Container(
                  width: 56,
                  alignment: Alignment.center,
                  child: _currentPage < 605
                      ? Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.navigate_next, color: Colors.white, size: 28),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.5), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(_isNightMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white, size: 22),
                    onPressed: _toggleNightMode,
                    tooltip: 'الوضع الليلي',
                  ),
                  IconButton(
                    icon: Icon(_textMode ? Icons.image : Icons.text_snippet, color: Colors.white, size: 22),
                    onPressed: _toggleTextMode,
                    tooltip: _textMode ? 'وضع المصحف' : 'وضع القراءة',
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_currentPage == 605 ? 'دعاء ختم القرآن' : 'صفحة $_currentPage',
                      style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted, color: Colors.white, size: 22),
                    onPressed: () => _showIndexSheet(context),
                    tooltip: 'فهرس السور',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionChip(
                    icon: Icons.menu_book,
                    label: 'التفسير',
                    onTap: () => _showPageTafsir(context, _currentPage),
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.history_edu,
                    label: 'أسباب النزول',
                    onTap: () => _showPageTafsir(context, _currentPage),
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: _bookmarkedPage == _currentPage ? Icons.bookmark : Icons.bookmark_add_outlined,
                    label: _bookmarkedPage == _currentPage ? 'محفوظة' : 'حفظ الصفحة',
                    iconColor: _bookmarkedPage == _currentPage ? AppColors.gold : Colors.white70,
                    onTap: _toggleBookmark,
                  ),
                  if (_bookmarkedPage > 0 && _bookmarkedPage != _currentPage) ...[
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.double_arrow,
                      label: 'انتقال للمحفوظة',
                      iconColor: AppColors.gold,
                      onTap: () => _pageController.jumpToPage(_bookmarkedPage - 1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final showResume = _currentPage != _sessionResumePage;
    final surah = _getSurahForPage(_currentPage);
    final surahName = _currentPage == 605 ? 'دعاء ختم القرآن' : _getSurahName(surah);

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.only(top: 24, bottom: MediaQuery.of(context).padding.bottom + 16, left: 16, right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6), Colors.black.withValues(alpha: 0.95)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reciter Selection
                GestureDetector(
                  onTap: () => _showReciterPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(_reciterName(), style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                
                // Play Button
                GestureDetector(
                  onTap: _togglePlaySurah,
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isPlaying 
                          ? [AppColors.gold, AppColors.goldMuted]
                          : [AppColors.navyLight, AppColors.navy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isPlaying ? AppColors.gold : AppColors.navy).withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: _isLoading
                      ? const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                  ),
                ),

                // Surah Name + Stop
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(surahName, style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    if (_isPlaying) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _stopAudio,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stop_rounded, color: Colors.white70, size: 14),
                              SizedBox(width: 4),
                              Text('إيقاف', style: TextStyle(color: Colors.white70, fontFamily: 'Amiri', fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 1)
                  GestureDetector(
                    onTap: _goToPreviousPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ),
                  )
                else const SizedBox(width: 32),
                
                if (showResume)
                  GestureDetector(
                    onTap: () => _pageController.jumpToPage(_sessionResumePage - 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, color: AppColors.gold, size: 16),
                          const SizedBox(width: 6),
                          Text('عودة ($_sessionResumePage)', style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$_currentPage / 605',
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 14)),
                  ),

                if (_currentPage < 605)
                  GestureDetector(
                    onTap: _goToNextPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                    ),
                  )
                else const SizedBox(width: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: const BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('اختر القارئ', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(color: AppColors.goldMuted, height: 32),
            ...QuranAudio.reciters.entries.map((e) {
              final selected = e.value.code == _reciterKey;
              return ListTile(
                leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: AppColors.gold),
                title: Text(e.key, style: TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 18, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                trailing: selected ? const Icon(Icons.check, color: AppColors.gold) : null,
                onTap: () {
                  setState(() => _reciterKey = e.value.code);
                  Navigator.pop(ctx);
                  if (_isPlaying) {
                    _stopAudio().then((_) => _togglePlaySurah());
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showIndexSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _IndexSheet(
        onPageSelected: (page) {
          Navigator.pop(context);
          _pageController.jumpToPage(page - 1);
        },
      ),
    );
  }

  Future<void> _showPageTafsir(BuildContext context, int page) async {
    final ayahs = await ref.read(pageAyahsProvider(page).future);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PageTafsirListSheet(ayahs: ayahs, pageNumber: page),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  const _ActionChip({required this.icon, required this.label, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MushafPage extends StatelessWidget {
  final int pageNumber;
  final bool isNightMode;
  const _MushafPage({required this.pageNumber, required this.isNightMode});

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      'assets/mushaf/page_$pageNumber.jpg',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );

    if (isNightMode) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          -1,  0,  0, 0, 255,
           0, -1,  0, 0, 255,
           0,  0, -1, 0, 255,
           0,  0,  0, 1,   0,
        ]),
        child: image,
      );
    }

    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 3.0,
      child: Container(
        color: isNightMode ? const Color(0xFF121212) : const Color(0xFFFDF7E7),
        child: image,
      ),
    );
  }

  Widget _imageFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64, height: 64,
          decoration: const BoxDecoration(
            color: AppColors.goldMuted,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu_book, color: AppColors.gold, size: 32),
        ),
        const SizedBox(height: 16),
        Text('صفحة $pageNumber', style: TextStyle(fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold, color: isNightMode ? Colors.white : Colors.black)),
        const SizedBox(height: 8),
        const Text('الصفحة غير متاحة',
          style: TextStyle(fontFamily: 'Amiri', fontSize: 14, color: AppColors.textOnDarkMuted)),
      ],
    );
  }
}

class _DuaKhatmPage extends StatelessWidget {
  final bool isNightMode;
  const _DuaKhatmPage({required this.isNightMode});

  @override
  Widget build(BuildContext context) {
    final bgColor = isNightMode ? const Color(0xFF121212) : const Color(0xFFFDF7E7);
    final textColor = isNightMode ? Colors.white70 : const Color(0xFF3A2E1C);
    final accentColor = isNightMode ? AppColors.gold : const Color(0xFF8B7355);
    final dividerColor = isNightMode ? Colors.white12 : const Color(0xFFD4C5A9);
    final cardBg = isNightMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F0E6);

    return Container(
      color: bgColor,
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              // Bismillah
              Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accentColor,
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Text(
                  'دُعَاءُ خَتْمِ الْقُرْآنِ الْكَرِيمِ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Dua text
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Text(
                  'اللَّهُمَّ ارْحَمْنِي بِالْقُرْآنِ الْعَظِيمِ، وَاجْعَلْهُ لِي إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً، اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نَسِيتُ، وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ، وَارْزُقْنِي تِلَاوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ، وَاجْعَلْهُ لِي حُجَّةً يَا رَبَّ الْعَالَمِينَ.\n\n'
                  'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الْحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ، وَاجْعَلِ الْمَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ.\n\n'
                  'اللَّهُمَّ اجْعَلْ خَيْرَ عُمْرِي آخِرَهُ، وَخَيْرَ عَمَلِي خَوَاتِمَهُ، وَخَيْرَ أَيَّامِي يَوْمَ أَلْقَاكَ فِيهِ.\n\n'
                  'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِيشَةً هَنِيَّةً، وَمِيتَةً سَوِيَّةً، وَمَرَدًّا غَيْرَ مُخْزٍ وَلَا فَاضِحٍ.\n\n'
                  'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَسْأَلَةِ، وَخَيْرَ الدُّعَاءِ، وَخَيْرَ النَّجَاحِ، وَخَيْرَ الْعَمَلِ، وَخَيْرَ الثَّوَابِ، وَخَيْرَ الْحَيَاةِ، وَخَيْرَ الْمَمَاتِ، وَثَبِّتْنِي ثَقِّلْ بِهِ مَوَازِينِي، وَحَقِّقْ بِهِ إِيمَانِي، وَارْفَعْ بِهِ دَرَجَتِي، وَتَقَبَّلْهُ مِنِّي يَا أَرْحَمَ الرَّاحِمِينَ.\n\n'
                  'اللَّهُمَّ لَا تَجْعَلْهُ عَلَيَّ سُلْطَانًا وَلَا حُجَّةً، وَلَا تَجْعَلْهُ لِي شَيْئًا أَخَافُهُ يَوْمَ الْقِيَامَةِ، وَاجْعَلْهُ لِي نُورًا مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَمِنْ تَحْتِي، يَا ذَا الْجَلَالِ وَالْإِكْرَامِ.\n\n'
                  'اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُسْلِمِينَ وَالْمُسْلِمَاتِ، الْأَحْيَاءِ مِنْهُمْ وَالْأَمْوَاتِ، إِنَّكَ سَمِيعٌ قَرِيبٌ مُجِيبُ الدَّعَوَاتِ.\n\n'
                  'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.\n'
                  'وَصَلَّى اللَّهُ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلَّمَ تَسْلِيمًا كَثِيرًا.\n'
                  'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 2.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/app_icon.png', height: 56, width: 56),
              ),
              const SizedBox(height: 12),
              Text(
                'تطبيق إبراهيم',
                style: TextStyle(
                  color: accentColor,
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Closing dua
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dividerColor),
                ),
                child: Text(
                  'تقبل الله منا ومنكم صالح الأعمال\nولا تنسونا من صالح دعاكم',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.8,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndexSheet extends ConsumerWidget {
  final Function(int) onPageSelected;
  const _IndexSheet({required this.onPageSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('فهرس السور', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(color: AppColors.goldMuted, height: 32),
          Expanded(
            child: surahsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
              error: (_, __) => const Center(child: Text('خطأ في تحميل الفهرس', style: TextStyle(color: Colors.red))),
              data: (surahs) => ListView.builder(
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return ListTile(
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.goldMuted)),
                      alignment: Alignment.center,
                      child: Text('${surah.number}', style: const TextStyle(color: AppColors.gold, fontSize: 12)),
                    ),
                    title: Text(surah.nameArabic, style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 18)),
                    subtitle: Text('${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • آياتها ${surah.ayahs}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: Text('صفحة ${surah.startPage}', style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
                    onTap: () => onPageSelected(surah.startPage),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTafsirListSheet extends StatelessWidget {
  final List<dynamic> ayahs;
  final int pageNumber;
  const _PageTafsirListSheet({required this.ayahs, required this.pageNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: AppDimensions.xl),
          const Text('اختر الآية', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(color: AppColors.goldMuted, height: 32),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                final a = ayahs[index];
                return ListTile(
                  title: Text(a['text'], textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 18)),
                  subtitle: Text('سورة ${a['surah']['name']} • آية ${a['numberInSurah']}',
                    textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                    style: const TextStyle(color: AppColors.goldMuted, fontFamily: 'Amiri', fontSize: 12)),
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => _TafsirTabsSheet(
                        surah: a['surah']['number'], ayah: a['numberInSurah'], ayahText: a['text']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TafsirTabsSheet extends StatefulWidget {
  final int surah;
  final int ayah;
  final String ayahText;
  const _TafsirTabsSheet({required this.surah, required this.ayah, required this.ayahText});

  @override
  State<_TafsirTabsSheet> createState() => _TafsirTabsSheetState();
}

class _TafsirTabsSheetState extends State<_TafsirTabsSheet> with SingleTickerProviderStateMixin {
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.ayahText, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text('سورة رقم ${widget.surah} • آية رقم ${widget.ayah}', style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14)),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(fontFamily: 'Amiri', fontSize: 16, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'التفسير الميسر'),
              Tab(text: 'أسباب النزول'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TafsirTab(surah: widget.surah, ayah: widget.ayah),
                _AsbabTab(surah: widget.surah, ayah: widget.ayah),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TafsirTab extends ConsumerWidget {
  final int surah;
  final int ayah;
  const _TafsirTab({required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tafsirAsync = ref.watch(tafsirProvider((surah: surah, ayah: ayah)));
    return tafsirAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (_, __) => const Center(child: Text('تعذر تحميل التفسير', style: TextStyle(color: Colors.red, fontFamily: 'Amiri'))),
      data: (tafsir) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          tafsir.isEmpty ? 'التفسير غير متاح حالياً' : tafsir,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 18, height: 1.8),
        ),
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

class _AyahRange {
  final int surah;
  final int ayahStart;
  final int ayahEnd;
  const _AyahRange({required this.surah, required this.ayahStart, required this.ayahEnd});
}

List<_AyahRange> _getAyahRangesForPage(int page, List<SurahMeta> surahs) {
  final ranges = <_AyahRange>[];
  for (int i = 0; i < surahs.length; i++) {
    final surah = surahs[i];
    final startPage = surah.startPage;
    final endPage = i + 1 < surahs.length ? surahs[i + 1].startPage - 1 : 604;
    if (endPage < startPage) continue;
    if (page < startPage || page > endPage) continue;
    final totalPages = endPage - startPage + 1;
    final pageIndex = page - startPage;
    final ayahStart = pageIndex == 0 ? 1 : (surah.ayahs * pageIndex / totalPages).floor() + 1;
    final ayahEnd = pageIndex == totalPages - 1 ? surah.ayahs : (surah.ayahs * (pageIndex + 1) / totalPages).floor();
    if (ayahStart <= ayahEnd) {
      ranges.add(_AyahRange(surah: surah.number, ayahStart: ayahStart, ayahEnd: ayahEnd));
    }
  }
  return ranges;
}

final textPageAyahsProvider = FutureProvider.family<List<AyahModel>, int>((ref, page) async {
  final surahs = await ref.watch(surahListProvider.future);
  final ranges = _getAyahRangesForPage(page, surahs);
  if (ranges.isEmpty) return [];
  final uniqueSurahs = ranges.map((r) => r.surah).toSet();
  final surahAyahs = <int, List<AyahModel>>{};
  for (final sn in uniqueSurahs) {
    surahAyahs[sn] = await ref.watch(surahContentProvider(sn).future);
  }
  final result = <AyahModel>[];
  for (final range in ranges) {
    final ayahs = surahAyahs[range.surah]!;
    for (final ayah in ayahs) {
      if (ayah.numberInSurah >= range.ayahStart && ayah.numberInSurah <= range.ayahEnd) {
        result.add(ayah);
      }
    }
  }
  result.sort((a, b) => a.numberInQuran.compareTo(b.numberInQuran));
  return result;
});

class _TextMushafPage extends ConsumerWidget {
  final int pageNumber;
  final bool isNightMode;
  const _TextMushafPage({required this.pageNumber, required this.isNightMode});

  Color get _bgColor => isNightMode ? const Color(0xFF121212) : const Color(0xFFFDF7E7);
  Color get _textColor => isNightMode ? Colors.white70 : const Color(0xFF3A2E1C);
  Color get _accentColor => isNightMode ? AppColors.gold : const Color(0xFF8B7355);
  Color get _cardBg => isNightMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F0E6);
  Color get _dividerColor => isNightMode ? Colors.white12 : const Color(0xFFD4C5A9);

  static const _surahNames = [
    '', 'الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام','الأعراف','الأنفال','التوبة','يونس',
    'هود','يوسف','الرعد','إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه',
    'الأنبياء','الحج','المؤمنون','النور','الفرقان','الشعراء','النمل','القصص','العنكبوت','الروم',
    'لقمان','السجدة','الأحزاب','سبأ','فاطر','يس','الصافات','ص','الزمر','غافر',
    'فصلت','الشورى','الزخرف','الدخان','الجاثية','الأحقاف','محمد','الفتح','الحجرات','ق',
    'الذاريات','الطور','النجم','القمر','الرحمن','الواقعة','الحديد','المجادلة','الحشر','الممتحنة',
    'الصف','الجمعة','المنافقون','التغابن','الطلاق','التحريم','الملك','القلم','الحاقة','المعارج',
    'نوح','الجن','المزمل','المدثر','القيامة','الإنسان','المرسلات','النبأ','النازعات','عبس',
    'التكوير','الانفطار','المطففين','الانشقاق','البروج','الطارق','الأعلى','الغاشية','الفجر','البلد',
    'الشمس','الليل','الضحى','الشرح','التين','العلق','القدر','البينة','الزلزلة','العاديات',
    'القارعة','التكاثر','العصر','الهمزة','الفيل','قريش','الماعون','الكوثر','الكافرون','النصر',
    'المسد','الإخلاص','الفلق','الناس',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(textPageAyahsProvider(pageNumber));
    return ayahsAsync.when(
      loading: () => Container(
        color: _bgColor,
        child: const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (_, __) => Container(
        color: _bgColor,
        child: Center(
          child: Text('تعذر تحميل الآيات', style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: _textColor)),
        ),
      ),
      data: (ayahs) => _buildPage(context, ayahs),
    );
  }

  Widget _buildPage(BuildContext context, List<AyahModel> ayahs) {
    if (ayahs.isEmpty) {
      return Container(
        color: _bgColor,
        child: Center(
          child: Text('لا توجد آيات في هذه الصفحة', style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: _textColor)),
        ),
      );
    }

    return Container(
      color: _bgColor,
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildAyahSections(ayahs),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAyahSections(List<AyahModel> ayahs) {
    final widgets = <Widget>[];
    int? currentSurah;

    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];

      if (ayah.surahNumber != currentSurah) {
        currentSurah = ayah.surahNumber;
        widgets.add(_buildSurahHeader(currentSurah));
        if (currentSurah != 1 && currentSurah != 9 && ayah.numberInSurah == 1) {
          widgets.add(_buildBasmalah());
        }
      }

      widgets.add(_buildAyahCard(ayah));
    }

    return widgets;
  }

  Widget _buildSurahHeader(int surahNumber) {
    final name = surahNumber >= 1 && surahNumber <= 114 ? _surahNames[surahNumber] : 'سورة $surahNumber';
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _dividerColor),
          ),
          child: Text(
            'سورة $name',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _accentColor,
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasmalah() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _accentColor,
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(AyahModel ayah) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentColor),
                ),
                child: Center(
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: TextStyle(
                      color: _accentColor,
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ayah.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: _textColor,
                    fontFamily: 'Amiri',
                    fontSize: 22,
                    height: 1.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (ayah.translation != null && ayah.translation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ayah.translation!,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: _textColor.withValues(alpha: 0.7),
                fontFamily: 'Amiri',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
