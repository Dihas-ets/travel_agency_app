import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'navigation.dart';
import 'utils/app_colors.dart';

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
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.darkGreen,
          surface: Colors.white,
          surfaceContainerHighest: AppColors.surfaceSoft,
          outline: AppColors.border,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          labelStyle: const TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w700,
          ),
          hintStyle: TextStyle(
            color: AppColors.mutedText.withValues(alpha: 0.72),
            fontWeight: FontWeight.w600,
          ),
          prefixIconColor: AppColors.primary,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE11D48)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size.fromHeight(52),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkGreen,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.darkGreen,
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
