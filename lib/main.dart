import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'database/app_database.dart';
import 'database/book_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_shell.dart';
import 'services/locale_controller.dart';
import 'services/theme_controller.dart';
import 'l10n/app_localizations.dart';

late final AppDatabase database;
late final BookRepository bookRepository;
final localeController = LocaleController();
final themeController = ThemeController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  bookRepository = BookRepository(database);

  await initializeDateFormatting('de_DE');
  await localeController.loadSavedLocale();
  await themeController.loadSavedTheme();

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
            return MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: FlexThemeData.light(scheme: scheme),
              darkTheme: FlexThemeData.dark(scheme: scheme),
              themeMode: ThemeMode.system,
              home: const MainShell(),
            );
          },
        );
      },
    );
  }
}