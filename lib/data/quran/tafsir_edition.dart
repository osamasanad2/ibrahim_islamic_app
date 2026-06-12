enum TafsirEdition {
  muyassar(id: 16, name: 'التفسير الميسر'),
  tabari(id: 15, name: 'تفسير الطبري'),
  saadi(id: 91, name: 'تفسير السعدي'),
  ibnKathir(id: 14, name: 'تفسير ابن كثير');

  final int id;
  final String name;
  const TafsirEdition({required this.id, required this.name});
}
