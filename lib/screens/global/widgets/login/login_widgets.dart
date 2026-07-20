import 'package:flutter/material.dart';

import '../common/african_phone_field.dart';

/// Widgets réutilisables de la page de connexion.
///
/// Les séparer de LoginPage garde la page principale plus lisible.

/// Header de la page : bouton retour à gauche + logo Fofana centré
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bouton retour → revient à la page précédente
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0B4F2A)),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Logo Fofana chargé depuis les assets
        Image.asset('assets/images/logo_fofana_no_background.png', height: 68),

        // SizedBox vide de même largeur que l'IconButton (48px)
        // → permet de centrer visuellement le logo
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Champ de saisie du numéro de téléphone pour la connexion.
class PhoneLoginField extends StatelessWidget {
  /// Controleur fourni par LoginPage pour lire le numéro saisi.
  final TextEditingController? controller;

  const PhoneLoginField({super.key, this.controller});

  @override
  Widget build(BuildContext context) =>
      AfricanPhoneField(controller: controller);
}

/// Champ de mot de passe pour la connexion
class PasswordField extends StatefulWidget {
  /// Controleur fourni par LoginPage pour lire le mot de passe saisi.
  final TextEditingController? controller;

  const PasswordField({super.key, this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  // true : mot de passe masqué, false : mot de passe visible.
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0B4F2A).withValues(alpha: 0.24),
          width: 1.4,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: "Entrez votre mot de passe",
          border: InputBorder.none,
          hintStyle: const TextStyle(
            color: Color(0xFF7B849B),
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: GestureDetector(
            onTap: () {
              // Alterne entre l'affichage et le masquage du mot de passe.
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF0B4F2A),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton "Se connecter" pleine largeur
class LoginButton extends StatelessWidget {
  /// Action exécutée quand l'utilisateur appuie sur le bouton.
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.label = "Se connecter",
    this.icon = Icons.login_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16A34A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
