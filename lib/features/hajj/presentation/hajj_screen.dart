import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class HajjScreen extends ConsumerStatefulWidget {
  const HajjScreen({super.key});

  @override
  ConsumerState<HajjScreen> createState() => _HajjScreenState();
}

class _HajjScreenState extends ConsumerState<HajjScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _hajjChecklists = {};
  final Map<String, bool> _umrahChecklists = {};
  final Map<String, bool> _bagChecklist = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    for (final step in _hajjSteps) {
      for (final item in step.checklist) {
        _hajjChecklists[item] = false;
      }
    }
    for (final step in _umrahSteps) {
      for (final item in step.checklist) {
        _umrahChecklists[item] = false;
      }
    }
    for (final item in _bagItems) {
      _bagChecklist[item] = false;
    }
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
        title: const Text(
          'دليل الحج والعمرة',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navy,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textOnDarkMuted,
          labelStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'الحج'),
            Tab(text: 'العمرة'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.work_outline, color: AppColors.gold),
            tooltip: 'حقيبة الحاج',
            onPressed: () => _showPilgrimBagSheet(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHajjTab(),
          _buildUmrahTab(),
        ],
      ),
    );
  }

  int get _hajjProgress {
    final total = _hajjSteps.fold<int>(0, (s, e) => s + e.checklist.length);
    final done = _hajjChecklists.values.where((v) => v).length;
    if (total == 0) return 0;
    return (done / total * 100).round();
  }

  int get _umrahProgress {
    final total = _umrahSteps.fold<int>(0, (s, e) => s + e.checklist.length);
    final done = _umrahChecklists.values.where((v) => v).length;
    if (total == 0) return 0;
    return (done / total * 100).round();
  }

  Widget _buildProgressBar(int progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.xs,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'التقدم:',
                style: TextStyle(
                  color: AppColors.textOnDarkMuted,
                  fontFamily: 'Amiri',
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppColors.navyLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHajjTab() {
    return Column(
      children: [
        _buildProgressBar(_hajjProgress),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.sm,
            ),
            itemCount: _hajjSteps.length,
            itemBuilder: (context, index) =>
                _buildStepCard(index, _hajjSteps[index], _hajjChecklists),
          ),
        ),
      ],
    );
  }

  Widget _buildUmrahTab() {
    return Column(
      children: [
        _buildProgressBar(_umrahProgress),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.sm,
            ),
            itemCount: _umrahSteps.length,
            itemBuilder: (context, index) =>
                _buildStepCard(index, _umrahSteps[index], _umrahChecklists),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(
    int index,
    HajjStepData step,
    Map<String, bool> checklist,
  ) {
    final isComplete = step.checklist.every((c) => checklist[c] == true);
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isComplete ? AppColors.gold : AppColors.goldMuted,
          width: isComplete ? 1.5 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.gold,
          ),
          unselectedWidgetColor: AppColors.textOnDarkMuted,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppDimensions.md,
            0,
            AppDimensions.md,
            AppDimensions.md,
          ),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: isComplete ? AppColors.gold : AppColors.navy,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isComplete ? AppColors.navy : AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          title: Text(
            step.title,
            style: TextStyle(
              color: isComplete ? AppColors.goldLight : AppColors.textOnDark,
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            step.subtitle,
            style: const TextStyle(
              color: AppColors.textOnDarkMuted,
              fontFamily: 'Amiri',
              fontSize: 14,
            ),
          ),
          trailing: isComplete
              ? const Icon(Icons.check_circle, color: AppColors.gold, size: 22)
              : const Icon(Icons.expand_more, color: AppColors.textOnDarkMuted),
          children: [
            _buildDescription(step.description),
            if (step.dua != null) _buildDuaSection(step.dua!),
            if (step.dua2 != null) _buildDuaSection(step.dua2!),
            if (step.ruling != null) _buildRulingSection(step.ruling!),
            _buildChecklistSection(step.checklist, checklist),
            const SizedBox(height: AppDimensions.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: AppColors.textOnDark,
          fontFamily: 'Amiri',
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildDuaSection(String dua) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الدعاء:',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            dua,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.goldLight,
              fontFamily: 'Amiri',
              fontSize: 20,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulingSection(String ruling) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.goldMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'أحكام مهمة:',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            ruling,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: AppColors.textOnDarkMuted,
              fontFamily: 'Amiri',
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(
    List<String> items,
    Map<String, bool> checklist,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.sm),
          child: Text(
            'قائمة الإجراءات:',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...items.map(
          (item) => CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(
              item,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: checklist[item] == true
                    ? AppColors.textOnDarkMuted
                    : AppColors.textOnDark,
                fontFamily: 'Amiri',
                fontSize: 15,
                decoration: checklist[item] == true
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            value: checklist[item],
            activeColor: AppColors.gold,
            checkColor: AppColors.navy,
            onChanged: (v) {
              setState(() {
                checklist[item] = v!;
              });
            },
          ),
        ),
      ],
    );
  }

  void _showPilgrimBagSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.goldMuted),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final bagDone = _bagChecklist.values.where((v) => v).length;
            final bagTotal = _bagChecklist.length;
            return Container(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.goldMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  const Row(
                    children: [
                      Icon(Icons.work, color: AppColors.gold, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'حقيبة الحاج',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  const Text(
                    'تذكرة بكل ما يحتاجه الحاج والمعتمر',
                    style: TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontFamily: 'Amiri',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    child: LinearProgressIndicator(
                      value: bagTotal > 0 ? bagDone / bagTotal : 0,
                      backgroundColor: AppColors.navy,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    '$bagDone / $bagTotal',
                    style: const TextStyle(
                      color: AppColors.textOnDarkMuted,
                      fontFamily: 'Amiri',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: _bagItems.map(
                        (item) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            item,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: _bagChecklist[item] == true
                                  ? AppColors.textOnDarkMuted
                                  : AppColors.textOnDark,
                              fontFamily: 'Amiri',
                              fontSize: 15,
                              decoration: _bagChecklist[item] == true
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          value: _bagChecklist[item],
                          activeColor: AppColors.gold,
                          checkColor: AppColors.navy,
                          onChanged: (v) {
                            setSheetState(() {
                              _bagChecklist[item] = v!;
                            });
                            setState(() {});
                          },
                        ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class HajjStepData {
  final String title;
  final String subtitle;
  final String description;
  final String? dua;
  final String? dua2;
  final String? ruling;
  final List<String> checklist;

  const HajjStepData({
    required this.title,
    required this.subtitle,
    required this.description,
    this.dua,
    this.dua2,
    this.ruling,
    this.checklist = const [],
  });
}

final List<HajjStepData> _hajjSteps = [
  const HajjStepData(
    title: 'الإحرام',
    subtitle: 'نية الدخول في النسك من الميقات',
    description:
        'الإحرام هو نية الدخول في الحج أو العمرة. يبدأ من الميقات المكاني المحدد، ويستحب الاغتسال والتطيب والتجرد من المخيط للرجال. أما المرأة فتحرم في ثيابها العادية.',
    dua: 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    ruling: 'واجبات الإحرام: النية، التلبية. محظورات الإحرام: الطيب، قص الشعر، قص الأظافر، عقد النكاح، الجماع، الصيد، لبس المخيط للرجال، تغطية الرأس للرجل، لبس القفازين والبرقع للمرأة.',
    checklist: [
      'الاغتسال والتطيب قبل الإحرام',
      'لبس ملابس الإحرام (للرجال: إزار ورداء)',
      'صلاة ركعتين سنة الإحرام',
      'عقد النية: "اللهم إني نويت الحج فيسره لي وتقبله مني"',
      'التلبية: لبيك اللهم لبيك...',
      'تجنب محظورات الإحرام',
    ],
  ),
  const HajjStepData(
    title: 'يوم التروية',
    subtitle: 'اليوم الثامن من ذي الحجة - الذهاب إلى منى',
    description:
        'يوم التروية هو اليوم الثامن من ذي الحجة. يخرج الحاج إلى منى ويبيت بها، ويصلي بها الظهر والعصر والمغرب والعشاء والفجر قصراً (رباعية ركعتين) دون جمع. يسمى يوم التروية لأن الناس كانوا يتروون فيه من الماء.',
    ruling:
        'السنة أن يبيت الحاج في منى يوم التروية. يصلي الظهر والعصر والعشاء قصراً بدون جمع. يجمع بين المغرب والعشاء جمع تأخير. يبيت ليلة عرفة بمنى.',
    checklist: [
      'الخروج إلى منى ضحى اليوم الثامن',
      'صلاة الظهر قصراً ركعتين في منى',
      'صلاة العصر قصراً ركعتين في منى',
      'صلاة المغرب ثلاثاً والعشاء ركعتين',
      'المبيت في منى ليلة عرفة',
      'الإكثار من التلبية والذكر والدعاء',
    ],
  ),
  const HajjStepData(
    title: 'يوم عرفة',
    subtitle: 'أعظم أركان الحج - اليوم التاسع',
    description:
        'الوقوف بعرفة هو الركن الأعظم للحج. يوم عرفة هو اليوم التاسع من ذي الحجة. يتوجه الحاج من منى إلى عرفة بعد طلوع الشمس. يقف الحاج في عرفة حتى غروب الشمس. أفضل دعاء يوم عرفة: "لا إله إلا الله وحده لا شريك له".',
    dua: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    dua2:
        'اللَّهُمَّ لَكَ الْحَمْدُ كَالَّذِي نَقُولُ وَخَيْرًا مِمَّا نَقُولُ، اللَّهُمَّ لَكَ صَلَاتِي وَنُسُكِي وَمَحْيَايَ وَمَمَاتِي، وَإِلَيْكَ مَآبِي، وَلَكَ رَبِّ تُرَاثِي',
    ruling:
        'الوقوف بعرفة ركن الحج الأعظم، من فاته الوقوف بعرفة فقد فاته الحج. يبدأ وقت الوقوف من زوال شمس يوم التاسع إلى طلوع فجر يوم العاشر. السنة أن يكون الحاج على طهارة مستقبلاً القبلة رافعاً يديه.',
    checklist: [
      'التوجه من منى إلى عرفة بعد طلوع الشمس',
      'النزول بنمرة والاغتسال قبل الزوال',
      'صلاة الظهر والعصر قصراً جمع تقديم بأذان واحد وإقامتين',
      'الوقوف بعرفة مستقبل القبلة',
      'الإكثار من الدعاء والتلبية والذكر',
      'البقاء بعرفة حتى غروب الشمس',
    ],
  ),
  const HajjStepData(
    title: 'مزدلفة',
    subtitle: 'المبيت وجمع الجمرات',
    description:
        'بعد غروب الشمس من يوم عرفة، يتوجه الحاج إلى مزدلفة بسكينة ووقار. يصلي بها المغرب والعشاء جمعاً قصراً (المغرب ثلاثاً والعشاء ركعتين). يبيت الحاج في مزدلفة ويصلي فيها الفجر، ثم يلتقط الجمرات (حصى رمي الجمار) سبع حصيات.',
    dua: 'اللَّهُمَّ اجْعَلْهَا حَجًّا مَبْرُورًا وَذَنْبًا مَغْفُورًا وَسَعْيًا مَشْكُورًا',
    ruling:
        'المبيت بمزدلفة واجب. من ترك المبيت فعليه دم. وقت المبيت من بعد منتصف الليل إلى طلوع الفجر. يستحب جمع سبع وأربعين حصاة لرمي الجمار في أيام التشريق.',
    checklist: [
      'التوجه من عرفة إلى مزدلفة بعد الغروب',
      'صلاة المغرب والعشاء جمعاً قصراً في مزدلفة',
      'المبيت في مزدلفة',
      'صلاة الفجر في مزدلفة',
      'جمع سبع حصيات (أو تسع وأربعين للثلاثة أيام)',
      'الإكثار من الدعاء والذكر في مزدلفة',
    ],
  ),
  const HajjStepData(
    title: 'يوم النحر',
    subtitle: 'يوم العيد - رمي جمرة العقبة والحلق والهدي',
    description:
        'يوم النحر هو اليوم العاشر من ذي الحجة، وهو أول أيام عيد الأضحى. يبدأ الحاج بالتوجه إلى منى لرمي جمرة العقبة الكبرى (سبع حصيات)، ثم يذبح الهدي إن كان متمتعاً أو قارناً، ثم يحلق أو يقصر (الحلق للرجال أفضل والتقصير للنساء)، ثم يطوف ويسعى.',
    dua: 'اللَّهُمَّ اجْعَلْهُ حَجًّا مَبْرُورًا وَذَنْبًا مَغْفُورًا وَعَمَلًا صَالِحًا مَقْبُولًا',
    ruling:
        'ترتيب أعمال يوم النحر: 1- رمي جمرة العقبة 2- ذبح الهدي 3- الحلق أو التقصير 4- طواف الإفاضة 5- السعي. من قدم بعضها على بعض فلا حرج. التحلل الأول يحصل برمي الجمرة والحلق.',
    checklist: [
      'التوجه إلى منى لرمي جمرة العقبة',
      'رمي جمرة العقبة بسبع حصيات متعاقبات مع التكبير',
      'ذبح الهدي (للمتمتع والقارن)',
      'الحلق للرجال أو التقصير',
      'الاغتسال ولبس الثياب (التحلل الأول)',
      'التوجه إلى مكة لطواف الإفاضة والسعي',
    ],
  ),
  const HajjStepData(
    title: 'أيام التشريق',
    subtitle: 'أيام الحادي عشر والثاني عشر والثالث عشر',
    description:
        'أيام التشريق هي أيام الحادي عشر والثاني عشر والثالث عشر من ذي الحجة. يبيت الحاج في منى هذه الأيام ويرمي الجمرات الثلاث: الجمرة الصغرى ثم الوسطى ثم الكبرى (جمرة العقبة). يرمي كل جمرة بسبع حصيات متعاقبات ويكبر مع كل حصاة.',
    dua: 'اللَّهُمَّ اجْعَلْهُ حَجًّا مَبْرُورًا وَذَنْبًا مَغْفُورًا، وَارْزُقْنَا الْعَوْدَةَ إِلَى بَيْتِكَ الْحَرَامِ',
    dua2:
        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    ruling:
        'المبيت بمنى ليالي التشريق واجب. من تركه فعليه دم. يجوز التعجل في يومين (بعد رمي الثاني عشر) لمن أراد. السنة أن يستقبل القبلة أثناء الرمي عدا جمرة العقبة.',
    checklist: [
      'المبيت في منى أيام التشريق',
      'رمي الجمرة الصغرى بسبع حصيات',
      'رمي الجمرة الوسطى بسبع حصيات',
      'رمي جمرة العقبة بسبع حصيات',
      'الإكثار من الذكر والدعاء والتكبير',
      'التوجه إلى مكة للوداع إن لم يتعجل',
    ],
  ),
  const HajjStepData(
    title: 'طواف الإفاضة والسعي',
    subtitle: 'طواف الزيارة والركنان',
    description:
        'طواف الإفاضة (طواف الزيارة) هو ركن من أركان الحج. يطوف الحاج بالكعبة سبعة أشواط تبدأ من الحجر الأسود. ثم يسعى بين الصفا والمروة سبعة أشواط. يكون طواف الإفاضة بعد الرجوع من منى في أيام العيد.',
    dua: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    dua2:
        'اللَّهُمَّ اجْعَلْ هَذَا حَجًّا مَبْرُورًا وَسَعْيًا مَشْكُورًا وَذَنْبًا مَغْفُورًا',
    ruling:
        'طواف الإفاضة ركن من أركان الحج لا يتم الحج إلا به. السعي بين الصفا والمروة ركن أيضاً. وقت طواف الإفاضة من بعد منتصف ليلة النحر إلى آخر أيام التشريق.',
    checklist: [
      'الطواف سبعة أشواط حول الكعبة',
      'استلام الحجر الأسود في بداية كل شوط',
      'صلاة ركعتين خلف مقام إبراهيم',
      'شرب من ماء زمزم',
      'السعي بين الصفا والمروة سبعة أشواط',
      'صعود الصفا والمروة والدعاء عليهما',
    ],
  ),
  const HajjStepData(
    title: 'طواف الوداع',
    subtitle: 'طواف الصدر - آخر مناسك الحج',
    description:
        'طواف الوداع هو آخر مناسك الحج. يطوف الحاج بالكعبة سبعة أشواط قبل مغادرته مكة المكرمة. هو واجب من واجبات الحج، يسقط عن الحائض والنفساء.',
    dua: 'اللَّهُمَّ لَا تَجْعَلْهُ آخِرَ الْعَهْدِ بِبَيْتِكَ الْحَرَامِ، اللَّهُمَّ ارْزُقْنِي الْعَوْدَةَ إِلَيْهِ آمِنًا مُعَافًى',
    ruling:
        'طواف الوداع واجب على الحاج عند مغادرة مكة. يسقط عن الحائض والنفساء. من تركه فعليه دم. السنة أن يشرب من ماء زمزم ويدعو عند باب الكعبة.',
    checklist: [
      'الطواف بالكعبة سبعة أشواط',
      'صلاة ركعتين خلف مقام إبراهيم',
      'شرب ماء زمزم',
      'الدعاء عند الملتزم بين الركن والباب',
      'توديع البيت الحرام',
      'الخروج من المسجد الحرام',
    ],
  ),
];

final List<HajjStepData> _umrahSteps = [
  const HajjStepData(
    title: 'الإحرام',
    subtitle: 'نية الدخول في العمرة من الميقات',
    description:
        'الإحرام للعمرة كالإحرام للحج. يبدأ من الميقات، ويستحب الاغتسال والتطيب، والتجرد من المخيط للرجال. تنعقد العمرة بالنية والتلبية.',
    dua: 'لَبَّيْكَ اللَّهُمَّ عُمْرَةً، لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ',
    ruling:
        'أركان العمرة: الإحرام، الطواف، السعي. واجبات العمرة: الإحرام من الميقات، الحلق أو التقصير. محظورات الإحرام هي نفس محظورات الحج.',
    checklist: [
      'الاغتسال والتطيب',
      'لبس ملابس الإحرام',
      'صلاة ركعتين سنة الإحرام',
      'عقد النية: "اللهم إني نويت العمرة فيسرها لي وتقبلها مني"',
      'التلبية: لبيك اللهم عمرة...',
      'تجنب محظورات الإحرام',
    ],
  ),
  const HajjStepData(
    title: 'الطواف',
    subtitle: 'سبعة أشواط حول الكعبة المشرفة',
    description:
        'الطواف هو الركن الثاني من أركان العمرة. يطوف المعتمر بالكعبة سبعة أشواط، يبدأ كل شوط من الحجر الأسود وينتهي عنده. والسنة أن يستلم الحجر الأسود في بداية كل شوط ويقبله إن استطاع.',
    dua: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِفَضْلِ طَوَافِي هَذَا أَنْ تَفْتَحَ لِي أَبْوَابَ رَحْمَتِكَ وَمَغْفِرَتِكَ، رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    dua2:
        'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    ruling:
        'يشترط للطواف: الطهارة من الحدثين، ستر العورة، أن يكون سبعة أشواط كاملة، أن يبدأ من الحجر الأسود، أن يكون داخل المسجد الحرام. الرمل (الإسراع) في الأشواط الثلاثة الأولى سنة للرجال.',
    checklist: [
      'الوضوء قبل الطواف',
      'البدء من الحجر الأسود مع التكبير',
      'الشوط الأول: الدعاء والذكر',
      'الشوط الثاني: الدعاء والذكر',
      'الشوط الثالث: الرمل للرجال',
      'الشوط الرابع والخامس والسادس والسابع',
      'صلاة ركعتين خلف مقام إبراهيم',
      'شرب ماء زمزم',
    ],
  ),
  const HajjStepData(
    title: 'السعي',
    subtitle: 'بين الصفا والمروة سبعة أشواط',
    description:
        'السعي بين الصفا والمروة هو الركن الثالث من أركان العمرة. يبدأ من الصفا وينتهي بالمروة، كل ذلك شوط واحد. سبعة أشواط: أربعة من الصفا إلى المروة وثلاثة من المروة إلى الصفا.',
    dua: 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ... رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    dua2:
        'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    ruling:
        'يشترط للسعي: أن يكون بعد طواف صحيح، أن يكون سبعة أشواط، أن يبدأ من الصفا وينتهي بالمروة. السنة أن يرقى على الصفا والمروة ويستقبل القبلة ويكبر ثلاثاً ويدعو.',
    checklist: [
      'بدء السعي من الصفا',
      'قراءة قوله تعالى: "إن الصفا والمروة من شعائر الله"',
      'الصعود على الصفا مستقبل القبلة والدعاء',
      'السعي إلى المروة (شوط ذهاب)',
      'السعي من المروة إلى الصفا (شوط إياب)',
      'الإسراع بين العلمين الأخضرين للرجال',
      'الصعود على المروة والدعاء',
      'إكمال سبعة أشواط',
    ],
  ),
  const HajjStepData(
    title: 'الحلق أو التقصير',
    subtitle: 'التحلل من الإحرام',
    description:
        'الحلق أو التقصير هو واجب من واجبات العمرة. الحلق أفضل للرجال (يحلق جميع شعر الرأس). التقصير للمرأة (تأخذ من طرف شعرها قدر أنملة). بهذا يتم التحلل من الإحرام وتنتهي العمرة.',
    ruling:
        'الحلق أفضل من التقصير للرجال لأن النبي صلى الله عليه وسلم دعا للمحلقين ثلاثاً وللمقصرين مرة. المرأة تقصر من كل ضفيرة قدر أنملة. بعد الحلق أو التقصير يحل للمعتمر كل شيء حرم عليه بالإحرام.',
    checklist: [
      'حلق جميع شعر الرأس (للرجال)',
      'أو تقصير الشعر (للرجال والنساء)',
      'لبس الثياب العادية',
      'الدعاء: الحمد لله الذي بلغني هذه النعمة',
    ],
  ),
];

const List<String> _bagItems = [
  'ملابس الإحرام (إزار ورداء للرجال)',
  'ملابس عادية مريحة للنساء',
  'حذاء مريح للطواف والسعي',
  'مظلة شمسية',
  'سجادة صلاة شخصية',
  'مصحف صغير أو تطبيق قرآن',
  'زجاجة مياه قابلة لإعادة الاستخدام',
  'حقيبة ظهر صغيرة',
  'أدوية شخصية ومستلزمات طبية',
  'مطهر ومناديل مبللة',
  'كريم واقي من الشمس',
  'مقص صغير (للحلق والتقصير)',
  'جواز السفر ونسخ احتياطية',
  'نقود وبطاقات بنكية',
  'هاتف محمول وشاحن',
  'وسادة صغيرة للسفر',
  'بطانية خفيفة',
  'وجبات خفيفة صحية',
  'مفكرة صغيرة لتدوين الأدعية',
  'ساعة يدوية',
];
