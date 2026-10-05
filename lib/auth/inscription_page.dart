import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/models/user_model.dart';
import 'package:code_initial/navigation.dart';
// Import de tous les widgets de ce dossier
import 'package:code_initial/auth/widgets/inscription_widgets.dart';

import 'package:code_initial/services/auth_service.dart';

/// Page de création de compte.
///
/// Elle crée directement un compte client protégé par mot de passe.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Contrôleurs du formulaire d'inscription.
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  String _numeroComplet = "";

  /// Libère les contrôleurs pour éviter de garder des ressources inutiles.
  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _inscrireClient() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final password = _passwordController.text;

    if (nom.isEmpty ||
        prenom.isEmpty ||
        _numeroComplet.isEmpty ||
        password.isEmpty ||
        _passwordConfirmationController.text.isEmpty) {
      Get.snackbar(
        "Champs requis",
        "Veuillez remplir tous les champs, y compris les mots de passe.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (password.length < 8) {
      Get.snackbar(
        'Mot de passe trop court',
        'Le mot de passe doit contenir au moins 8 caractères.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    if (password != _passwordConfirmationController.text) {
      Get.snackbar(
        'Confirmation incorrecte',
        'Les deux mots de passe ne correspondent pas.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A))),
      barrierDismissible: false,
    );

    try {
      final result = await AuthService().inscrireClient(
        nom: nom,
        prenom: prenom,
        telephone: _numeroComplet,
        password: password,
        passwordConfirmation: _passwordConfirmationController.text,
      );
      Get.back();

      if (result['success']) {
        final token = result['token']?.toString();
        final userData = result['user'];
        if (token == null ||
            token.isEmpty ||
            userData is! Map<String, dynamic>) {
          Get.snackbar('Erreur', 'Réponse d’inscription incomplète.');
          return;
        }
        await AuthLocalStore.saveToken(token);
        final user = UserModel.fromJson(userData);
        SessionStore.setCurrentUser(user);
        await AuthLocalStore.saveCurrentUser(user);
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Inscription impossible',
          result['message']?.toString() ?? 'Veuillez réessayer.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Erreur",
        "Connexion au serveur impossible.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
            // Permet de scroller si le clavier réduit l'espace disponible.
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Bouton retour + Logo Fofana
                const RegisterHeader(),

                const SizedBox(height: 18),

                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Créer un compte",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Renseignez vos informations et créez votre mot de passe.",
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

                const SizedBox(height: 26),

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
                      // Champ Nom
                      RegisterTextField(
                        controller: _nomController,
                        label: 'Nom',
                        hint: "",
                      ),

                      const SizedBox(height: 18),

                      // Champ Prénom
                      RegisterTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        hint: "",
                      ),

                      const SizedBox(height: 22),

                      // Label section téléphone
                      const Text(
                        "Numéro de téléphone",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Champ téléphone avec sélection du pays par drapeau.
                      PhoneInputField(
                        controller: _telephoneController,
                        onFullNumberChanged: (value) {
                          _numeroComplet = value; // ex: "+229XXXXXXXX"
                        },
                      ),

                      const SizedBox(height: 18),

                      RegisterPasswordField(controller: _passwordController),
                      const SizedBox(height: 16),
                      RegisterPasswordField(
                        controller: _passwordConfirmationController,
                        label: 'Confirmer le mot de passe',
                        hint: 'Saisissez-le à nouveau',
                      ),
                      const SizedBox(height: 18),
                      const WhatsAppInfoBox(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SubmitButton(
                  onPressed: _inscrireClient,
                  label: 'Créer mon compte',
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Get.offNamed(Routes.LOGIN),
                    child: const Text(
                      'Vous avez déjà un compte ? Se connecter',
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
