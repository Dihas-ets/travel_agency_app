import 'package:flutter/material.dart';
import 'package:code_initial/menus/menu_percepteur/menu_percepteur.dart';
import 'package:code_initial/menus/menu_percepteur/menu_profil_percepteur.dart';
import 'package:code_initial/screens/percepteur/parts/history_news_section.dart';
import 'package:code_initial/screens/percepteur/parts/assignments_section.dart';
import 'package:code_initial/screens/percepteur/parts/ticket_validation_section.dart';
import 'package:code_initial/screens/controleur/controleur_history_section.dart';

class ControleurVoyageContent extends StatelessWidget {
  const ControleurVoyageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 18),
      children: const [
        PercepteurNewsSection(),
        SizedBox(height: 22),
        ControleurVoyageMenu(),
      ],
    );
  }
}

class ControleurVoyageMenu extends StatelessWidget {
  const ControleurVoyageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Menu',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        MenuPercepteurButton(
          icon: Icons.assignment_turned_in_rounded,
          label: 'Affectation',
          isWide: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PercepteurAssignmentsPage(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MenuPercepteurButton(
                icon: Icons.login_rounded,
                label: 'Connexion',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PercepteurConnectionPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MenuPercepteurButton(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Validation',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TicketValidationPage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ControleurMainMenuSheet extends StatelessWidget {
  const ControleurMainMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.86,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FBFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4F2A).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Image.asset(
                'assets/images/logo_fofana_no_background.png',
                height: 62,
              ),
              const SizedBox(height: 14),
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF58648D),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Controleur Fofana',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0B4F2A),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 24),
              MenuPercepteurOptionTile(
                icon: Icons.account_circle_outlined,
                title: 'Profil',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              MenuPercepteurOptionTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Mes affectations',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const PercepteurAssignmentsPage(),
                    ),
                  );
                },
              ),
              MenuPercepteurOptionTile(
                icon: Icons.history_rounded,
                title: 'Tickets scannes',
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const ControleurHistoryPage(),
                    ),
                  );
                },
              ),
              MenuPercepteurOptionTile(
                icon: Icons.logout_rounded,
                title: 'Deconnexion',
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcomepage', (_) => false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
