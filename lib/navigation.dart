//export 'package:code_initial/core/navigation/app_navigation.dart';

// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:code_initial/screens/global/welcome/welcome_page.dart';
import 'package:code_initial/screens/global/onboarding/onboarding_page.dart';
import 'package:code_initial/auth/inscription_page.dart';
import 'package:code_initial/auth/connexion_page.dart';
import 'package:code_initial/screens/percepteur/percepteur_password_page.dart';
import 'package:code_initial/auth/verification_code_page.dart';
import 'package:code_initial/screens/client/home/home_page.dart';
import 'package:code_initial/screens/percepteur/percepteur_home_page.dart';
import 'package:code_initial/screens/controleur/controleur_home_page.dart';
import 'package:code_initial/screens/controleur/controleur_password_page.dart';
import 'package:code_initial/auth/mot_de_passe_oublie_page.dart';
import 'package:code_initial/screens/client/colis/envois_effectues_page.dart';
import 'package:code_initial/screens/chauffeur/chauffeur_home_page.dart';
import 'package:code_initial/pages/payment_success_page.dart';
import 'package:code_initial/pages/payment_error_page.dart';
import 'package:code_initial/auth/stockage_auth_local.dart';
import 'package:code_initial/data/local/session_store.dart';
import 'package:code_initial/services/auth_service.dart';

/// Centralise toutes les pages accessibles avec GetX.
///
/// Cela évite d'éparpiller les chemins de navigation dans chaque écran.
class Nav {
  static List<GetPage> routes = [
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingPage()),

    GetPage(name: Routes.REGISTER, page: () => const RegisterPage()),

    GetPage(name: Routes.LOGIN, page: () => const LoginPage()),

    GetPage(
      name: Routes.PERCEPTEUR_PASSWORD,
      page: () => const PercepteurPasswordPage(),
    ),

    GetPage(
      name: Routes.CONTROLEUR_PASSWORD,
      page: () => const ControleurPasswordPage(),
    ),

    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
    ),

    GetPage(
      name: Routes.CHAUFFEUR_HOME,
      page: () => const ChauffeurHomePage(),
    ),

    GetPage(name: Routes.WELCOME, page: () => const WelcomePage()),

    GetPage(name: Routes.VERIFY_CODE, page: () => const VerifyCodePage()),

    GetPage(name: Routes.HOME, page: () => const HomePage()),

    GetPage(
      name: Routes.PERCEPTEUR_HOME,
      page: () => const PercepteurHomePage(),
    ),

    GetPage(
      name: Routes.CONTROLEUR_HOME,
      page: () => const ControleurHomePage(),
    ),
    GetPage(
      name: Routes.ENVOIS_EFFECTUES,
      page: () => const EnvoisEffectuesPage(),
    ),
    GetPage(
      name: '/payment-success',
      page: () => const PaymentSuccessPage(),
    ),

    GetPage(
      name: '/payment-error',
      page: () => const PaymentErrorPage(),
    ),
  ];
}

/// Noms des routes utilisées dans l'application.
///
/// Les constantes permettent d'éviter les fautes de frappe dans les appels
/// comme Get.toNamed(...) ou Get.offNamed(...).
class Routes {
  /// Route affichée au démarrage.
  ///
  /// Pour l'instant l'application commence toujours par l'onboarding.
  static Future<String> get initialRoute async {
    // Vérifie si un token valide existe localement.
    // Si oui, on restaure la session et on redirige vers HOME.
    // Si non, on démarre depuis ONBOARDING comme d'habitude.
    try {
      final token = await AuthLocalStore.getToken();
      if (token != null && token.trim().isNotEmpty) {
        final cachedUser = await AuthLocalStore.getCurrentUser();
        if (cachedUser != null) {
          SessionStore.setCurrentUser(cachedUser);
        }

        final freshUser = await AuthService().getProfile();
        if (freshUser != null) {
          final role = freshUser.role.trim().toLowerCase();
          if (role == 'percepteur') return PERCEPTEUR_HOME;
          if (role == 'controlleur' || role == 'controleur') return CONTROLEUR_HOME;
          if (role == 'chauffeur') return CHAUFFEUR_HOME;
          return HOME;
        }

        return HOME;
      }
    } catch (_) {
      // En cas d'erreur, on repart sur ONBOARDING
    }
    return ONBOARDING;
  }

  /// Page de création de compte.
  static const REGISTER = '/register';

  /// Page de connexion.
  static const LOGIN = '/login';

  /// Saisie du mot de passe percepteur après le numéro.
  static const PERCEPTEUR_PASSWORD = '/percepteur-password';

  /// Saisie du mot de passe controleur.
  static const CONTROLEUR_PASSWORD = '/controleur-password';

  /// Page de réinitialisation du mot de passe.
  static const FORGOT_PASSWORD = '/forgot-password';

  /// Parcours d'introduction affiché au premier lancement.
  static const ONBOARDING = '/onboarding';

  /// Page d'accueil après l'onboarding.
  static const WELCOME = '/welcomepage';

  /// Page de saisie du code de vérification.
  static const VERIFY_CODE = '/verify-code';

  /// Interface principale après connexion.
  static const HOME = '/home';

  /// Interface principale du percepteur.
  static const PERCEPTEUR_HOME = '/percepteur-home';

  /// Interface principale du controleur.
  static const CONTROLEUR_HOME = '/controleur-home';

  /// Liste des envois effectués.
  static const ENVOIS_EFFECTUES = '/envois-effectues';
  
  /// Interface principale du chauffeur.
  static const CHAUFFEUR_HOME = '/chauffeur-home';
}
