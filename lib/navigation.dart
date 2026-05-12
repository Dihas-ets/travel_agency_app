// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:code_initial/presentation/pages/welcome/welcome_page.dart';
import 'package:code_initial/presentation/pages/onboarding/onboarding_page.dart';
import 'package:code_initial/presentation/pages/register/register_page.dart';
import 'package:code_initial/presentation/pages/login/login_page.dart';
import 'package:code_initial/presentation/pages/verify_code/verify_code_page.dart';
import 'package:code_initial/presentation/pages/home/home_page.dart';
import 'package:code_initial/presentation/pages/forgot_password/forgot_password_page.dart';

/// Centralise toutes les pages accessibles avec GetX.
///
/// Cela évite d'éparpiller les chemins de navigation dans chaque écran.
class Nav {
  static List<GetPage> routes = [
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingPage()),

    GetPage(name: Routes.REGISTER, page: () => const RegisterPage()),

    GetPage(name: Routes.LOGIN, page: () => const LoginPage()),

    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
    ),

    GetPage(name: Routes.WELCOME, page: () => const WelcomePage()),

    GetPage(name: Routes.VERIFY_CODE, page: () => const VerifyCodePage()),

    GetPage(name: Routes.HOME, page: () => const HomePage()),
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
    return ONBOARDING;
  }

  /// Page de création de compte.
  static const REGISTER = '/register';

  /// Page de connexion.
  static const LOGIN = '/login';

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
}
