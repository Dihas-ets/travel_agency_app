// ignore_for_file: deprecated_member_use

import 'package:code_initial/navigation.dart';
import 'package:flutter/material.dart';
// Import de la page Tarifs pour la navigation
import 'package:code_initial/presentation/pages/tarifs/tarifs_page.dart';
// Import de la page Register
import 'package:code_initial/presentation/pages/register/register_page.dart';
// Import des widgets
import 'package:code_initial/widgets/welcome/welcome_widgets.dart';
import 'package:get/get.dart';

/// Page d'accueil principale après l'onboarding.
///
/// Elle affiche l'image de fond, le logo STM, les accès rapides et les boutons
/// de création de compte / connexion.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Image de fond plein écran ────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_image.jpg',
              fit: BoxFit.cover, // L'image couvre tout l'écran
              errorBuilder: (_, __, ___) => Container(
                // Fallback si l'image est introuvable : dégradé bleu foncé
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D1B3E), Color(0xFF1A2A5E)],
                  ),
                ),
              ),
            ),
          ),

          // ── Overlay sombre par-dessus l'image ───────────────────
          // Permet de rendre le texte blanc lisible sur l'image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF060663).withOpacity(0.4),
                    const Color(0xFF1A2A5E).withOpacity(0.3),
                    const Color(0xFF0D1530).withOpacity(0.6),
                    const Color(0xFF060663).withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.3, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Contenu de la page ───────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Boutons de navigation en haut à gauche
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // Bouton "Tarifs" → navigue vers TarifsPage
                      NavButton(
                        icon: Icons.currency_exchange_rounded,
                        label: 'Tarifs',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TarifsPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 70),
                      // Bouton "Actualités" (action à implémenter)
                      NavButton(
                        icon: Icons.article_outlined,
                        label: 'Actualités',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // Pousse le logo vers le centre de l'écran
                const Spacer(),

                // Logo STM grand format depuis les assets
                Image.asset(
                  'assets/images/logo_stm_no_background.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),

                // Espace entre le logo et la zone de boutons en bas
                const SizedBox(height: 120),

                // ── Zone de boutons en bas ───────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      // Bouton "Créer votre compte" → navigue vers RegisterPage
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF80C0D),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(
                              0xFFF80C0D,
                            ).withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Créer votre compte',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Vous avez déjà un compte ?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Bouton "Se connecter" avec fond transparent bleu
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // Redirige vers la page de connexion.
                            Get.toNamed(Routes.LOGIN);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(
                              0xFF060663,
                            ).withOpacity(0.2),
                            side: const BorderSide(
                              color: Color(0xFF060663),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Modes de paiements possibles :',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Carte blanche avec les logos de paiement
                      Container(
                        width: 260,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Chaque logo est chargé depuis les assets
                            _buildPaymentLogo("assets/images/logo_carte.jpg"),
                            _buildPaymentLogo("assets/images/logo_mtn.jpg"),
                            _buildPaymentLogo("assets/images/logo_moov.png"),
                            _buildPaymentLogo("assets/images/logo_celtiis.png"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Lien "Autres modes de paiements"
                      GestureDetector(
                        onTap: () {
                          // Prévu pour afficher plus de moyens de paiement.
                        },
                        child: const Text(
                          'Autres modes de paiements',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit un logo de paiement à partir d'un chemin d'asset
  Widget _buildPaymentLogo(String path) {
    return Image.asset(
      path,
      height: 35,
      width: 60,
      fit: BoxFit.contain, // L'image garde ses proportions
    );
  }
}
