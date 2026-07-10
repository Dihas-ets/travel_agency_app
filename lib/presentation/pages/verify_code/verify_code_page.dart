import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:code_initial/data/local/auth_local_store.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/core/navigation/app_navigation.dart';

/// Page de vérification du code reçu par téléphone.
///
/// L'utilisateur saisit un code à 6 chiffres, un chiffre par case.
class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  // Un contrôleur par case pour lire chaque chiffre séparément.
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // Un FocusNode par case pour déplacer automatiquement le curseur.
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendRemaining = 90;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  /// Nettoie les contrôleurs et les focus nodes quand la page est détruite.
  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendRemaining = 90);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendRemaining = 0);
        return;
      }
      if (mounted) setState(() => _resendRemaining--);
    });
  }

  void _renvoyerCode() {
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code renvoyé.'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  /// Gère le passage automatique d'une case à l'autre.
  ///
  /// Quand un chiffre est saisi, le focus avance. Quand une case est vidée,
  /// le focus recule pour faciliter la correction.
  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _validerCode() async {
    final code = _controllers.map((controller) => controller.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le code à 6 chiffres.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      return;
    }

    final arguments = Get.arguments as Map<String, dynamic>?;
    final phone = arguments?['phone']?.toString() ?? '';
    final flow = arguments?['flow']?.toString() ?? '';
    if (phone.isNotEmpty && (flow == 'login' || flow == 'register')) {
      SessionStore.setCurrentClientPhone(phone);
    }
    if (flow == 'register') {
      final nom = arguments?['nom']?.toString() ?? '';
      final prenom = arguments?['prenom']?.toString() ?? '';
      if (nom.trim().isNotEmpty || prenom.trim().isNotEmpty) {
        SessionStore.setCurrentClientName(nom: nom, prenom: prenom);
      }
    } else if (phone.isNotEmpty && flow == 'login') {
      final fullName = await AuthLocalStore.getClientFullName(phone);
      if (fullName != null && fullName.isNotEmpty) {
        SessionStore.currentClientFullName = fullName;
      }
    }

    Get.offAllNamed(Routes.HOME);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF0B4F2A),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Image.asset(
                      'assets/images/logo_fofana_no_background.png',
                      height: 68,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.74),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B4F2A).withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF16A34A),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Vérification du code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0B4F2A),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Entrez le code reçu sur votre numéro pour confirmer votre compte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: Color(0xFF5F6B86),
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
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
                    children: [
                      const Text(
                        'Code de confirmation',
                        style: TextStyle(
                          color: Color(0xFF0B4F2A),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Génère les 6 cases de saisie du code au format ***-***.
                      FittedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(7, (position) {
                            if (position == 3) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0B4F2A),
                                  ),
                                ),
                              );
                            }

                            final index = position > 3
                                ? position - 1
                                : position;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: SizedBox(
                                width: 48,
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
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0B4F2A),
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.9,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 17,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: const Color(
                                          0xFF0B4F2A,
                                        ).withValues(alpha: 0.24),
                                        width: 1.4,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF16A34A),
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      _onCodeChanged(value, index),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 14),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _resendRemaining > 0
                            ? Text(
                                'Renvoyez le code dans $_resendRemaining seconde${_resendRemaining > 1 ? 's' : ''}',
                                key: const ValueKey('resend-countdown'),
                                style: const TextStyle(
                                  color: Color(0xFF7B849B),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : TextButton.icon(
                                key: const ValueKey('resend-button'),
                                onPressed: _renvoyerCode,
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                ),
                                label: const Text('Renvoyer'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF16A34A),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Bouton prévu pour valider le code une fois la logique backend ajoutée.
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _validerCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Valider',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
