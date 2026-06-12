import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AzkarAudioService {
  final FlutterTts _tts = FlutterTts();
  List<String> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _speaking = false;
  bool _initialized = false;
  String? _lastError;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  int get totalItems => _queue.length;
  String? get lastError => _lastError;

  final void Function(int index)? onIndexChanged;
  final void Function()? onCompleted;
  final void Function()? onStopped;
  final void Function(String error)? onError;

  AzkarAudioService({
    this.onIndexChanged,
    this.onCompleted,
    this.onStopped,
    this.onError,
  }) {
    _setupHandlers();
  }

  void _setupHandlers() {
    _tts.setCompletionHandler(() {
      _speaking = false;
      if (_isPlaying) {
        _advanceToNext();
      }
    });
    _tts.setCancelHandler(() {
      _speaking = false;
    });
    _tts.setErrorHandler((msg) {
      _speaking = false;
      _lastError = msg.toString();
      onError?.call(msg.toString());
    });
  }

  Future<void> init() async {
    if (_initialized) return;
    _lastError = null;
    try {
      final available = await _tts.isLanguageAvailable('ar');
      if (available != true) {
        final alt = await _tts.isLanguageAvailable('ar-SA');
        if (alt == true) {
          await _tts.setLanguage('ar-SA');
        } else {
          try {
            await _tts.setLanguage('ar');
          } catch (_) {
            _lastError = 'اللغة العربية غير متوفرة في محرك النطق';
            onError?.call(_lastError!);
            return;
          }
        }
      } else {
        await _tts.setLanguage('ar');
      }
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      _initialized = true;
    } catch (e) {
      _lastError = 'فشل تهيئة محرك الصوت';
      onError?.call(_lastError!);
    }
  }

  Future<void> setQueue(List<String> texts) async {
    _queue = List.from(texts);
  }

  Future<void> playAll() async {
    await init();
    if (!_initialized) return;
    if (_queue.isEmpty) return;
    _currentIndex = 0;
    _isPlaying = true;
    _isPaused = false;
    onIndexChanged?.call(_currentIndex);
    await _speakCurrent();
  }

  Future<void> playAt(int index) async {
    await init();
    if (!_initialized) return;
    if (index < 0 || index >= _queue.length) return;
    await _tts.stop();
    _speaking = false;
    _currentIndex = index;
    _isPlaying = true;
    _isPaused = false;
    onIndexChanged?.call(_currentIndex);
    await _speakCurrent();
  }

  Future<void> playNext() async {
    if (_currentIndex < _queue.length - 1) {
      await playAt(_currentIndex + 1);
    } else {
      await stop();
      onCompleted?.call();
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      await playAt(_currentIndex - 1);
    }
  }

  Future<void> togglePause() async {
    await init();
    if (!_initialized) return;
    if (_isPaused) {
      _isPaused = false;
      await _speakCurrent();
    } else {
      _isPaused = true;
      _speaking = false;
      await _tts.stop();
    }
  }

  Future<void> stop() async {
    _speaking = false;
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _currentIndex = -1;
    onStopped?.call();
  }

  Future<void> _speakCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    if (_speaking) {
      await _tts.stop();
      _speaking = false;
    }
    try {
      _speaking = true;
      _lastError = null;
      final result = await _tts.speak(_queue[_currentIndex]);
      if (result == 0) {
        _speaking = false;
        _lastError = 'فشل تشغيل الصوت - تأكد من تثبيت محرك النطق العربي';
        onError?.call(_lastError!);
      }
    } catch (e) {
      _speaking = false;
      _lastError = 'خطأ في تشغيل الصوت';
      onError?.call(_lastError!);
    }
  }

  void _advanceToNext() {
    if (!_isPlaying) return;
    final next = _currentIndex + 1;
    if (next < _queue.length) {
      _currentIndex = next;
      onIndexChanged?.call(_currentIndex);
      _speakCurrent();
    } else {
      _isPlaying = false;
      onCompleted?.call();
    }
  }

  void dispose() {
    _tts.stop();
    _tts.setCompletionHandler(() {});
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((_) {});
  }
}

final azkarAudioServiceProvider = Provider<AzkarAudioService>((ref) {
  final service = AzkarAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
