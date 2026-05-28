import 'package:code_initial/widgets/login/login_widgets.dart';
import 'package:flutter/material.dart';

/// Page de réinitialisation du mot de passe.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _telephoneController = TextEditingController();

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final telephone = _telephoneController.text.trim();

    if (telephone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code de réinitialisation envoyé au $telephone'),
        backgroundColor: const Color(0xFF0B4F2A),
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const LoginHeader(),
                const SizedBox(height: 34),
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        color: Color(0xFF16A34A),
                        size: 54,
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Mot de passe oublié',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Entrez votre numéro pour recevoir un code de réinitialisation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF5F6B86),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
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
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
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
                      const Text(
                        'Numéro de téléphone',
                        style: TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PhoneLoginField(controller: _telephoneController),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: _sendCode,
                          icon: const Icon(
                            Icons.sms_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                          label: const Text(
                            'Envoyer code',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
