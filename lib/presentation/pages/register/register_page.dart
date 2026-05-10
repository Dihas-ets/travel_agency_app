import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/navigation.dart';
// Import de tous les widgets de ce dossier
import 'package:code_initial/widgets/register/register_widgets.dart';

/// Page de création de compte.
///
/// Elle récupère le nom, le prénom et le téléphone de l'utilisateur avant
/// d'envoyer vers la page de vérification du code.
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

  /// Libère les contrôleurs pour éviter de garder des ressources inutiles.
  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  /// Valide les champs obligatoires avant d'envoyer l'utilisateur au code.
  void _envoyerCode() {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final telephone = _telephoneController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || telephone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs avant d'envoyer le code.",
          ),
          backgroundColor: Color(0xFFF80C0D),
        ),
      );
      return;
    }

    Get.toNamed(Routes.VERIFY_CODE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Permet de scroller si le clavier réduit l'espace disponible.
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Bouton retour + Logo STM
              const RegisterHeader(),

              const SizedBox(height: 20),

              // Titre centré "Créer un compte"
              const Center(
                child: Text(
                  "Créer un compte",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Champ Nom
              RegisterTextField(
                controller: _nomController,
                label: 'Nom',
                hint: "",
              ),

              const SizedBox(height: 20),

              // Champ Prénom
              RegisterTextField(
                controller: _prenomController,
                label: 'Prénom',
                hint: "",
              ),

              const SizedBox(height: 30),

              // Label section téléphone
              const Text(
                "Numéro de téléphone :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 15),

              // Champ téléphone avec sélection du pays par drapeau.
              PhoneInputField(controller: _telephoneController),

              const SizedBox(height: 20),

              // Message d'info WhatsApp
              const WhatsAppInfoBox(),

              const SizedBox(height: 40),

              // Lance la validation puis la navigation vers VerifyCodePage.
              SubmitButton(onPressed: _envoyerCode),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
