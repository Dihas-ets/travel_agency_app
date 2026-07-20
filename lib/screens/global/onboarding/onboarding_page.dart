import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import du fichier de routes GetX (navigation)
import 'package:code_initial/navigation.dart';

import 'package:code_initial/screens/global/widgets/onboarding/onboarding_dot_indicator.dart';
import 'package:code_initial/models/onboarding_data_model.dart';
import 'onboarding_slide.dart';

/// Parcours d'introduction affiché avant l'accueil.
///
/// Les trois slides présentent les avantages du service Fofana puis redirigent
/// vers la page d'accueil.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Contrôleur du PageView — permet de naviguer entre les slides par le code
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;

  // Index de la slide actuellement visible (commence à 0)
  int _currentPage = 0;

  // Liste des données pour chaque slide — const car elles ne changent jamais
  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Plus efficace',
      description:
          'Voyagez en toute tranquillité avec Fofana : ponctuel, fiable et accessible. '
          'Que ce soit pour vous ou vos colis, nous facilitons votre quotidien !',
      illustrationAsset: 'assets/images/onboarding2.png',
    ),
    OnboardingData(
      title: 'Plus assuré',
      description:
          'Plus sûr, plus serein avec Fofana. Sécurité, fiabilité et professionnalisme '
          'sont nos priorités pour vous offrir un transport en toute confiance.',
      illustrationAsset: 'assets/images/onboarding3.png',
    ),
    OnboardingData(
      title: 'Plus simple',
      description:
          'Avec Fofana, voyagez et expédiez vos colis en toute simplicité. '
          'Ponctualité, rapidité et service optimisé pour mieux vous satisfaire !',
      illustrationAsset: 'assets/images/onboarding1.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      if (_currentPage >= _pages.length - 1) {
        timer.cancel();
        return;
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

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
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFF1FAF4), Color(0xFFEAF7EF)],
            stops: [0.0, 0.56, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: _SoftAccentCircle(
                size: 190,
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -85,
              child: _SoftAccentCircle(
                size: 220,
                color: const Color(0xFF0B4F2A).withValues(alpha: 0.1),
              ),
            ),
            SafeArea(
              // SafeArea évite que le contenu passe derrière la barre de statut
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo_fofana_no_background.png',
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        TextButton(
                          onPressed: () => Get.offNamed(Routes.WELCOME),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0B4F2A),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Passer'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Zone des slides (prend tout l'espace disponible) ──
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length, // 3 slides au total
                      // Mis à jour à chaque changement de slide (swipe ou bouton)
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        if (index == _pages.length - 1) {
                          _autoSlideTimer?.cancel();
                        }
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
                    activeColor: const Color(0xFF16A34A),
                    inactiveColor: const Color(0xFFE1E6F3),
                  ),

                  const SizedBox(height: 16),

                  // ── Bouton rond "→" pour avancer ──────────────────────
                  GestureDetector(
                    onTap: _nextPage, // Appelle _nextPage au clic
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: _currentPage == _pages.length - 1 ? 168 : 72,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B4F2A),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0B4F2A,
                            ).withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(
                              0,
                              8,
                            ), // Ombre portée vers le bas
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _currentPage == _pages.length - 1
                            ? const FittedBox(
                                key: ValueKey('start'),
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Commencer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              )
                            : const Icon(
                                key: ValueKey('next'),
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftAccentCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftAccentCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
