import 'package:code_initial/navigation.dart';
import 'package:code_initial/presentation/pages/register/register_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Page d'accueil principale après l'onboarding.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const Color _fofanaGreen = Color(0xFF16A34A);
  static const Color _deepBlue = Color(0xFF0B4F2A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Activez votre localisation pour voir les agences Fofana proches.',
          ),
          action: SnackBarAction(
            label: 'Activer',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de localisation à connecter'),
                ),
              );
            },
          ),
          backgroundColor: const Color(0xFF0B4F2A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_image.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF111827), Color(0xFF0B4F2A)],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.2)),
          ),
          Positioned.fill(child: _WelcomeOverlay()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 690;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.86),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo_fofana_no_background.png',
                                height: compact ? 68 : 82,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 18 : 28),
                          const Text(
                            'Voyagez simplement avec Fofana',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              shadows: [
                                Shadow(
                                  color: Color(0xAA060663),
                                  blurRadius: 20,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Réservez vos voyages, suivez vos colis et retrouvez vos agences Fofana proches de vous.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.94),
                              fontSize: 15.5,
                              height: 1.42,
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(
                                  color: Color(0xAA060663),
                                  blurRadius: 14,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 18),
                          const Spacer(),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(top: compact ? 28 : 42),
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.42),
                                  Colors.white.withValues(alpha: 0.18),
                                  _deepBlue.withValues(alpha: 0.38),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Commencer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 58,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Créer votre compte'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _fofanaGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Get.toNamed(Routes.LOGIN);
                                    },
                                    icon: const Icon(
                                      Icons.login_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Se connecter'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.28,
                                        ),
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'Moyens de paiement',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.white.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildPaymentLogo(
                                      'assets/images/logo_carte.png',
                                    ),
                                    _buildPaymentLogo(
                                      'assets/images/logo_mtn.png',
                                    ),
                                    _buildPaymentLogo(
                                      'assets/images/logo_moov.png',
                                    ),
                                    _buildPaymentLogo(
                                      'assets/images/logo_celtiis.png',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLogo(String path) {
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: _fofanaGreen.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.credit_card_rounded, color: Color(0xFF0B4F2A)),
        ),
      ),
    );
  }
}

class _WelcomeOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            const Color(0xFF0B4F2A).withValues(alpha: 0.16),
            const Color(0xFF16A34A).withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.68),
          ],
          stops: const [0.0, 0.32, 0.64, 1.0],
        ),
      ),
    );
  }
}
