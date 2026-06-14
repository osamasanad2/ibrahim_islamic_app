class AsbabEntry {
  final int surahNumber;
  final int? ayahNumber;
  final String text;
  final String? source;
  final String type;

  const AsbabEntry({
    required this.surahNumber,
    this.ayahNumber,
    required this.text,
    this.source,
    this.type = 'general',
  });

  factory AsbabEntry.fromJson(Map<String, dynamic> json) => AsbabEntry(
        surahNumber: json['surah'] as int,
        ayahNumber: json['ayah'] as int?,
        text: json['text'] as String,
        source: json['source'] as String?,
        type: json['type'] as String? ?? 'general',
      );

  Map<String, dynamic> toJson() => {
        'surah': surahNumber,
        if (ayahNumber != null) 'ayah': ayahNumber,
        'text': text,
        if (source != null) 'source': source,
        'type': type,
      };

  String get key => ayahNumber != null ? '$surahNumber:$ayahNumber' : '$surahNumber';
}
