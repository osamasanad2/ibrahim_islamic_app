import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/recent_activity_service.dart';
import '../../azkar/data/azkar_audio_service.dart';

class Zikr {
  final int id;
  final String arabic;
  final String translation;
  final int count;
  final String source;
  final String? category;
  final String? benefits;

  const Zikr({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.count,
    required this.source,
    this.category,
    this.benefits,
  });

  factory Zikr.fromAzkarJson(Map<String, dynamic> json) => Zikr(
        id: json['id'] as int,
        arabic: json['arabic'] as String,
        translation: json['translation'] as String,
        count: json['count'] as int,
        source: json['source'] as String,
        category: json['category'] as String,
        benefits: json['benefits'] as String?,
      );

  factory Zikr.fromOccasionJson(Map<String, dynamic> json) => Zikr(
        id: json['id'] as int,
        arabic: json['arabic'] as String,
        translation: json['translation'] as String,
        count: json['count'] as int,
        source: json['reference'] as String,
        category: json['category'] as String,
      );
}

class AdhkarScreen extends ConsumerStatefulWidget {
  final int initialMainTab;
  final int initialTimeTab;
  
  const AdhkarScreen({
    super.key,
    this.initialMainTab = 0,
    this.initialTimeTab = 0,
  });

  @override
  ConsumerState<AdhkarScreen> createState() => _AdhkarScreenState();
}

// مسارات مقاطع صوتية مجانية لأذكار الصباح والمساء
// المصدر: makkahlive.net - مقاطع صوتية مفتوحة المصدر بصوت مشاري العفاسي
const _morningAudioUrl = 'https://www.islamcan.com/audio/azkar/morning.mp3';
const _eveningAudioUrl = 'https://www.islamcan.com/audio/azkar/evening.mp3';

class _AdhkarScreenState extends ConsumerState<AdhkarScreen> {
  late int _mainTabIndex;
  late int _timeTabIndex;

  List<Zikr> _morning = [];
  List<Zikr> _evening = [];
  List<Zikr> _occasions = [];
  List<String> _occasionCategories = [];
  String _selectedOccasionCategory = 'الكل';
  bool _loading = true;
  String? _error;

  // مشغّل الصوت الكامل لأذكار الصباح والمساء
  final AudioPlayer _fullAudioPlayer = AudioPlayer();
  bool _fullAudioPlaying = false;
  bool _fullAudioLoading = false;

  @override
  void initState() {
    super.initState();
    _mainTabIndex = widget.initialMainTab;
    _timeTabIndex = widget.initialTimeTab;
    recordActivity(id: 'adhkar', title: 'الأذكار', subtitle: 'الأذكار النبوية', route: '/adhkar', icon: '📿');
    _loadAll();
    _fullAudioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _fullAudioPlaying = state.playing;
          _fullAudioLoading = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _fullAudioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleFullAudio() async {
    if (_fullAudioLoading) return;
    try {
      if (_fullAudioPlaying) {
        await _fullAudioPlayer.pause();
      } else {
        final url = _timeTabIndex == 0 ? _morningAudioUrl : _eveningAudioUrl;
        if (_fullAudioPlayer.audioSource == null) {
          await _fullAudioPlayer.setUrl(url);
        }
        await _fullAudioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تشغيل الصوت، تأكد من اتصالك بالإنترنت', style: TextStyle(fontFamily: 'Amiri')), backgroundColor: AppColors.navyLight),
        );
      }
    }
  }

  Future<void> _stopFullAudio() async {
    await _fullAudioPlayer.stop();
    await _fullAudioPlayer.seek(Duration.zero);
  }

