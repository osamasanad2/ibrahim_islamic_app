class AudioFocus {
  static final AudioFocus _instance = AudioFocus._();
  factory AudioFocus() => _instance;
  AudioFocus._();

  void Function()? _onStop;

  void request(void Function() stopCurrent) {
    if (_onStop != null) {
      _onStop!();
    }
    _onStop = stopCurrent;
  }

  void release() {
    _onStop = null;
  }
}
