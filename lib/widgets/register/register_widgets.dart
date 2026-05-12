import 'package:flutter/material.dart';

/// Fichier contenant tous les widgets utilisés dans RegisterPage.
/// Les regrouper ici permet de garder register_page.dart lisible.

/// Header de la page : bouton retour à gauche + logo TicBus centré.
class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bouton retour : revient à la page précédente.
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

        // Logo TicBus chargé depuis les assets.
        Image.asset('assets/images/logo_ticbus_no_background.png', height: 68),

        // Même largeur que l'IconButton pour garder le logo centré.
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Champ texte générique utilisé pour le nom et le prénom.
/// [hint] : texte indicatif dans le champ
/// [label] : texte affiché au-dessus ou en dessous du champ
class RegisterTextField extends StatelessWidget {
  /// Controller fourni par RegisterPage pour lire la valeur saisie.
  final TextEditingController? controller;

  /// Texte indicatif dans le champ. Peut rester vide.
  final String hint;

  final String label; // étiquette affichée autour du champ

  /// true : le label est au-dessus du champ, false : il est en dessous.
  final bool labelAbove;

  const RegisterTextField({
    super.key,
    this.controller,
    required this.hint,
    required this.label,
    this.labelAbove = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelAbove) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF060663),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Champ texte
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF060663).withValues(alpha: 0.24),
              width: 1.4,
            ),
          ),
          child: TextField(
            controller: controller,
            // Désactive les suggestions pour éviter des propositions inutiles
            // sur des champs courts comme nom/prénom.
            autofillHints: null,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: hint.isNotEmpty
                ? InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      color: Color(0xFF7B849B),
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: InputBorder.none,
                  ),
          ),
        ),

        if (!labelAbove) ...[
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ],
    );
  }
}

/// Champ de saisie du numéro de téléphone.
/// Affiche un drapeau dynamique selon le pays sélectionné, puis le champ.
class PhoneInputField extends StatefulWidget {
  /// Controller fourni par RegisterPage pour lire le numéro saisi.
  final TextEditingController? controller;

  const PhoneInputField({super.key, this.controller});

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  // Pays disponibles pour le sélecteur de drapeau.
  // Les indicatifs sont gardés dans la donnée pour une future utilisation.
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

  // Pays affiché par défaut au chargement de la page.
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

/// Champ de mot de passe utilisé pendant l'inscription.
class RegisterPasswordField extends StatefulWidget {
  /// Controller fourni par RegisterPage pour lire le mot de passe saisi.
  final TextEditingController? controller;

  const RegisterPasswordField({super.key, this.controller});

  @override
  State<RegisterPasswordField> createState() => _RegisterPasswordFieldState();
}

class _RegisterPasswordFieldState extends State<RegisterPasswordField> {
  // true : mot de passe masqué, false : mot de passe visible.
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mot de passe",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF060663),
          ),
        ),
        const SizedBox(height: 6),
        Container(
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
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
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
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF060663),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Boîte d'information qui conseille d'utiliser un numéro WhatsApp.
class WhatsAppInfoBox extends StatelessWidget {
  const WhatsAppInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF80C0D).withValues(alpha: 0.28),
          width: 1.3,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Color(0xFFF80C0D), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "De préférence votre numéro WhatsApp",
              style: TextStyle(
                color: Color(0xFF060663),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton rouge "Envoyer le code" pleine largeur.
class SubmitButton extends StatelessWidget {
  /// Action exécutée après validation du formulaire par RegisterPage.
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.onPressed});

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
            Icon(Icons.sms_rounded, color: Colors.white, size: 21),
            SizedBox(width: 10),
            Text(
              "Envoyer le code",
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
