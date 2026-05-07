import 'package:flutter/material.dart';
// Import de tous les widgets de ce dossier
import 'package:code_initial/widgets/register/register_widgets.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Permet de scroller si le clavier réduit l'espace disponible
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
                    color: Color(0xFF1E293B), // Bleu très foncé (quasi noir)
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Label section nom & prénom
              const Text(
                "Nom & prénom :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),

              const SizedBox(height: 15),

              // Champ Nom
              const RegisterTextField(hint: "houda"),

              const SizedBox(height: 15),

              // Champ Prénom
              const RegisterTextField(hint: "Diara"),

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

              // Champ téléphone avec indicatif pays
              const PhoneInputField(),

              const SizedBox(height: 20),

              // Message d'info WhatsApp
              const WhatsAppInfoBox(),

              const SizedBox(height: 40),

              // Bouton "Envoyer le code"
              SubmitButton(
                onPressed: () {
                  // implémenter l'envoi du code de vérification
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}