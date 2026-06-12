import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AzkarAudioService {
  final FlutterTts _tts = FlutterTts();
  List<String> _queue = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isPaused = false;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  int get totalItems => _queue.length;

  final void Function(int index)? onIndexChanged;
  final void Function()? onCompleted;
  final void Function()? onStopped;

  AzkarAudioService({this.onIndexChanged, this.onCompleted, this.onStopped}) {
    _tts.setLanguage('ar');
    _tts.setSpeechRate(0.35);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(_onSpeechComplete);
    _tts.setCancelHandler(_onCancel);
  }

  Future<void> setQueue(List<String> texts) async {
    _queue = texts;
  }

  Future<void> playAll() async {
    if (_queue.isEmpty) return;
    _currentIndex = 0;
    _isPlaying = true;
    _isPaused = false;
    onIndexChanged?.call(_currentIndex);
    await _speakCurrent();
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    await stop();
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
    if (_isPaused) {
      _isPaused = false;
      await _tts.speak(_queue[_currentIndex]);
    } else {
      _isPaused = true;
      await _tts.stop();
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _currentIndex = -1;
    onStopped?.call();
  }

  Future<void> _speakCurrent() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    await _tts.speak(_queue[_currentIndex]);
  }

  void _onSpeechComplete() {
    if (!_isPlaying) return;
    playNext();
  }

  void _onCancel() {
    if (!_isPaused) {
      _isPlaying = false;
    }
  }

  void dispose() {
    _tts.stop();
    _tts.setCompletionHandler(() {});
    _tts.setCancelHandler(() {});
  }
}

final azkarAudioServiceProvider = Provider<AzkarAudioService>((ref) {
  final service = AzkarAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
