import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/routing/navbar_shell.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../providers/l10n.provider.dart';
import 'settings_page.dart';

class L10nSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath =
      PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'language');

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
    _decimalSeparatorController =
        TextEditingController(text: l10n.decimalSeparator);
    _thousandSeparatorController =
        TextEditingController(text: l10n.thousandSeparator);
    _dateTimeFormatController =
        TextEditingController(text: l10n.dateFormat.pattern);
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
    var l10n = ref.watch(l10nProvider);

    buildLocaleCard(Locale locale) {
      return Card.outlined(
        child: ListTile(
          onTap: () {
            context.setLocale(locale);
            ScaffoldNavBarShell.maybeOf(context)?.refresh();
          },
          title: Text(locale.getLocaleName()),
          trailing: context.locale == locale ? const Icon(Icons.check) : null,
        ),
      );
    }

    buildVerticalLayout(Size size) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: ListView(
              children: [
                for (Locale locale in context.supportedLocales)
                  buildLocaleCard(locale),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Divider(),
                ),
                ExpansionTile(
                  title: L10nKey.l10nDecimalSeparator.toText(),
                  subtitle: Text('1${l10n.decimalSeparator}234'),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: _decimalSeparatorController,
                        onChanged: (value) {
                          if (value.trim().isEmpty || value.length > 1) return;
                          ref
                              .read(l10nProvider.notifier)
                              .setDecimalSeparator(value);
                        },
                        decoration: InputDecoration(
                          labelText: L10nKey.l10nDecimalSeparator.toString(),
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(1)],
                      ),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: L10nKey.l10nThousandsSeparator.toText(),
                  subtitle: Text(
                      '1${l10n.thousandSeparator}234${l10n.thousandSeparator}567'),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: _thousandSeparatorController,
                        onChanged: (value) {
                          if (value.trim().isEmpty || value.length > 1) return;
                          ref
                              .read(l10nProvider.notifier)
                              .setThousandSeparator(value);
                        },
                        decoration: InputDecoration(
                          labelText: L10nKey.l10nThousandsSeparator.toString(),
                        ),
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
                      child: TextFormField(
                          controller: _dateTimeFormatController,
                          onChanged: (value) {
                            ref
                                .read(l10nProvider.notifier)
                                .setDateFormat(DateFormat(value));
                          },
                          decoration: InputDecoration(
                            labelText: L10nKey.l10nDateFormat.toString(),
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) =>
          SafeArea(child: buildVerticalLayout(size)),
    );
  }
}
