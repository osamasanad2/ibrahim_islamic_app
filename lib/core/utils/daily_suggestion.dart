class DailySuggestion {
  final String title;
  final String text;
  final String? icon;

  const DailySuggestion({required this.title, required this.text, this.icon});

  static DailySuggestion getForToday() {
    final weekday = DateTime.now().weekday;

    switch (weekday) {
      case 5:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '📖',
          text: 'اليوم الجمعة! لا تنسَ قراءة سورة الكهف، فإنها نور لك من الجمعة إلى الجمعة. وأكثر من الصلاة على النبي ﷺ',
        );
      case 1:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '🤲',
          text: 'اليوم الاثنين، لا تنسَ نية صيام هذا اليوم، فصيام الاثنين سنة عن النبي ﷺ',
        );
      case 4:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '🤲',
          text: 'اليوم الخميس، لا تنسَ نية صيام هذا اليوم، فصيام الخميس سنة عن النبي ﷺ',
        );
      case 6:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '📖',
          text: 'اليوم السبت، اغتنم هذا اليوم بقراءة القرآن والذكر والدعاء',
        );
      case 7:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '🌅',
          text: 'يوم الأحد المبارك، ابدأ أسبوعك بذكر الله وصلاة الفجر في وقتها',
        );
      case 2:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '💪',
          text: 'يوم الثلاثاء، لا تنسَ أن تتصدق ولو بشيء بسيط، فالصدقة تطفئ غضب الرب',
        );
      case 3:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '🌟',
          text: 'يوم الأربعاء، أكثِر من الاستغفار فإنه سبب للرزق والبركة',
        );
      default:
        return const DailySuggestion(
          title: 'تذكير اليوم',
          icon: '🍃',
          text: 'أكرمك الله اليوم، فاحمده على نعمه واسأله من فضله',
        );
    }
  }
}
