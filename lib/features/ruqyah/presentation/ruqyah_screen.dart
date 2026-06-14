import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../azkar/data/azkar_audio_service.dart';

class _RuqyahVerse {
  final String surah;
  final int ayahNumber;
  final String arabic;
  final String description;

  const _RuqyahVerse({
    required this.surah,
    required this.ayahNumber,
    required this.arabic,
    required this.description,
  });
}

class _RuqyahDua {
  final String arabic;
  final String transliteration;
  final String translation;
  final String repeatCount;
  final String source;

  const _RuqyahDua({
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.repeatCount,
    required this.source,
  });
}

class _InstructionSection {
  final String title;
  final List<String> items;

  const _InstructionSection({
    required this.title,
    required this.items,
  });
}

class RuqyahScreen extends ConsumerStatefulWidget {
  const RuqyahScreen({super.key});

  @override
  ConsumerState<RuqyahScreen> createState() => _RuqyahScreenState();
}

class _RuqyahScreenState extends ConsumerState<RuqyahScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_RuqyahVerse> _verses = [
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 1,
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      description: 'الآية 1',
    ),
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 2,
      arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      description: 'الآية 2',
    ),
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 3,
      arabic: 'الرَّحْمَٰنِ الرَّحِيمِ',
      description: 'الآية 3',
    ),
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 4,
      arabic: 'مَالِكِ يَوْمِ الدِّينِ',
      description: 'الآية 4',
    ),
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 5,
      arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      description: 'الآية 5',
    ),
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 6,
      arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      description: 'الآية 6',
    ),
    _RuqyahVerse(
      surah: 'الفاتحة',
      ayahNumber: 7,
      arabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      description: 'الآية 7',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 1,
      arabic: 'الٓمٓ',
      description: 'الآية 1',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 2,
      arabic: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
      description: 'الآية 2',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 3,
      arabic: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ',
      description: 'الآية 3',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 4,
      arabic: 'وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنزِلَ إِلَيْكَ وَمَا أُنزِلَ مِن قَبْلِكَ وَبِالْآخِرَةِ هُمْ يُوقِنُونَ',
      description: 'الآية 4',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 5,
      arabic: 'أُولَٰئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ',
      description: 'الآية 5 من أول سورة البقرة',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 255,
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۚ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      description: 'آية الكرسي',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 285,
      arabic: 'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِّن رُّسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ',
      description: 'الآية 285 من آخر سورة البقرة',
    ),
    _RuqyahVerse(
      surah: 'البقرة',
      ayahNumber: 286,
      arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
      description: 'الآية 286 من آخر سورة البقرة',
    ),
    _RuqyahVerse(
      surah: 'آل عمران',
      ayahNumber: 18,
      arabic: 'شَهِدَ اللَّهُ أَنَّهُ لَا إِلَٰهَ إِلَّا هُوَ وَالْمَلَائِكَةُ وَأُولُو الْعِلْمِ قَائِمًا بِالْقِسْطِ ۚ لَا إِلَٰهَ إِلَّا هُوَ الْعَزِيزُ الْحَكِيمُ',
      description: 'الآية 18',
    ),
    _RuqyahVerse(
      surah: 'الكافرون',
      ayahNumber: 1,
      arabic: 'قُلْ يَا أَيُّهَا الْكَافِرُونَ',
      description: 'الآية 1',
    ),
    _RuqyahVerse(
      surah: 'الكافرون',
      ayahNumber: 2,
      arabic: 'لَا أَعْبُدُ مَا تَعْبُدُونَ',
      description: 'الآية 2',
    ),
    _RuqyahVerse(
      surah: 'الكافرون',
      ayahNumber: 3,
      arabic: 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
      description: 'الآية 3',
    ),
    _RuqyahVerse(
      surah: 'الكافرون',
      ayahNumber: 4,
      arabic: 'وَلَا أَنَا عَابِدٌ مَّا عَبَدتُّمْ',
      description: 'الآية 4',
    ),
    _RuqyahVerse(
      surah: 'الكافرون',
      ayahNumber: 5,
      arabic: 'وَلَا أَنتُمْ عَابِدُونَ مَا أَعْبُدُ',
      description: 'الآية 5',
    ),
    _RuqyahVerse(
      surah: 'الكافرون',
      ayahNumber: 6,
      arabic: 'لَكُمْ دِينُكُمْ وَلِيَ دِينِ',
      description: 'الآية 6 - سورة الكافرون كاملة',
    ),
    _RuqyahVerse(
      surah: 'الإخلاص',
      ayahNumber: 1,
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      description: 'الآية 1',
    ),
    _RuqyahVerse(
      surah: 'الإخلاص',
      ayahNumber: 2,
      arabic: 'اللَّهُ الصَّمَدُ',
      description: 'الآية 2',
    ),
    _RuqyahVerse(
      surah: 'الإخلاص',
      ayahNumber: 3,
      arabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      description: 'الآية 3',
    ),
    _RuqyahVerse(
      surah: 'الإخلاص',
      ayahNumber: 4,
      arabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      description: 'الآية 4 - سورة الإخلاص كاملة',
    ),
    _RuqyahVerse(
      surah: 'الفلق',
      ayahNumber: 1,
      arabic: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
      description: 'الآية 1',
    ),
    _RuqyahVerse(
      surah: 'الفلق',
      ayahNumber: 2,
      arabic: 'مِن شَرِّ مَا خَلَقَ',
      description: 'الآية 2',
    ),
    _RuqyahVerse(
      surah: 'الفلق',
      ayahNumber: 3,
      arabic: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
      description: 'الآية 3',
    ),
    _RuqyahVerse(
      surah: 'الفلق',
      ayahNumber: 4,
      arabic: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
      description: 'الآية 4',
    ),
    _RuqyahVerse(
      surah: 'الفلق',
      ayahNumber: 5,
      arabic: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      description: 'الآية 5 - سورة الفلق كاملة',
    ),
    _RuqyahVerse(
      surah: 'الناس',
      ayahNumber: 1,
      arabic: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
      description: 'الآية 1',
    ),
    _RuqyahVerse(
      surah: 'الناس',
      ayahNumber: 2,
      arabic: 'مَلِكِ النَّاسِ',
      description: 'الآية 2',
    ),
    _RuqyahVerse(
      surah: 'الناس',
      ayahNumber: 3,
      arabic: 'إِلَٰهِ النَّاسِ',
      description: 'الآية 3',
    ),
    _RuqyahVerse(
      surah: 'الناس',
      ayahNumber: 4,
      arabic: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
      description: 'الآية 4',
    ),
    _RuqyahVerse(
      surah: 'الناس',
      ayahNumber: 5,
      arabic: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
      description: 'الآية 5',
    ),
    _RuqyahVerse(
      surah: 'الناس',
      ayahNumber: 6,
      arabic: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
      description: 'الآية 6 - سورة الناس كاملة',
    ),
  ];

  final List<_RuqyahDua> _duas = [
    _RuqyahDua(
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration: 'A\'udhu bi kalimatillahit-tammati min sharri ma khalaq',
      translation: 'أعوذ بكلمات الله التامات من شر ما خلق - تقال صباحاً ومساءً (3 مرات)',
      repeatCount: '3',
      source: 'رواه مسلم',
    ),
    _RuqyahDua(
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      transliteration: 'Bismillahil-ladhi la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-sami\'ul-\'alim',
      translation: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم - تقال صباحاً ومساءً (3 مرات)',
      repeatCount: '3',
      source: 'رواه أبو داود والترمذي',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي',
      transliteration: 'Allahumma inni as\'alukal-\'afiyata fid-dunya wal-akhirah, Allahumma inni as\'alukal-\'afwa wal-\'afiyata fi dini wa dunyaya wa ahli wa mali',
      translation: 'اللهم إني أسألك العافية في الدنيا والآخرة - تقال صباحاً ومساءً',
      repeatCount: '1',
      source: 'رواه أبو داود وابن ماجه',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ، لَا إِلَهَ إِلَّا أَنْتَ',
      transliteration: 'Allahumma rahmataka arju fala takilni ila nafsi tarfata \'aynin, wa aslih li sha\'ni kullah, la ilaha illa ant',
      translation: 'اللهم رحمتك أرجو فلا تكلني إلى نفسي طرفة عين - دعاء للحماية من الشرور',
      repeatCount: '1',
      source: 'رواه أبو داود',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ، وَغَلَبَةِ الرِّجَالِ',
      transliteration: 'Allahumma inni a\'udhu bika minal-hammi wal-hazan, wal-\'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala\'id-dayn, wa ghalabatir-rijal',
      translation: 'اللهم إني أعوذ بك من الهم والحزن - دعاء للأرق والقلق',
      repeatCount: '1',
      source: 'رواه البخاري',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ',
      transliteration: 'Allahumma \'afini fi badani, Allahumma \'afini fi sam\'i, Allahumma \'afini fi basari, la ilaha illa ant',
      translation: 'اللهم عافني في بدني - دعاء للمريض (3 مرات)',
      repeatCount: '3',
      source: 'رواه أبو داود',
    ),
    _RuqyahDua(
      arabic: 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ',
      transliteration: 'As\'alullahal-\'azima rabbal-\'arshil-\'azimi an yashfiyak',
      translation: 'أسأل الله العظيم رب العرش العظيم أن يشفيك - تقال للمريض (7 مرات)',
      repeatCount: '7',
      source: 'رواه الترمذي',
    ),
    _RuqyahDua(
      arabic: 'بِسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِسْمِ اللَّهِ أَرْقِيكَ',
      transliteration: 'Bismillahi arqika, min kulli shay\'in yu\'dhika, min sharri kulli nafsin aw \'ayni hasidin, Allahu yashfika, bismillahi arqika',
      translation: 'بسم الله أرقيك - رقية شرعية للمريض (3 مرات)',
      repeatCount: '3',
      source: 'رواه مسلم',
    ),
    _RuqyahDua(
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      transliteration: 'A\'udhu bi kalimatillahit-tammati min kulli shaytanin wa hammah, wa min kulli \'aynin lammah',
      translation: 'أعوذ بكلمات الله التامة من كل شيطان وهامة - للحماية من العين والحسد',
      repeatCount: '3',
      source: 'رواه البخاري',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، وَاشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
      transliteration: 'Allahumma rabban-nasi, adhhibil-ba\'sa, washfi antash-shafi, la shifa\'a illa shifa\'uka, shifa\'an la yughadiru saqama',
      translation: 'اللهم رب الناس أذهب البأس - دعاء شفاء المريض',
      repeatCount: '3',
      source: 'رواه البخاري ومسلم',
    ),
    _RuqyahDua(
      arabic: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      transliteration: 'Hasbiyallahu la ilaha illa huwa \'alayhi tawakkaltu wa huwa rabbul-\'arshil-\'azim',
      translation: 'حسبي الله لا إله إلا هو عليه توكلت - تقال عند الخوف والقلق (7 مرات)',
      repeatCount: '7',
      source: 'سورة التوبة آية 129',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا',
      transliteration: 'Allahumma la sahla illa ma ja\'altahu sahla, wa anta taj\'alul-hazna idha shi\'ta sahla',
      translation: 'اللهم لا سهل إلا ما جعلته سهلاً - دعاء لتيسير الأمور وإزالة الهم',
      repeatCount: '1',
      source: 'رواه ابن حبان',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ زَوَالِ نِعْمَتِكَ، وَتَحَوُّلِ عَافِيَتِكَ، وَفُجَاءَةِ نِقْمَتِكَ، وَجَمِيعِ سَخَطِكَ',
      transliteration: 'Allahumma inni a\'udhu bika min zawali ni\'matika, wa tahawwuli \'afiyatika, wa fuja\'ati niqmatika, wa jami\'i sakhatik',
      translation: 'اللهم إني أعوذ بك من زوال نعمتك - دعاء للحفظ من المصائب',
      repeatCount: '1',
      source: 'رواه مسلم',
    ),
    _RuqyahDua(
      arabic: 'بِسْمِ اللَّهِ يُمْسِينَا وَعَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
      transliteration: 'Bismillahi yumsina wa \'ala fitratil-islam, wa \'ala kalimatil-ikhlas, wa \'ala dini nabiyyina Muhammadin sallallahu \'alayhi wa sallam',
      translation: 'دعاء المساء - الحفظ من الشرور',
      repeatCount: '1',
      source: 'رواه أحمد',
    ),
    _RuqyahDua(
      arabic: 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
      transliteration: 'Raditu billahi rabba, wa bil-islami dina, wa bi Muhammadin sallallahu \'alayhi wa sallama nabiyya',
      translation: 'رضيت بالله رباً - تقال صباحاً ومساءً (3 مرات) - من قالها وجبت له الجنة',
      repeatCount: '3',
      source: 'رواه أبو داود',
    ),
    _RuqyahDua(
      arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      transliteration: 'Allahumma salli wa sallim \'ala nabiyyina Muhammad',
      translation: 'الصلاة على النبي صلى الله عليه وسلم - من أنفع الرقية',
      repeatCount: '100',
      source: 'فاتحه للهموم ومطردة للشيطان',
    ),
  ];

  final List<_InstructionSection> _instructions = [
    _InstructionSection(
      title: 'شروط الرقية الشرعية',
      items: [
        'أن تكون بكلام الله تعالى (القرآن الكريم) وبأسمائه وصفاته',
        'أن تكون بالسنة النبوية وبالأدعية المأثورة عن النبي ﷺ',
        'أن تكون باللغة العربية أو بما يفهم معناه',
        'أن يعتقد الراقي والمرقي أن الرقية لا تؤثر بذاتها بل بإذن الله',
        'أن لا يكون فيها شرك أو استعانة بالجن أو الغيبيات',
        'أن لا تحتوي على ألفاظ غير مفهومة أو طلاسم',
      ],
    ),
    _InstructionSection(
      title: 'طريقة رقية النفس بنفسك',
      items: [
        'توضأ واستقبل القبلة وابدأ بالدعاء والاستغفار',
        'اقرأ سورة الفاتحة (7 مرات)',
        'اقرأ آية الكرسي (7 مرات)',
        'اقرأ سورة الإخلاص والمعوذتين (3-7 مرات)',
        'اقرأ أول 5 آيات من سورة البقرة',
        'اقرأ آخر آيتين من سورة البقرة',
        'اقرأ سورة الكافرون',
        'انفث في يديك وامسح بهما وجهك وجسدك (كما كان النبي ﷺ يفعل)',
        'كرر ذلك صباحاً ومساءً وعند الشعور بالضيق',
        'داوم على أذكار الصباح والمساء والتحصين اليومي',
      ],
    ),
    _InstructionSection(
      title: 'كيفية الرقية على الآخرين',
      items: [
        'ضع يدك على موضع الألم أو على رأس المريض',
        'قل: "بسم الله أرقيك من كل شيء يؤذيك، من شر كل نفس أو عين حاسد، الله يشفيك"',
        'اقرأ الفاتحة وآية الكرسي والإخلاص والمعوذتين وأنت تضع يدك',
        'قل: "أسأل الله العظيم رب العرش العظيم أن يشفيك" (7 مرات)',
        'امسح على موضع الألم بيدك اليمنى',
        'انفث نفثاً خفيفاً (بدون ريق) على المريض أثناء القراءة',
        'كرر الرقية ثلاث مرات أو أكثر',
        'يجب أن يكون الراقي من أهْلِ الخير والصلاح والتقوى',
      ],
    ),
    _InstructionSection(
      title: 'ما يقال عند زيارة المريض',
      items: [
        'تقول: "لا بأس طهور إن شاء الله"',
        'تقول: "أسأل الله العظيم رب العرش العظيم أن يشفيك" (7 مرات)',
        'تقرأ الفاتحة والإخلاص والمعوذتين',
        'تدعو للمريض بالشفاء العاجل',
        'تذكر المريض بالأجر والثواب في المرض',
        'ترفع معنويات المريض وتدعو له بالتفاؤل',
      ],
    ),
    _InstructionSection(
      title: 'علامات الحسد والعين',
      items: [
        'الصداع المستمر والتنقل في الرأس',
        'الاصفرار في الوجه والشحوب',
        'الخمول والكسل الدائم',
        'الأرق وصعوبة النوم',
        'النسيان وعدم التركيز',
        'تسارع ضربات القلب بدون سبب',
        'التعرق الليلي والكوابيس',
        'الانعزال الاجتماعي وكثرة البكاء',
        'ألم في المعدة والظهر بدون تشخيص طبي',
      ],
    ),
    _InstructionSection(
      title: 'خطوات العلاج الشرعي',
      items: [
        '1. التحصين اليومي بأذكار الصباح والمساء',
        '2. قراءة القرآن الكريم يومياً وخاصة سورة البقرة',
        '3. الرقية الشرعية على نفسك صباحاً ومساءً',
        '4. المحافظة على الصلوات في أوقاتها والسنن',
        '5. الإكثار من الدعاء والاستغفار',
        '6. الصدقة فهي تطفئ غضب الرب وتدفع البلاء',
        '7. الحجامة فهي من أنفع العلاجات بإذن الله',
        '8. صلاة الليل والدعاء في السجود',
        '9. الإكثار من قراءة سورة الإخلاص والمعوذتين',
        '10. تناول العسل الأسود وحبة البركة والزيت',
        '11. الاغتسال بماء مقروء عليه (ورق السدر)',
        '12. الصبر واليقين بأن الشفاء بيد الله وحده',
        '13. الاستمرار لمدة 21 يوماً على الأقل',
      ],
    ),
    _InstructionSection(
      title: 'الممارسات المحظورة',
      items: [
        'لا يجوز الذهاب للسحرة والمشعوذين والدجالين',
        'لا يجوز تعليق التمائم والطلاسم والحروز',
        'لا يجوز استخدام أسماء غير مفهومة أو طلاسم',
        'لا يجوز الرقية بالشرك أو الاستعانة بالجن',
        'لا يجوز كتابة آيات القرآن وبيعها مقابل المال',
        'لا يجوز للرجل رقية امرأة أجنبية بدون محرم',
        'لا يجوز الاعتقاد أن الرقية تؤثر بذاتها',
        'لا يجوز استخدام بخور أو طقوس غريبة',
        'لا يجوز إيذاء المريض بالضرب أو غيره',
        'لا يجوز طلب رقية عن بعد دون رؤية المريض',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('الرقية الشرعية'),
        backgroundColor: AppColors.navy,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textOnDarkMuted,
          labelStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'آيات الرقية'),
            Tab(text: 'أدعية الرقية'),
            Tab(text: 'طريقة الرقية'),
          ],
          onTap: (_) => ref.read(azkarAudioServiceProvider).stop(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVersesTab(),
          _buildDuasTab(),
          _buildInstructionsTab(),
        ],
      ),
    );
  }

  Widget _buildVersesTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: AppDimensions.lg,
        bottom: AppDimensions.xxl,
      ),
      itemCount: _verses.length,
      itemBuilder: (context, index) => _VerseCard(
        verse: _verses[index],
        index: index,
      ),
    );
  }

  Widget _buildDuasTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: AppDimensions.lg,
        bottom: AppDimensions.xxl,
      ),
      itemCount: _duas.length,
      itemBuilder: (context, index) => _DuaCard(
        dua: _duas[index],
        index: index,
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppDimensions.lg,
        right: AppDimensions.lg,
        top: AppDimensions.lg,
        bottom: AppDimensions.xxl,
      ),
      itemCount: _instructions.length,
      itemBuilder: (context, index) => _InstructionCard(
        section: _instructions[index],
        index: index,
      ),
    );
  }
}

