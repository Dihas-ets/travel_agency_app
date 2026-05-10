// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import du fichier de routes GetX (navigation)
import 'package:code_initial/navigation.dart';

import 'package:code_initial/widgets/onboarding/onboarding_dot_indicator.dart';
import '../../../models/onboarding_data_model.dart';
import 'onboarding_slide.dart';

/// Parcours d'introduction affiché avant l'accueil.
///
/// Les trois slides présentent les avantages du service STM puis redirigent
/// vers la page d'accueil.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Contrôleur du PageView — permet de naviguer entre les slides par le code
  final PageController _pageController = PageController();

  // Index de la slide actuellement visible (commence à 0)
  int _currentPage = 0;

  // Liste des données pour chaque slide — const car elles ne changent jamais
  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Plus efficace',
      description:
          'Voyagez en toute tranquillité avec STM : ponctuel, fiable et accessible. '
          'Que ce soit pour vous ou vos colis, nous facilitons votre quotidien !',
      illustrationAsset: 'assets/images/onboarding2.png',
    ),
    OnboardingData(
      title: 'Plus assuré',
      description:
          'Plus sûr, plus serein avec STM. Sécurité, fiabilité et professionnalisme '
          'sont nos priorités pour vous offrir un transport en toute confiance.',
      illustrationAsset: 'assets/images/onboarding3.png',
    ),
    OnboardingData(
      title: 'Plus simple',
      description:
          'Avec STM, voyagez et expédiez vos colis en toute simplicité. '
          'Ponctualité, rapidité et service optimisé pour mieux vous satisfaire !',
      illustrationAsset: 'assets/images/onboarding1.png',
    ),
  ];

  /// Avance à la slide suivante.
  /// Si on est sur la dernière slide, redirige vers la page d'accueil.
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      // Pas encore à la fin → passe à la slide suivante avec une animation
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut, // Animation fluide
      );
    } else {
      // Dernière slide atteinte → navigation vers Welcome
      // Get.offNamed remplace la page courante (pas de retour arrière possible)
      Get.offNamed(Routes.WELCOME);
    }
  }

  /// Libère le PageController quand la page est détruite
  /// évite les fuites mémoire
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dégradé de fond : bleu clair en haut → beige rosé en bas
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDDEEF8), // Bleu clair
              Color(0xFFF5EBE0), // Beige rosé
            ],
          ),
        ),
        child: SafeArea(
          // SafeArea évite que le contenu passe derrière la barre de statut
          child: Column(
            children: [
              const SizedBox(height: 8),

              Center(
                child: Image.asset(
                  'assets/images/logo_stm_no_background.png',
                  height: 105,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 8),

              // ── Zone des slides (prend tout l'espace disponible) ──
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length, // 3 slides au total
                  // Mis à jour à chaque changement de slide (swipe ou bouton)
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    // setState déclenche un rebuild pour mettre à jour
                    // les points indicateurs
                  },

                  // Construit chaque slide à la demande (lazy loading)
                  itemBuilder: (context, index) {
                    return OnboardingSlide(
                      data: _pages[index],
                      slideIndex: index,
                    );
                  },
                ),
              ),

              // ── Indicateur de points (ex: ●○○, ○●○, ○○●) ─────────
              DotIndicator(
                count: _pages.length, // Nombre total de points
                currentIndex: _currentPage, // Point actif (bleu foncé)
                activeColor: const Color(0xFF060663),
                inactiveColor: const Color(0xFFD9D9D9),
              ),

              const SizedBox(height: 24),

              // ── Bouton rond "→" pour avancer ──────────────────────
              GestureDetector(
                onTap: _nextPage, // Appelle _nextPage au clic
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF060663),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF060663).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6), // Ombre portée vers le bas
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
