import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/navigation.dart';
// Import de tous les widgets de ce dossier
import 'package:code_initial/auth/widgets/inscription_widgets.dart';

import 'package:code_initial/services/auth_service.dart';

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
 /// Valide les champs et communique avec le backend pour envoyer l'OTP
  Future<void> _envoyerCode() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final telephone = _telephoneController.text.trim();

    // 1. VALIDATION LOCALE : On vérifie si c'est vide
    if (nom.isEmpty || prenom.isEmpty || telephone.isEmpty) {
      Get.snackbar(
        "Champs requis",
        "Veuillez remplir tous les champs.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return; // On arrête tout ici si c'est vide
    }

    // 2. LOADER : On affiche un cercle de chargement
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A))),
      barrierDismissible: false,
    );

    try {
      // 3. APPEL BACKEND : On demande au serveur d'envoyer l'OTP
      final result = await AuthService().envoyerOtp(telephone);

      // On ferme le loader dès qu'on a la réponse
      Get.back();

      if (result['success']) {
        // 4. SUCCÈS : Le backend a validé et créé l'OTP
        await AuthLocalStore.saveClientPhone(telephone);
        await AuthLocalStore.saveClientProfile(
          phone: telephone,
          nom: nom,
          prenom: prenom,
        );

        Get.toNamed(
          Routes.VERIFY_CODE,
          arguments: {
            'flow': 'register',
            'phone': telephone,
            'nom': nom,
            'prenom': prenom,
          },
        );
      } else {
        // 5. ERREUR BACKEND : (ex: numéro déjà utilisé par un compte staff)
        Get.snackbar(
          "Attention",
          result['message'], // Le message vient directement de Laravel
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Fermer le loader
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
                        "Renseignez vos informations pour recevoir votre code.",
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
                      PhoneInputField(controller: _telephoneController),

                      const SizedBox(height: 18),

                      // Message d'info WhatsApp
                      const WhatsAppInfoBox(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Lance la validation puis la navigation vers VerifyCodePage.
                SubmitButton(onPressed: _envoyerCode),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