class _VerseCard extends ConsumerStatefulWidget {
  final _RuqyahVerse verse;
  final int index;

  const _VerseCard({required this.verse, required this.index});

  @override
  ConsumerState<_VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends ConsumerState<_VerseCard> {
  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(azkarAudioServiceProvider);
    final isCurrentTrack = audio.isPlaying && audio.currentIndex == widget.index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isCurrentTrack ? AppColors.success : AppColors.goldMuted,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  '${widget.verse.surah} : ${widget.verse.ayahNumber}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final service = ref.read(azkarAudioServiceProvider);
                  if (isCurrentTrack) {
                    service.stop();
                  } else {
                    service.setQueue([widget.verse.arabic]);
                    service.playAt(0);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrentTrack
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.goldMuted,
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
          const SizedBox(height: AppDimensions.md),
          Text(
            widget.verse.arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textOnDark,
              fontFamily: 'Amiri',
              fontSize: 22,
              height: 2.0,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Center(
            child: Text(
              widget.verse.description,
              style: const TextStyle(
                color: AppColors.textOnDarkMuted,
                fontFamily: 'Amiri',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DuaCard extends ConsumerStatefulWidget {
  final _RuqyahDua dua;
  final int index;

  const _DuaCard({required this.dua, required this.index});

  @override
  ConsumerState<_DuaCard> createState() => _DuaCardState();
}

class _DuaCardState extends ConsumerState<_DuaCard> {
  bool _showTransliteration = false;

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(azkarAudioServiceProvider);
    final isCurrentTrack = audio.isPlaying && audio.currentIndex == widget.index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isCurrentTrack ? AppColors.success : AppColors.goldMuted,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.dua.arabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: AppColors.gold,
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
                    service.setQueue([widget.dua.arabic]);
                    service.playAt(0);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrentTrack
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.goldMuted,
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
            children: [
              Expanded(
                child: Text(
                  widget.dua.translation,
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          GestureDetector(
            onTap: () {
              setState(() => _showTransliteration = !_showTransliteration);
            },
            child: Row(
              children: [
                Icon(
                  _showTransliteration
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.goldLight,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'النطق',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.goldLight.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppDimensions.sm),
              child: Text(
                widget.dua.transliteration,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _showTransliteration
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.dua.source,
                style: const TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontFamily: 'Amiri',
                  fontSize: 11,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  'تكرار ${widget.dua.repeatCount}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final _InstructionSection section;
  final int index;

  const _InstructionCard({required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          if (section.title == 'علامات الحسد والعين' ||
              section.title == 'خطوات العلاج الشرعي' ||
              section.title == 'الممارسات المحظورة')
            ...List.generate(section.items.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: section.title == 'الممارسات المحظورة'
                            ? AppColors.error.withValues(alpha: 0.7)
                            : AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        section.items[i],
                        style: TextStyle(
                          color: section.title == 'الممارسات المحظورة'
                              ? AppColors.warning
                              : AppColors.textOnDark,
                          fontFamily: 'Amiri',
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            ...List.generate(section.items.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.goldMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          section.items[i],
                          style: const TextStyle(
                            color: AppColors.textOnDark,
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
