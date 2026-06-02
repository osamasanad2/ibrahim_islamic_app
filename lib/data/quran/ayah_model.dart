class AyahModel {
  final int numberInSurah;
  final int numberInQuran;
  final String text;
  final String? translation;
  final int surahNumber;

  const AyahModel({
    required this.numberInSurah,
    required this.numberInQuran,
    required this.text,
    this.translation,
    required this.surahNumber,
  });
}
