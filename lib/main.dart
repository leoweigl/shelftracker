import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
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

FontWeight _bolder(FontWeight? weight) {
  final index = FontWeight.values.indexOf(weight ?? FontWeight.w400);
  final newIndex = (index + 2).clamp(0, FontWeight.values.length - 1);
  return FontWeight.values[newIndex];
}

TextTheme _boldTextTheme(TextTheme theme) {
  TextStyle? bump(TextStyle? style) =>
      style?.copyWith(fontWeight: _bolder(style.fontWeight));
  return TextTheme(
    displayLarge: bump(theme.displayLarge),
    displayMedium: bump(theme.displayMedium),
    displaySmall: bump(theme.displaySmall),
    headlineLarge: bump(theme.headlineLarge),
    headlineMedium: bump(theme.headlineMedium),
    headlineSmall: bump(theme.headlineSmall),
    titleLarge: bump(theme.titleLarge),
    titleMedium: bump(theme.titleMedium),
    titleSmall: bump(theme.titleSmall),
    bodyLarge: bump(theme.bodyLarge),
    bodyMedium: bump(theme.bodyMedium),
    bodySmall: bump(theme.bodySmall),
    labelLarge: bump(theme.labelLarge),
    labelMedium: bump(theme.labelMedium),
    labelSmall: bump(theme.labelSmall),
  );
}

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
            final lightBase = FlexThemeData.light(scheme: scheme);
            final darkBase = FlexThemeData.dark(scheme: scheme);
            return MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: lightBase.copyWith(
                textTheme: _boldTextTheme(
                  GoogleFonts.ralewayTextTheme(lightBase.textTheme),
                ),
              ),
              darkTheme: darkBase.copyWith(
                textTheme: _boldTextTheme(
                  GoogleFonts.ralewayTextTheme(darkBase.textTheme),
                ),
              ),
              themeMode: ThemeMode.system,
              home: const MainShell(),
            );
          },
        );
      },
    );
  }
}