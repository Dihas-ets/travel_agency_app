import 'package:flutter/material.dart';

/// Fichier contenant tous les widgets utilisés dans RegisterPage.
/// Les regrouper ici permet de garder register_page.dart lisible.


/// Header de la page : bouton retour à gauche + logo STM centré
class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Bouton retour → revient à la page précédente
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

        // Logo STM chargé depuis les assets
        Image.asset(
          'assets/images/logo_stm_no_background.png',
          height: 60,
        ),

        // SizedBox vide de même largeur que l'IconButton (48px)
        // → permet de centrer visuellement le logo
        const SizedBox(width: 48),
      ],
    );
  }
}


/// Champ texte générique utilisé pour le Nom et le Prénom.
/// Prend un [hint] comme texte indicatif dans le champ.
class RegisterTextField extends StatelessWidget {
  final String hint; // Texte affiché quand le champ est vide

  const RegisterTextField({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Bordure grise subtile autour du champ
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        decoration: InputDecoration(
          // Espacement interne du champ
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: hint,
          border: InputBorder.none, // Supprime la bordure par défaut de TextField
          hintStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}


/// Champ de saisie du numéro de téléphone.
/// Affiche un drapeau 🇧🇯, l'indicatif pays "00229", un séparateur vertical, puis le champ de saisie.
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [

          // Icône téléphone à gauche
          const Icon(Icons.phone, color: Colors.grey, size: 20),
          const SizedBox(width: 10),

          // Bloc drapeau + indicatif pays
          Row(
            children: [
              // Emoji drapeau du Bénin
              const Text("🇧🇯", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 5),
              // Indicatif téléphonique du Bénin
              Text(
                "00229",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              // Flèche vers le bas pour suggérer un menu de sélection
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),

          const SizedBox(width: 10),

          // Séparateur vertical entre l'indicatif et le champ de saisie
          Container(
            height: 30,
            width: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(width: 15),

          // Champ de saisie du numéro — prend tout l'espace restant
          const Expanded(
            child: TextField(
              keyboardType: TextInputType.phone, // Clavier numérique
              decoration: InputDecoration(
                hintText: "67 30 40 30",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}


/// Boîte d'information bleue qui conseille d'utiliser un numéro WhatsApp.
class WhatsAppInfoBox extends StatelessWidget {
  const WhatsAppInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE), // Bleu clair (style info)
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          // Icône info bleue
          Icon(Icons.info, color: Color(0xFF0EA5E9), size: 20),
          SizedBox(width: 10),
          // Message d'information — Expanded pour éviter l'overflow
          Expanded(
            child: Text(
              "De préférence le numéro WhatsApp",
              style: TextStyle(
                color: Color(0xFF0EA5E9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Bouton orange "Envoyer le code" pleine largeur.
/// [onPressed] : action déclenchée au clic (à implémenter)
class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed; // Fonction appelée quand le bouton est pressé

  const SubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Prend toute la largeur disponible
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8135), // Orange STM
          elevation: 0, // Pas d'ombre sous le bouton
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Envoyer le code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}