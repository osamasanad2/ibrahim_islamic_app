import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/local_storage.dart';

part 'font_size_provider.g.dart';

@riverpod
class FontScaleNotifier extends _$FontScaleNotifier {
  @override
  double build() {
    final storage = LocalStorage();
    return storage.getDouble('font_scale', defaultValue: 1.0);
  }

  void setFontScale(double scale) {
    state = scale;
    LocalStorage().saveDouble('font_scale', scale);
  }
}
