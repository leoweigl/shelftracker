import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ValueListenableBuilder(
        valueListenable: localeController,
        builder: (context, currentLocale, _) {
          return Column(
            children: [
              RadioListTile<Locale>(
                title: Text (AppLocalizations.of(context)!.languageGerman),
                value: const Locale('de'),
                groupValue: currentLocale,
                onChanged: (locale) {
                  if (locale != null) localeController.setLocale(locale);
                },
              ),
              RadioListTile<Locale>(
                title: Text (AppLocalizations.of(context)!.languageEnglish),
                value: const Locale('en'),
                groupValue: currentLocale,
                onChanged: (locale) {
                  if (locale != null) localeController.setLocale(locale);
                },
              ),
            ],
          );
        }
      ),
    );
  }
}