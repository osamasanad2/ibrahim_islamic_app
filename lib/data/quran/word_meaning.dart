class WordMeaning {
  final int position;
  final String arabic;
  final String translation;

  const WordMeaning({
    required this.position,
    required this.arabic,
    required this.translation,
  });

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      position: json['position'] as int? ?? 0,
      arabic: json['text_uthmani'] as String? ?? json['text'] as String? ?? '',
      translation: (json['translation'] as Map<String, dynamic>?)?['text'] as String? ?? '',
    );
  }
}
