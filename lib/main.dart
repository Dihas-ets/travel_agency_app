import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:code_initial/core/navigation/app_navigation.dart';
import 'package:code_initial/core/theme/app_colors.dart';

/// Point d'entrée de l'application.
///
/// On initialise Flutter avant de récupérer la route de départ, car certaines
/// dépendances futures peuvent avoir besoin des bindings Flutter.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

/// Prévu pour enregistrer les dépendances globales de l'application
/// lorsque le projet aura besoin de services, repositories ou contrôleurs.
void initializeDependencies() {}

/// Widget racine de l'application.
///
/// Il configure la navigation GetX, la langue par défaut et la police globale.
class Main extends StatelessWidget {
  /// Route affichée au lancement de l'application.
  final String initialRoute;

  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Fofana Voyage",
      // La première page est déterminée par Routes.initialRoute.
      initialRoute: initialRoute,
      // Toutes les routes GetX disponibles dans l'application.
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
      // Active les textes et composants Flutter localisés en français/anglais.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
      // L'interface de l'application est affichée en français par défaut.
      locale: const Locale('fr', 'FR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.darkGreen,
          tertiary: AppColors.accentRed,
          error: AppColors.accentRed,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        // Montserrat est appliquée à toute la typographie de l'application.
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
    );
  }
}
