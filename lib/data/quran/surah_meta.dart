class SurahMeta {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final int ayahs;
  final String revelationType;
  final int startPage;

  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.ayahs,
    required this.revelationType,
    this.startPage = 1,
  });

  factory SurahMeta.fromJson(Map<String, dynamic> json) => SurahMeta(
        number: json['number'] as int,
        nameArabic: json['name_arabic'] as String,
        nameEnglish: json['name_english'] as String,
        nameTransliteration: json['name_transliteration'] as String,
        ayahs: json['ayahs'] as int,
        revelationType: json['revelation_type'] as String,
        startPage: (json['start_page'] as int?) ?? 1,
      );
}
