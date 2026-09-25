part of 'pages_colis.dart';

const Color _deepBlue = Color(0xFF0B4F2A);
const Color _logoRed = Color(0xFFE53935);
const Color _fofanaGreen = Color(0xFF16A34A);
const Color _pageBackground = Color(0xFFF8F9FE);

const List<String> _beninCities = [
  'Abomey',
  'Abomey-Calavi',
  'Adjohoun',
  'Allada',
  'Aplahoué',
  'Banikoara',
  'Bassila',
  'Bembèrèkè',
  'Bétérou',
  'Bohicon',
  'Bopa',
  'Cotonou',
  'Comè',
  'Covè',
  'Dassa-Zoumè',
  'Djougou',
  'Dogbo',
  'Glazoué',
  'Grand-Popo',
  'Kandi',
  'Kétou',
  'Kouandé',
  'Lokossa',
  'Malanville',
  'Natitingou',
  'Nikki',
  "N'Dali",
  'Ouidah',
  'Parakou',
  'Pobè',
  'Porto-Novo',
  'Sakété',
  'Savè',
  'Savalou',
  'Sèmè-Kpodji',
  'Tanguiéta',
  'Tchaourou',
];



class _ParcelDraft {
  String? nature;
  final TextEditingController valueController = TextEditingController();
  XFile? attachment;
  int quantity = 1;

  bool get isComplete {
    return nature != null &&
        nature!.trim().isNotEmpty &&
        valueController.text.trim().isNotEmpty &&
        attachment != null;
  }

  String get summary {
    final value = valueController.text.trim();
    return '${nature ?? ''} x$quantity - valeur ${value.isEmpty ? '--' : value} CFA';
  }

  void dispose() {
    valueController.dispose();
  }
}
