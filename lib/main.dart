import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'database/book_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/dashboard_screen.dart';
import 'services/locale_controller.dart';
import 'l10n/app_localizations.dart';

late final AppDatabase database;
late final BookRepository bookRepository;
final localeController = LocaleController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  bookRepository = BookRepository(database);

  await initializeDateFormatting('de_DE');
  await localeController.loadSavedLocale();

  runApp(const ShelfTrackerApp());
}

class ShelfTrackerApp extends StatelessWidget {
  const ShelfTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: const DashboardScreen(),
        );
      },
    );
  }
}