import 'package:flutter/material.dart';
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connexion en cours...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Le scroll évite que les champs soient masqués par le clavier.
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Bouton retour + Logo STM
              const LoginHeader(),

              const SizedBox(height: 40),

              // Titre centré "Se connecter"
              const Center(
                child: Text(
                  "Se connecter",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Libellé du champ téléphone.
              const Text(
                "Numéro de téléphone",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 10),

              PhoneLoginField(controller: _telephoneController),

              const SizedBox(height: 40),

              // Libellé du champ mot de passe.
              const Text(
                "Mot de passe",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 10),

              PasswordField(controller: _passwordController),

              const SizedBox(height: 15),

              // Lien prévu pour une future récupération de mot de passe.
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Implémenter la logique "mot de passe oublié"
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à implémenter'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(
                      color: Color(0xFFF80C0D),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Déclenche la validation des champs avant toute tentative de connexion.
              LoginButton(onPressed: _seConnecter),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
