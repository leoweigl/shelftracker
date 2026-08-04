import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database/app_database.dart';
import 'database/book_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_shell.dart';
import 'services/locale_controller.dart';
import 'services/theme_controller.dart';
import 'services/display_mode_controller.dart';
import 'l10n/app_localizations.dart';

late final AppDatabase database;
late final BookRepository bookRepository;
final localeController = LocaleController();
final themeController = ThemeController();
final displayModeController = DisplayModeController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  bookRepository = BookRepository(database);

  await initializeDateFormatting('de_DE');
  await localeController.loadSavedLocale();
  await themeController.loadSavedTheme();
  await displayModeController.loadSavedMode();

  runApp(const ShelfTrackerApp());
}

class ShelfTrackerApp extends StatelessWidget {
  const ShelfTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return ValueListenableBuilder<FlexScheme>(
          valueListenable: themeController,
          builder: (context, scheme, _) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: displayModeController,
              builder: (context, mode, _) {
                final lightBase = FlexThemeData.light(scheme: scheme);
                final darkBase = FlexThemeData.dark(scheme: scheme);
                return MaterialApp(
                  locale: locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: lightBase.copyWith(
                    textTheme: GoogleFonts.sourceSans3TextTheme(
                      lightBase.textTheme,
                    ),
                  ),
                  darkTheme: darkBase.copyWith(
                    textTheme: GoogleFonts.sourceSans3TextTheme(
                      darkBase.textTheme,
                    ),
                  ),
                  themeMode: mode,
                  home: const MainShell(),
                );
              },
            );
          },
        );
      },
    );
  }
}