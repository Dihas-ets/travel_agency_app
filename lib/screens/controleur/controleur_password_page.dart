import 'package:code_initial/navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/auth/widgets/connexion_widgets.dart';

/// Connexion de l'espace controleur.
///
/// Le controleur utilise un mot de passe distinct du percepteur afin d'ouvrir
/// son interface de controle des tickets scannes.
class ControleurPasswordPage extends StatefulWidget {
  const ControleurPasswordPage({super.key});

  @override
  State<ControleurPasswordPage> createState() => _ControleurPasswordPageState();
}

class _ControleurPasswordPageState extends State<ControleurPasswordPage> {
  static const String _defaultControllerPassword = '0000';

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _seConnecter() {
    if (_passwordController.text.trim() != _defaultControllerPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe controleur incorrect.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      return;
    }

    Get.offAllNamed(Routes.CONTROLEUR_HOME);
  }

  @override
  Widget build(BuildContext context) {
    final phone = (Get.arguments as Map?)?['phone']?.toString() ?? '';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const LoginHeader(),
                const SizedBox(height: 36),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'Connexion controleur',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Entrez le mot de passe controleur pour acceder aux validations.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5F6B86),
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
                    color: Colors.white.withValues(alpha: 0.64),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.86),
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
                      if (phone.isNotEmpty) ...[
                        const Text(
                          'Numero controleur',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5F6B86),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          phone,
                          style: const TextStyle(
                            color: Color(0xFF0B4F2A),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                      const Text(
                        'Mot de passe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PasswordField(controller: _passwordController),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                LoginButton(onPressed: _seConnecter),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
