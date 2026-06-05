import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../di/providers.dart';

class MushafCacheService {
  final Dio dio;
  Directory? _cacheDir;
  bool _isPreloading = false;

  static const String _baseUrl =
      'https://raw.githubusercontent.com/QuranHub/quran-pages-images/main/easyquran.com/hafs-tajweed';

  static const List<String> _mirrors = [
    'https://raw.githubusercontent.com/QuranHub/quran-pages-images/main/easyquran.com/hafs-tajweed',
  ];

  static const int totalPages = 604;
  static const int _maxRetries = 3;
  static const int _concurrentDownloads = 6;
  static const int _preloadCount = 20;

  MushafCacheService(this.dio);

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/mushaf_pages');
    if (!_cacheDir!.existsSync()) {
      _cacheDir!.createSync(recursive: true);
    }
    return _cacheDir!;
  }

  Future<String> getPagePath(int pageNum) async {
    final dir = await _getCacheDir();
    return '${dir.path}/page_$pageNum.jpg';
  }

  Future<bool> isPageCached(int pageNum) async {
    final path = await getPagePath(pageNum);
    return File(path).existsSync();
  }

  Future<int> cachedCount() async {
    final dir = await _getCacheDir();
    final files = dir.listSync().where((f) => f.path.endsWith('.jpg'));
    return files.length;
  }

  Future<void> downloadPage(int pageNum) async {
    final path = await getPagePath(pageNum);
    final file = File(path);
    if (file.existsSync()) return;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      for (final mirror in _mirrors) {
        try {
          await dio.download('$mirror/$pageNum.jpg', path,
              options: Options(receiveTimeout: const Duration(seconds: 30)));
          final f = File(path);
          if (f.existsSync() && f.lengthSync() > 1000) return;
          if (f.existsSync()) await f.delete();
        } on DioException catch (_) {
          continue;
        }
      }
      if (attempt < _maxRetries - 1) {
        await Future.delayed(Duration(seconds: (attempt + 1) * 2));
      }
    }
    throw Exception('Failed to download page $pageNum after $_maxRetries attempts');
  }

  Future<void> preloadPages({int count = _preloadCount}) async {
    if (_isPreloading) return;
    _isPreloading = true;
    try {
      await downloadRecent(count);
    } finally {
      _isPreloading = false;
    }
  }

  Future<void> downloadAll(void Function(int downloaded, int total) onProgress) async {
    final dir = await _getCacheDir();
    final existing = dir.listSync().where((f) => f.path.endsWith('.jpg')).length;
    if (existing >= totalPages) return;

    final pending = <int>[];
    for (int i = 1; i <= totalPages; i++) {
      final path = '${dir.path}/page_$i.jpg';
      if (!File(path).existsSync()) {
        pending.add(i);
      }
    }

    if (pending.isEmpty) return;

    int completed = existing;
    const total = totalPages;

    for (int start = 0; start < pending.length; start += _concurrentDownloads) {
      final batch = pending.skip(start).take(_concurrentDownloads).toList();
      final futures = batch.map(downloadPage);
      await Future.wait(futures);
      completed += batch.length;
      onProgress(completed, total);
    }
  }

  Future<void> downloadRecent(int count) async {
    final dir = await _getCacheDir();
    int downloaded = 0;
    for (int i = 1; i <= totalPages && downloaded < count; i++) {
      final path = '${dir.path}/page_$i.jpg';
      if (!File(path).existsSync()) {
        try {
          await dio.download('$_baseUrl/$i.jpg', path);
          downloaded++;
        } catch (_) {}
      } else {
        downloaded++;
      }
    }
  }

  Future<int> deleteAll() async {
    final dir = await _getCacheDir();
    int count = 0;
    for (final f in dir.listSync()) {
      await f.delete();
      count++;
    }
    return count;
  }
}

final mushafCacheServiceProvider = Provider<MushafCacheService>((ref) {
  return MushafCacheService(ref.read(dioProvider));
});

final mushafDownloadProgressProvider =
    StateNotifierProvider<MushafDownloadProgressNotifier, AsyncValue<int?>>((ref) {
  return MushafDownloadProgressNotifier(ref.read(mushafCacheServiceProvider));
});

class MushafDownloadProgressNotifier extends StateNotifier<AsyncValue<int?>> {
  final MushafCacheService service;

  MushafDownloadProgressNotifier(this.service) : super(const AsyncData(null));

  Future<void> startDownload() async {
    state = const AsyncLoading();
    try {
      await service.downloadAll((downloaded, total) {
        state = AsyncData(downloaded);
      });
      state = const AsyncData(604);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> startPreload() async {
    try {
      await service.preloadPages();
      final count = await service.cachedCount();
      state = AsyncData(count);
    } catch (_) {}
  }

  Future<void> checkStatus() async {
    try {
      final count = await service.cachedCount();
      state = AsyncData(count >= 604 ? 604 : count);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
