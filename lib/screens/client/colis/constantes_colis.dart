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

const List<String> _parcelNatures = [
  'Alluminum',
  'Appareil électronique',
  'Armoire',
  'Bac',
  'Bache',
  'Bafana',
  'Balle de friperie',
  'Banc',
  'Batterie',
  'Bidon',
  'Boîte',
  'Bouteille',
  'Brouette',
  'Cable',
  'Caisse',
  'Caisse de poisson',
  'Canapé',
  'Cartable',
  'Carton',
  'Carton carreau',
  'Carton lait',
  'Carton moyen',
  'Carton ram',
  'Carton sucre',
  'Carton toner',
  'Casier',
  'Casier de bière',
  'Casier de jus',
  'Casier 2 jus',
  'Casier 3 jus',
  'Casier 4 jus',
  'Casier 5 jus',
  'Casier 6 jus',
  "Casier d'eau",
  'Chaise',
  'Chaussures',
  'Clé',
  'Climatiseur',
  'Colis',
  "Colis d'eau",
  'Colis jus',
  'Colis valise',
  'Complement douane',
  'Cop',
  'Couverture',
  'Cuisiniere',
  'Décoder',
  'Document',
  'Écran',
  'Enveloppe',
  'Fauteuil',
  'Fer',
  'Fil',
  'Four',
  'Frigo',
  'Frigo grand carton',
  'Imprimante',
  'Machine',
  'Machine à laver',
  'Malle',
  'Matelas',
  'Meuble',
  'Micro-onde',
  'Moto',
  'Ordinateur',
  'Pagne',
  'Panneau',
  'Pièce détachée',
  'Pièce moto',
  'Plastique',
  'Pneu',
  'Réchaud',
  'Sac',
  'Sac de ciment',
  'Sac de maïs',
  'Sac de riz',
  'Sac de voyage',
  'Sacoche',
  "Sachet d'eau",
  'Seau',
  'Tablette',
  'Table',
  'Téléphone',
  'Téléviseur',
  'Tonneau',
  'Valise',
  'Ventilateur',
  'Vélo',
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
