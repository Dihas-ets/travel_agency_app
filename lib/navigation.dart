// ignore_for_file: constant_identifier_names

import 'package:code_initial/presentation/pages/welcome/welcome_page.dart';
import 'package:code_initial/presentation/pages/onboarding/onboarding_page.dart';
import 'package:code_initial/presentation/pages/register/register_page.dart';
import 'package:get/get.dart';


class Nav {
  static List<GetPage> routes = [

    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingPage(),
    ),

    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterPage(),
    ),

    GetPage(
      name: Routes.WELCOME,
      page: () => const WelcomePage(),
    ),
  ];
}


class Routes {
  static Future<String> get initialRoute async {

    return ONBOARDING;
  }

  static const REGISTER = '/register';

  static const ONBOARDING = '/onboarding';

  //Route de la page onboarding3
  static const WELCOME = '/welcomepage';

}