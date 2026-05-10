import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Page de vérification du code reçu par téléphone.
///
/// L'utilisateur saisit un code à 4 chiffres, un chiffre par case.
class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  // Un contrôleur par case pour lire chaque chiffre séparément.
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  // Un FocusNode par case pour déplacer automatiquement le curseur.
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  /// Nettoie les contrôleurs et les focus nodes quand la page est détruite.
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Gère le passage automatique d'une case à l'autre.
  ///
  /// Quand un chiffre est saisi, le focus avance. Quand une case est vidée,
  /// le focus recule pour faciliter la correction.
  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du code'),
        backgroundColor: const Color(0xFFF80C0D),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Entrez le code reçu sur votre numéro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 30),

            // Génère les 4 cases de saisie du code.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: index == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      // N'accepte que les chiffres et limite chaque case à 1 caractère.
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF060663),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onCodeChanged(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Bouton prévu pour valider le code une fois la logique backend ajoutée.
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Ici on peut ajouter la logique de validation du code.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF80C0D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
