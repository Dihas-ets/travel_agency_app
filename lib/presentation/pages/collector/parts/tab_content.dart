import 'package:flutter/material.dart';
import 'package:code_initial/presentation/pages/collector/parts/voyage_menu_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/parcel_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/expense_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/menu_profile_section.dart';
import 'package:code_initial/presentation/pages/collector/parts/history_news_section.dart';

// Aiguilleur des onglets principaux de l espace percepteur.

class CollectorTabContent extends StatelessWidget {
  final CollectorTab tab;

  const CollectorTabContent({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    if (tab.title == 'Voyage') {
      return const CollectorVoyageContent();
    }
    if (tab.title == 'Colis') {
      return const CollectorColisContent();
    }
    if (tab.title == 'Depense') {
      return const CollectorDepenseContent();
    }
    if (tab.title == 'Profil') {
      return const CollectorProfileTabContent();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tab.icon, color: const Color(0xFF16A34A), size: 34),
          const SizedBox(height: 14),
          Text(
            tab.title,
            style: const TextStyle(
              color: Color(0xFF0B4F2A),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _descriptionFor(tab.title),
            style: const TextStyle(
              color: Color(0xFF5F6B86),
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _descriptionFor(String title) {
    switch (title) {
      case 'Voyage':
        return 'Gestion des voyages et des opérations liées aux tickets.';
      case 'Colis':
        return 'Suivi et traitement des colis confiés au percepteur.';
      case 'Depense':
        return 'Consultation et saisie des dépenses de service.';
      default:
        return 'Informations et paramètres du compte percepteur.';
    }
  }
}
