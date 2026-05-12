import 'package:flutter/material.dart';

/// Widgets réutilisables de la page de connexion.
///
/// Les séparer de LoginPage garde la page principale plus lisible.

/// Header de la page : bouton retour à gauche + logo TicBus centré
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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF060663)),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Logo TicBus chargé depuis les assets
        Image.asset('assets/images/logo_ticbus_no_background.png', height: 68),

        // SizedBox vide de même largeur que l'IconButton (48px)
        // → permet de centrer visuellement le logo
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Champ de saisie du numéro de téléphone pour la connexion.
/// Affiche un drapeau dynamique selon le pays sélectionné, l'indicatif pays, un séparateur vertical, puis le champ de saisie.
class PhoneLoginField extends StatefulWidget {
  /// Controller fourni par LoginPage pour lire le numéro saisi.
  final TextEditingController? controller;

  const PhoneLoginField({super.key, this.controller});

  @override
  State<PhoneLoginField> createState() => _PhoneLoginFieldState();
}

class _PhoneLoginFieldState extends State<PhoneLoginField> {
  // Pays disponibles pour le sélecteur de drapeau.
  // Le code est conservé dans la donnée même s'il n'est pas affiché.
  final Map<String, Map<String, String>> countries = {
    'Bénin': {'code': '00229', 'flag': '🇧🇯'},
    'Côte d\'Ivoire': {'code': '00225', 'flag': '🇨🇮'},
    'Togo': {'code': '00228', 'flag': '🇹🇬'},
    'Sénégal': {'code': '00221', 'flag': '🇸🇳'},
    'Mali': {'code': '00223', 'flag': '🇲🇱'},
    'Burkina Faso': {'code': '00226', 'flag': '🇧🇫'},
    'Niger': {'code': '00227', 'flag': '🇳🇪'},
    'Cameroun': {'code': '00237', 'flag': '🇨🇲'},
    'Ghana': {'code': '00233', 'flag': '🇬🇭'},
    'Nigeria': {'code': '00234', 'flag': '🇳🇬'},
  };

  // Pays sélectionné par défaut au chargement du champ.
  late String selectedCountry = 'Bénin';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF060663).withValues(alpha: 0.24),
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          // Bloc drapeau seul avec menu déroulant
          PopupMenuButton<String>(
            onSelected: (String country) {
              setState(() {
                selectedCountry = country;
              });
            },
            itemBuilder: (BuildContext context) {
              return countries.keys.map((String country) {
                return PopupMenuItem<String>(
                  value: country,
                  child: Row(
                    children: [
                      Text(
                        countries[country]!['flag']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(country),
                    ],
                  ),
                );
              }).toList();
            },
            child: Row(
              children: [
                // Emoji drapeau du pays sélectionné
                Text(
                  countries[selectedCountry]!['flag']!,
                  style: const TextStyle(fontSize: 20),
                ),
                // Flèche vers le bas pour suggérer un menu de sélection
                const Icon(Icons.arrow_drop_down, color: Color(0xFF060663)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Séparateur vertical entre le drapeau et le champ de saisie.
          Container(
            height: 30,
            width: 1,
            color: const Color(0xFF060663).withValues(alpha: 0.24),
          ),

          const SizedBox(width: 15),

          // Champ de saisie du numéro — prend tout l'espace restant
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFF7B849B),
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

/// Champ de mot de passe pour la connexion
class PasswordField extends StatefulWidget {
  /// Controller fourni par LoginPage pour lire le mot de passe saisi.
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
          color: const Color(0xFF060663).withValues(alpha: 0.24),
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
              color: const Color(0xFF060663),
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

  const LoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF80C0D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              "Se connecter",
              style: TextStyle(
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
