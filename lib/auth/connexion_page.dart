import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/navigation.dart';
import 'package:code_initial/auth/widgets/connexion_widgets.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/models/user_model.dart';

import 'package:code_initial/services/auth_service.dart';

/// Page de connexion.
///
/// Les clients et le personnel se connectent avec leur numéro et mot de passe.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _numeroComplet = "";

  /// Libère les contrôleurs quand la page est retirée de l'arbre Flutter.
  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continuer() async {
    // On vérifie toujours si c'est vide via le contrôleur
    if (_numeroComplet.trim().isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar(
        "Champs requis",
        "Veuillez entrer votre numéro et votre mot de passe.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A))),
      barrierDismissible: false,
    );

    try {
      final result = await AuthService().connexionMobile(
        telephone: _numeroComplet,
        password: _passwordController.text,
      );

      Get.back();

      if (result['success']) {
        final token = result['token']?.toString();
        final userData = result['user'];
        if (token == null ||
            token.isEmpty ||
            userData is! Map<String, dynamic>) {
          Get.snackbar('Erreur', 'Réponse de connexion incomplète.');
          return;
        }
        await AuthLocalStore.saveToken(token);
        final user = UserModel.fromJson(userData);
        SessionStore.setCurrentUser(user);
        await AuthLocalStore.saveCurrentUser(user);
        final role = user.role.trim().toLowerCase();
        if (role == 'percepteur') {
          Get.offAllNamed(Routes.PERCEPTEUR_HOME);
        } else if (role == 'controlleur' || role == 'controleur') {
          Get.offAllNamed(Routes.CONTROLEUR_HOME);
        } else if (role == 'chauffeur') {
          Get.offAllNamed(Routes.CHAUFFEUR_HOME);
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        Get.snackbar(
          "Connexion impossible",
          result['message']?.toString() ??
              "Ce numéro n'est associé à aucun compte. Veuillez vous inscrire.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar("Erreur", "Problème de connexion au serveur.");
    }
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

                // Bouton retour + Logo Fofana
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
                          color: Color(0xFF0B4F2A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Retrouvez vos trajets et vos services Fofana.",
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
                          color: Color(0xFF0B4F2A),
                        ),
                      ),

                      const SizedBox(height: 10),

                      PhoneLoginField(
                        controller: _telephoneController,
                        onFullNumberChanged: (value) {
                          _numeroComplet = value;
                        },
                      ),
                      const SizedBox(height: 18),
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

                LoginButton(
                  onPressed: _continuer,
                  label: 'Se connecter',
                  icon: Icons.arrow_forward_rounded,
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Get.offNamed(Routes.REGISTER),
                    child: const Text(
                      'Vous n’avez pas encore de compte ? S’inscrire',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
