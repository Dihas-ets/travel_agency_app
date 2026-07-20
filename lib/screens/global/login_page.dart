import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_initial/data/local/auth_local_store.dart';
import 'package:code_initial/navigation.dart';
import 'package:code_initial/screens/global/widgets/login/login_widgets.dart';

/// Page de connexion.
///
/// Elle demande d'abord un numéro de téléphone.
/// Les clients inscrits continuent par OTP, l'equipe par mot de passe.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _telephoneController = TextEditingController();

  /// Libère les contrôleurs quand la page est retirée de l'arbre Flutter.
  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _continuer() async {
    final telephone = _telephoneController.text.trim();

    if (telephone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer votre numéro de téléphone."),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      return;
    }

    final isClient = await AuthLocalStore.isRegisteredClientPhone(telephone);
    if (isClient) {
      Get.toNamed(
        Routes.VERIFY_CODE,
        arguments: {'flow': 'login', 'phone': telephone},
      );
      return;
    }

    Get.toNamed(Routes.PERCEPTEUR_PASSWORD, arguments: {'phone': telephone});
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
            // Le scroll évite que les champs soient masqués par le clavier.
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Bouton retour + Logo Fofana
                const LoginHeader(),

                const SizedBox(height: 36),

                const Center(
                  child: Column(
                    children: [
                      Text(
                        "Se connecter",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Retrouvez vos trajets et vos services Fofana.",
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

                const SizedBox(height: 30),

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
                      // Libellé du champ téléphone.
                      const Text(
                        "Numéro de téléphone",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B4F2A),
                        ),
                      ),

                      const SizedBox(height: 10),

                      PhoneLoginField(controller: _telephoneController),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                LoginButton(
                  onPressed: _continuer,
                  label: 'Suivant',
                  icon: Icons.arrow_forward_rounded,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