  Future<void> _loadAll() async {
    try {
      final azkarStr = await rootBundle.loadString('assets/azkar/azkar.json');
      final azkarData = json.decode(azkarStr) as Map<String, dynamic>;
      final occasionsStr = await rootBundle.loadString('assets/adhkar/occasions.json');
      final occasionsData = json.decode(occasionsStr) as Map<String, dynamic>;

      final morningRaw = azkarData['morning'];
      final eveningRaw = azkarData['evening'];
      final occasionsRaw = occasionsData['adhkar'];
      final categoriesRaw = occasionsData['categories'];

      if (morningRaw is! List || eveningRaw is! List || occasionsRaw is! List || categoriesRaw is! List) {
        if (mounted) setState(() => _error = 'خطأ في تنسيق البيانات');
        return;
      }

      final morning = morningRaw.map((e) => Zikr.fromAzkarJson(e as Map<String, dynamic>)).toList();
      final evening = eveningRaw.map((e) => Zikr.fromAzkarJson(e as Map<String, dynamic>)).toList();
      final occasions = occasionsRaw.map((e) => Zikr.fromOccasionJson(e as Map<String, dynamic>)).toList();
      final categories = ['الكل', ...categoriesRaw.cast<String>()];

      if (mounted) {
        setState(() {
          _morning = morning;
          _evening = evening;
          _occasions = occasions;
          _occasionCategories = categories;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'فشل تحميل الأذكار');
    }
  }

  List<Zikr> get _filteredOccasions {
    if (_selectedOccasionCategory == 'الكل') return _occasions;
    return _occasions.where((z) => z.category == _selectedOccasionCategory).toList();
  }

  List<Zikr> get _currentTimeList => _timeTabIndex == 0 ? _morning : _evening;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('الأذكار'),
        backgroundColor: AppColors.navy,
        elevation: 0,
      ),
      body: _error != null ? _buildError() : _loading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: AppColors.gold));

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () { setState(() { _error = null; _loading = true; }); _loadAll(); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.navy, fontFamily: 'Amiri')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildMainTabs(),
        Expanded(
          child: IndexedStack(
            index: _mainTabIndex,
            children: [
              _buildMorningEveningTab(),
              _buildOccasionsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.goldMuted, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildTabButton('أذكار الصباح والمساء', 0),
          _buildTabButton('الأذكار المنوعة', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final selected = _mainTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(azkarAudioServiceProvider).stop();
          setState(() => _mainTabIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.gold : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.gold : AppColors.textOnDarkMuted,
              fontFamily: 'Amiri',
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorningEveningTab() {
    return Column(
      children: [
        _buildTimeSubTabs(),
        _buildFullAudioBanner(),
        Expanded(
          child: Stack(
            children: [
              _ZikrList(azkar: _currentTimeList),
              _MiniPlayer(currentList: _currentTimeList),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullAudioBanner() {
    final label = _timeTabIndex == 0 ? 'أذكار الصباح' : 'أذكار المساء';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyLight, const Color(0xFF1A2744)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldMuted.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headphones_rounded, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('استمع إلى $label',
                  style: const TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 14, fontWeight: FontWeight.bold)),
                const Text('بصوت مشاري العفاسي',
                  style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 12)),
              ],
            ),
          ),
          if (_fullAudioLoading)
            const SizedBox(width: 36, height: 36,
              child: Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2)))
          else
            GestureDetector(
              onTap: _toggleFullAudio,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _fullAudioPlaying ? AppColors.gold : AppColors.navyLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold),
                ),
                child: Icon(
                  _fullAudioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: _fullAudioPlaying ? AppColors.navy : AppColors.gold,
                  size: 22,
                ),
              ),
            ),
          if (_fullAudioPlaying) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _stopFullAudio,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.navyLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldMuted),
                ),
                child: const Icon(Icons.stop_rounded, color: AppColors.textOnDarkMuted, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSubTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildSubTab('أذكار الصباح', 0),
          const SizedBox(width: 12),
          _buildSubTab('أذكار المساء', 1),
        ],
      ),
    );
  }


  Widget _buildSubTab(String label, int index) {
    final selected = _timeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(azkarAudioServiceProvider).stop();
          setState(() => _timeTabIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.gold : AppColors.navyLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.gold : AppColors.goldMuted),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.navy : AppColors.textOnDark,
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOccasionsTab() {
    return Column(
      children: [
        _buildCategoryChips(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('${_filteredOccasions.length} ذكر',
                style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Inter', fontSize: 12)),
              if (_selectedOccasionCategory != 'الكل')
                TextButton(
                  onPressed: () => setState(() => _selectedOccasionCategory = 'الكل'),
                  child: const Text('الكل', style: TextStyle(color: AppColors.gold, fontFamily: 'Amiri', fontSize: 13)),
                ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _ZikrList(azkar: _filteredOccasions),
              _MiniPlayer(currentList: _filteredOccasions),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _occasionCategories.length,
        itemBuilder: (context, index) {
          final cat = _occasionCategories[index];
          final selected = cat == _selectedOccasionCategory;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedOccasionCategory = cat);
              ref.read(azkarAudioServiceProvider).stop();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.gold : AppColors.navyLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? AppColors.gold : AppColors.goldMuted),
              ),
              child: Text(cat,
                style: TextStyle(
                  color: selected ? AppColors.navy : AppColors.textOnDark,
                  fontFamily: 'Amiri', fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniPlayer extends ConsumerWidget {
  final List<Zikr> currentList;
  const _MiniPlayer({required this.currentList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(azkarAudioServiceProvider);
    if (!audio.isPlaying && !audio.isPaused) return const SizedBox.shrink();

    final index = audio.currentIndex;
    final zikr = index >= 0 && index < currentList.length ? currentList[index] : null;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          top: AppDimensions.sm,
          bottom: MediaQuery.of(context).padding.bottom + AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          border: const Border(top: BorderSide(color: AppColors.goldMuted)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zikr != null ? 'ذِكر ${index + 1} من ${currentList.length}' : '',
                    style: const TextStyle(color: AppColors.gold, fontFamily: 'Inter', fontSize: 11),
                  ),
                  if (zikr != null)
                    Text(
                      zikr.arabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: AppColors.textOnDark, fontFamily: 'Amiri', fontSize: 14),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            if (index > 0)
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: AppColors.gold, size: 24),
                onPressed: () => audio.playPrevious(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            IconButton(
              icon: Icon(
                audio.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: AppColors.gold, size: 28,
              ),
              onPressed: () => audio.togglePause(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            if (index < currentList.length - 1)
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.gold, size: 24),
                onPressed: () => audio.playNext(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            IconButton(
              icon: const Icon(Icons.stop_rounded, color: AppColors.textOnDarkMuted, size: 22),
              onPressed: () => audio.stop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZikrList extends StatelessWidget {
  final List<Zikr> azkar;
  const _ZikrList({required this.azkar});

  @override
  Widget build(BuildContext context) {
    if (azkar.isEmpty) {
      return const Center(
        child: Text('لا توجد أذكار في هذه الفئة',
          style: TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Amiri', fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: azkar.length,
      itemBuilder: (context, index) => _ZikrCard(zikr: azkar[index], index: index),
    );
  }
}

class _ZikrCard extends ConsumerStatefulWidget {
  final Zikr zikr;
  final int index;
  const _ZikrCard({required this.zikr, required this.index});

  @override
  ConsumerState<_ZikrCard> createState() => _ZikrCardState();
}

class _ZikrCardState extends ConsumerState<_ZikrCard> {
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.zikr.count;
  }

  void _tap() {
    if (_remaining > 0) setState(() => _remaining--);
  }

  @override
  Widget build(BuildContext context) {
    final done = _remaining == 0;
    final audio = ref.watch(azkarAudioServiceProvider);
    final isCurrentTrack = audio.isPlaying && audio.currentIndex == widget.index;

    final borderColor = isCurrentTrack
        ? AppColors.success
        : done ? AppColors.success.withValues(alpha: 0.5) : AppColors.goldMuted;
    final bgColor = isCurrentTrack
        ? AppColors.success.withValues(alpha: 0.15)
        : done ? AppColors.success.withValues(alpha: 0.1) : AppColors.navyLight;

    final cat = widget.zikr.category;
    final categoryLabel = (cat == null || cat == 'morning' || cat == 'evening') ? '' : cat;

    return GestureDetector(
      onTap: _tap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppDimensions.md),
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.zikr.arabic,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: done ? AppColors.textOnDarkMuted : AppColors.gold,
                      fontFamily: 'Amiri',
                      fontSize: 20, height: 2.0,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                GestureDetector(
                  onTap: () {
                    final service = ref.read(azkarAudioServiceProvider);
                    if (isCurrentTrack) {
                      service.stop();
                    } else {
                      service.setQueue([widget.zikr.arabic]);
                      service.playAt(0);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrentTrack
                          ? AppColors.success.withValues(alpha: 0.2)
                          : AppColors.goldMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Icon(
                      isCurrentTrack && audio.isPlaying
                          ? Icons.volume_up_rounded
                          : Icons.play_arrow_rounded,
                      color: isCurrentTrack ? AppColors.success : AppColors.gold,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.zikr.source,
                    style: const TextStyle(color: AppColors.textOnDarkMuted, fontFamily: 'Inter', fontSize: 11)),
                ),
                const SizedBox(width: AppDimensions.sm),
                if (categoryLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(categoryLabel,
                      style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Amiri', fontSize: 11)),
                  ),
                const SizedBox(width: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: done ? AppColors.success : AppColors.goldMuted,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    done ? '✓' : '$_remaining/${widget.zikr.count}',
                    style: TextStyle(
                      color: done ? AppColors.white : AppColors.gold,
                      fontFamily: 'Inter', fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
