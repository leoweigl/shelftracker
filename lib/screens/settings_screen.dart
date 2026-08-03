import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final schemeOptions = <(FlexScheme, String)>[
      (FlexScheme.shadGray, l10n.themeGray),
      (FlexScheme.shadGreen, l10n.themeGreen),
      (FlexScheme.shadRed, l10n.themeCrimson),
      (FlexScheme.shadViolet, l10n.themeViolet),
      (FlexScheme.shadYellow, l10n.themeYellow),
      (FlexScheme.shadBlue, l10n.themeSapphire),
    ];

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
              _SettingsGroup(
                children: [
                  RadioListTile<Locale>(
                    secondary: const Text('🇩🇪', style: TextStyle(fontSize: 24)),
                    title: Text (l10n.languageGerman),
                    value: const Locale('de'),
                    groupValue: currentLocale,
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (locale) {
                      if (locale != null) localeController.setLocale(locale);
                    },
                  ),
                  RadioListTile<Locale>(
                    secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                    title: Text (l10n.languageEnglish),
                    value: const Locale('en'),
                    groupValue: currentLocale,
                    controlAffinity: ListTileControlAffinity.trailing,
                    onChanged: (locale) {
                      if (locale != null) localeController.setLocale(locale);
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.theme,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ValueListenableBuilder<FlexScheme>(
                valueListenable: themeController,
                builder: (context, currentScheme, _) {
                  return _SettingsGroup(
                    children: [
                      for (final (scheme, label) in schemeOptions)
                        _ThemeListRow(
                          scheme: scheme,
                          label: label,
                          selected: scheme == currentScheme,
                          onTap: () => themeController.setScheme(scheme),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }
      ),
    );
  }
}

/// Wraps a group of settings rows in a single rounded, bordered container,
/// with dividers between rows instead of each row having its own border.
class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ThemeListRow extends StatelessWidget {
  final FlexScheme scheme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeListRow({
    required this.scheme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = FlexColor.schemes[scheme]!;
    final swatch = isDark ? data.dark : data.light;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: swatch.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black26,
            width: 1,
          ),
        ),
      ),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : const Icon(Icons.circle_outlined),
    );
  }
}
