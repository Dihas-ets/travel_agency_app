import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:code_initial/features/parcel/presentation/pages/colis_attente_page.dart';
import 'package:code_initial/features/parcel/presentation/pages/parcel_pages.dart';
import 'package:code_initial/domain/models/expense_model.dart';
import 'package:code_initial/features/expense/data/expense_store.dart';
import 'package:code_initial/presentation/pages/expense/manual_expense_page.dart';
import 'package:code_initial/presentation/pages/expense/qr_scanner_page.dart';

part 'parts/models_and_stores.dart';
part 'parts/parcel_section.dart';
part 'parts/tab_content.dart';
part 'parts/expense_section.dart';
part 'parts/notifications_section.dart';
part 'parts/menu_profile_section.dart';
part 'parts/voyage_menu_section.dart';
part 'parts/assignments_section.dart';
part 'parts/ticket_validation_section.dart';
part 'parts/reservation_flow.dart';
part 'parts/history_news_section.dart';
part '../controller/controller_models.dart';
part '../controller/controller_home_page.dart';
part '../controller/controller_history_section.dart';
part '../controller/controller_profile_section.dart';

// Page racine de l espace percepteur: garde le shell Scaffold et delegue les sections aux fichiers part.

class CollectorHomePage extends StatefulWidget {
  const CollectorHomePage({super.key});

  @override
  State<CollectorHomePage> createState() => _CollectorHomePageState();
}

class _CollectorHomePageState extends State<CollectorHomePage> {
  int _currentIndex = 0;

  final List<_CollectorTab> _tabs = const [
    _CollectorTab('Voyage', Icons.directions_bus_filled_rounded),
    _CollectorTab('Colis', Icons.inventory_2_rounded),
    _CollectorTab('Depense', Icons.payments_rounded),
    _CollectorTab('Profil', Icons.person_rounded),
  ];

  void _openMainMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CollectorMainMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _tabs[_currentIndex];
    const navigationGreen = Color(0xFF16A34A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFFFFFFF), Color(0xFFFFF9F5)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _CollectorHeaderIconButton(
                        icon: Icons.menu_rounded,
                        onTap: _openMainMenu,
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_fofana_no_background.png',
                      height: 64,
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _CollectorNotificationIconButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Espace percepteur',
                  style: TextStyle(
                    color: Color(0xFF0B4F2A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTab.title,
                  style: const TextStyle(
                    color: Color(0xFF5F6B86),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(child: _CollectorTabContent(tab: currentTab)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: navigationGreen.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isActive = index == _currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? navigationGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isActive
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            )
                          : null,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: navigationGreen.withValues(alpha: 0.24),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF7B849B),
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            tab.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : const Color(0xFF7B849B),
                              fontSize: 10.8,
                              fontWeight: isActive
                                  ? FontWeight.w900
                                  : FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
