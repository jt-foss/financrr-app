import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/routing/ui/navbar_shell.dart';
import 'package:financrr_frontend/shared/ui/custom_replacements/custom_text_field.dart';
import 'package:financrr_frontend/shared/ui/custom_replacements/custom_card.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../providers/l10n.provider.dart';
import '../providers/theme.provider.dart';
import 'settings_page.dart';

class L10nSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'language');

  const L10nSettingsPage({super.key});

  @override
  ConsumerState<L10nSettingsPage> createState() => _L10nSettingsPageState();
}

class _L10nSettingsPageState extends ConsumerState<L10nSettingsPage> {
  late final TextEditingController _decimalSeparatorController;
  late final TextEditingController _thousandSeparatorController;
  late final TextEditingController _dateTimeFormatController;

  @override
  void initState() {
    super.initState();
    var l10n = ref.read(l10nProvider);
    _decimalSeparatorController = TextEditingController(text: l10n.decimalSeparator);
    _thousandSeparatorController = TextEditingController(text: l10n.thousandSeparator);
    _dateTimeFormatController = TextEditingController(text: l10n.dateFormat.pattern);
  }

  @override
  void dispose() {
    _decimalSeparatorController.dispose();
    _thousandSeparatorController.dispose();
    _dateTimeFormatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var l10n = ref.watch(l10nProvider);

    buildLocaleCard(Locale locale) {
      final bool selected = context.locale == locale;
      return FinancrrCard(
        onTap: () {
          context.setLocale(locale);
          ScaffoldNavBarShell.maybeOf(context)?.refresh();
        },
        padding: const EdgeInsets.all(10),
        borderColor: selected ? theme.financrrExtension.primary : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(locale.getLocaleName(),
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: selected ? theme.financrrExtension.primary : null, fontWeight: selected ? FontWeight.bold : null)),
            if (selected) Icon(Icons.check, color: theme.financrrExtension.primary),
          ],
        ),
      );
    }

    buildVerticalLayout(Size size) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: Theme(
              data: theme.themeData.copyWith(dividerColor: Colors.transparent),
              child: ListView(
                children: [
                  for (Locale locale in context.supportedLocales)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: buildLocaleCard(locale),
                    ),
                  ExpansionTile(
                    title: L10nKey.l10nDecimalSeparator.toText(),
                    subtitle: Text('1${l10n.decimalSeparator}234'),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FinancrrTextField(
                          controller: _decimalSeparatorController,
                          onChanged: (value) {
                            if (value.trim().isEmpty || value.length > 1) return;
                            ref.read(l10nProvider.notifier).setDecimalSeparator(value);
                          },
                          label: L10nKey.l10nDecimalSeparator,
                          inputFormatters: [LengthLimitingTextInputFormatter(1)],
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: L10nKey.l10nThousandsSeparator.toText(),
                    subtitle: Text('1${l10n.thousandSeparator}234${l10n.thousandSeparator}567'),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FinancrrTextField(
                          controller: _thousandSeparatorController,
                          onChanged: (value) {
                            if (value.trim().isEmpty || value.length > 1) return;
                            ref.read(l10nProvider.notifier).setThousandSeparator(value);
                          },
                          label: L10nKey.l10nThousandsSeparator,
                          inputFormatters: [LengthLimitingTextInputFormatter(1)],
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: L10nKey.l10nDateFormat.toText(),
                    subtitle: StatefulBuilder(builder: (context, setState) {
                      Timer(const Duration(seconds: 1), () {
                        if (context.mounted) {
                          setState(() {});
                        }
                      });
                      return Text(l10n.dateFormat.format(DateTime.now()));
                    }),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: FinancrrTextField(
                          controller: _dateTimeFormatController,
                          onChanged: (value) {
                            ref.read(l10nProvider.notifier).setDateFormat(DateFormat(value));
                          },
                          label: L10nKey.l10nDateFormat,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => buildVerticalLayout(size),
    );
  }
}
