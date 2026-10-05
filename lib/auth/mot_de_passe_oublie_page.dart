import 'package:flutter/material.dart';
import 'package:code_initial/auth/widgets/connexion_widgets.dart';

/// Information de récupération, sans envoi de code OTP.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFF1FAF4), Color(0xFFEAF7EF)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const LoginHeader(),
                const SizedBox(height: 34),
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFF16A34A),
                        size: 54,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Mot de passe oublié',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'La réinitialisation par code n’est pas disponible. '
                        'Contactez un administrateur pour rétablir votre accès.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5F6B86),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        color: Color(0xFF16A34A),
                        size: 44,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
