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
      body:
      ValueListenableBuilder(
        valueListenable: localeController,
        builder: (context, currentLocale, _) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              RadioListTile<Locale>(
                title: Text (l10n.languageGerman),
                value: const Locale('de'),
                groupValue: currentLocale,
                onChanged: (locale) {
                  if (locale != null) localeController.setLocale(locale);
                },
              ),
              RadioListTile<Locale>(
                title: Text (l10n.languageEnglish),
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