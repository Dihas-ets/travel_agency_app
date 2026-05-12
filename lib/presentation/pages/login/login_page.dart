import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/navigation.dart';
import 'package:code_initial/widgets/login/login_widgets.dart';

/// Page de connexion.
///
/// Elle demande un numéro de téléphone et un mot de passe, puis vérifie que
/// les deux champs sont remplis avant de lancer la connexion.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Contrôleurs utilisés pour lire le contenu des deux champs du formulaire.
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Libère les contrôleurs quand la page est retirée de l'arbre Flutter.
  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Vérifie le formulaire avant de continuer.
  ///
  /// Si un champ est vide, l'utilisateur reste sur la page et reçoit un message.
  void _seConnecter() {
    final telephone = _telephoneController.text.trim();
    final password = _passwordController.text.trim();

    if (telephone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs avant de vous connecter.",
          ),
          backgroundColor: Color(0xFFF80C0D),
        ),
      );
      return;
    }

    Get.offNamed(Routes.HOME);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FBFF), Color(0xFFEFF4FF), Color(0xFFFFF5F5)],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Le scroll évite que les champs soient masqués par le clavier.
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Bouton retour + Logo TicBus
                const LoginHeader(),

                const SizedBox(height: 36),

                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Se connecter",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF060663),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Retrouvez vos trajets et vos services TicBus.",
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
                      // Libellé du champ téléphone.
                      const Text(
                        "Numéro de téléphone",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF060663),
                        ),
                      ),

                      const SizedBox(height: 10),

                      PhoneLoginField(controller: _telephoneController),

                      const SizedBox(height: 22),

                      // Libellé du champ mot de passe.
                      const Text(
                        "Mot de passe",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF060663),
                        ),
                      ),

                      const SizedBox(height: 10),

                      PasswordField(controller: _passwordController),

                      const SizedBox(height: 14),

                      // Lien prévu pour une future récupération de mot de passe.
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.FORGOT_PASSWORD);
                          },
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                              color: Color(0xFFF80C0D),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Déclenche la validation des champs avant toute tentative de connexion.
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
