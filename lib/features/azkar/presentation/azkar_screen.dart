import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/recent_activity_service.dart';
import '../data/azkar_audio_service.dart';

class Zikr {
  final int id;
  final String arabic;
  final String translation;
  final int count;
  final String source;
  final String category;
  final String benefits;

  const Zikr({
    required this.id,
    required this.arabic,
    required this.translation,
    required this.count,
    required this.source,
    required this.category,
    required this.benefits,
  });

  factory Zikr.fromJson(Map<String, dynamic> json) => Zikr(
        id: json['id'] as int,
        arabic: json['arabic'] as String,
        translation: json['translation'] as String,
        count: json['count'] as int,
        source: json['source'] as String,
        category: json['category'] as String,
        benefits: json['benefits'] as String,
      );
}

class AzkarScreen extends ConsumerStatefulWidget {
  const AzkarScreen({super.key});

  @override
  ConsumerState<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends ConsumerState<AzkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Zikr> _morning = [];
  List<Zikr> _evening = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    recordActivity(id: 'azkar', title: 'الأذكار', subtitle: 'أذكار الصباح والمساء', route: '/azkar', icon: '🌅');
    _loadAzkar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAzkar() async {
    final str = await rootBundle.loadString('assets/azkar/azkar.json');
    final data = json.decode(str) as Map<String, dynamic>;
    setState(() {
      _morning = (data['morning'] as List).map((e) => Zikr.fromJson(e as Map<String, dynamic>)).toList();
      _evening = (data['evening'] as List).map((e) => Zikr.fromJson(e as Map<String, dynamic>)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _tabController.index == 0 ? _morning : _evening;

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('الأذكار'),
        backgroundColor: AppColors.navy,
        elevation: 0,
        actions: [
          if (!_loading && currentList.isNotEmpty)
            Consumer(
              builder: (context, ref, _) {
                final audio = ref.watch(azkarAudioServiceProvider);
                final playing = audio.isPlaying;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.stop_rounded : Icons.play_circle_fill_rounded,
                    color: AppColors.gold,
                  ),
                  tooltip: playing ? 'إيقاف' : 'تشغيل الكل',
                  onPressed: () {
                    if (playing) {
                      audio.stop();
                    } else {
                      _playAll(ref, currentList);
                    }
                  },
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textOnDarkMuted,
          labelStyle: const TextStyle(fontFamily: 'Amiri', fontSize: 16),
          tabs: const [
            Tab(text: 'أذكار الصباح'),
            Tab(text: 'أذكار المساء'),
          ],
          onTap: (_) => ref.read(azkarAudioServiceProvider).stop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _ZikrList(azkar: _morning, category: 'morning'),
                    _ZikrList(azkar: _evening, category: 'evening'),
                  ],
                ),
                _MiniPlayer(currentList: currentList),
              ],
            ),
    );
  }

  void _playAll(WidgetRef ref, List<Zikr> azkar) {
    final audio = ref.read(azkarAudioServiceProvider);
    final texts = azkar.map((z) => z.arabic).toList();
    audio.setQueue(texts);
    audio.playAll();
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
  final String category;
  const _ZikrList({required this.azkar, required this.category});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: AppDimensions.lg,
        bottom: 80,
      ),
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
    if (_remaining > 0) {
      setState(() => _remaining--);
    }
  }

  Color _borderColor(WidgetRef ref) {
    final audio = ref.watch(azkarAudioServiceProvider);
    if (audio.isPlaying && audio.currentIndex == widget.index) return AppColors.success;
    if (_remaining == 0) return AppColors.success.withValues(alpha: 0.5);
    return AppColors.goldMuted;
  }

  Color _bgColor(WidgetRef ref) {
    final audio = ref.watch(azkarAudioServiceProvider);
    if (audio.isPlaying && audio.currentIndex == widget.index) return AppColors.success.withValues(alpha: 0.15);
    if (_remaining == 0) return AppColors.success.withValues(alpha: 0.1);
    return AppColors.navyLight;
  }

  @override
  Widget build(BuildContext context) {
    final done = _remaining == 0;
    final audio = ref.watch(azkarAudioServiceProvider);
    final isCurrentTrack = audio.isPlaying && audio.currentIndex == widget.index;

    return GestureDetector(
      onTap: _tap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: AppDimensions.md),
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: _bgColor(ref),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: _borderColor(ref)),
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
                      fontSize: 20,
                      height: 2.0,
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
                Text(
                  widget.zikr.source,
                  style: const TextStyle(
                    color: AppColors.textOnDarkMuted,
                    fontFamily: 'Inter',
                    fontSize: 11,
                  ),
                ),
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
                      fontFamily: 'Inter',
                      fontSize: 12,
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
