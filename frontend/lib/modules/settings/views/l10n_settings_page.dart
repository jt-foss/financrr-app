import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../utils/text_utils.dart';
import 'settings_page.dart';

class L10nSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'languages');

  const L10nSettingsPage({super.key});

  @override
  ConsumerState<L10nSettingsPage> createState() => _L10nSettingsPageState();
}

class _L10nSettingsPageState extends ConsumerState<L10nSettingsPage> {
  late final TextEditingController _decimalSeparatorController;
  late final TextEditingController _thousandSeparatorController;
  late final TextEditingController _dateTimeFormatController;

  Locale? _locale;
  late String _decimalSeparator;
  late String _thousandSeparator;
  late String _dateTimeFormat;

  @override
  void initState() {
    super.initState();
    _decimalSeparator = StoreKey.decimalSeparator.readSync()!;
    _thousandSeparator = StoreKey.thousandSeparator.readSync()!;
    _dateTimeFormat = StoreKey.dateTimeFormat.readSync()!.pattern!;

    _decimalSeparatorController = TextEditingController(text: _decimalSeparator);
    _thousandSeparatorController = TextEditingController(text: _thousandSeparator);
    _dateTimeFormatController = TextEditingController(text: _dateTimeFormat);
  }

  @override
  Widget build(BuildContext context) {
    buildLocaleCard(Locale locale) {
      return ListTile(
        title: Text(locale.toLanguageTag()),
        onTap: () => setState(() => _locale = locale),
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
                Card.outlined(
                  child: Column(
                    children: [
                      for (Locale locale in context.supportedLocales) buildLocaleCard(locale),
                    ],
                  ),
                ),
                const Divider(),
                L10nKey.commonPreview.toText(style: ref.textTheme.titleSmall),
                Text(TextUtils.formatBalance(
                    123456789, 2, _decimalSeparatorController.text, _thousandSeparatorController.text)),
                Text(DateFormat(_dateTimeFormatController.text).format(DateTime.now())),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Flexible(
                          child: TextFormField(
                            controller: _decimalSeparatorController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: L10nKey.l10nDecimalSeparator.toString(),
                            ),
                            inputFormatters: [LengthLimitingTextInputFormatter(1)],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: TextFormField(
                            controller: _thousandSeparatorController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: L10nKey.l10nThousandsSeparator.toString(),
                            ),
                            inputFormatters: [LengthLimitingTextInputFormatter(1)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                    controller: _dateTimeFormatController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: L10nKey.l10nDateFormat.toString(),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: _isDifferent() ? () => _save() : null,
                    child: L10nKey.commonSave.toText(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: buildVerticalLayout(size)),
    );
  }

  bool _isDifferent() {
    return (_locale != null && context.locale != _locale) ||
        _decimalSeparatorController.text != _decimalSeparator ||
        _thousandSeparatorController.text != _thousandSeparator ||
        _dateTimeFormatController.text != _dateTimeFormat;
  }

  void _save() async {
    if (_locale != null && context.locale != _locale) {
      await context.setLocale(_locale!);
    }
    if (_decimalSeparatorController.text != _decimalSeparator) {
      StoreKey.decimalSeparator.write(_decimalSeparatorController.text);
    }
    if (_thousandSeparatorController.text != _thousandSeparator) {
      StoreKey.thousandSeparator.write(_thousandSeparatorController.text);
    }
    if (_dateTimeFormatController.text != _dateTimeFormat) {
      StoreKey.dateTimeFormat.write(DateFormat(_dateTimeFormatController.text));
    }
    setState(() {
      _locale = context.locale;
      _decimalSeparator = _decimalSeparatorController.text;
      _thousandSeparator = _thousandSeparatorController.text;
      _dateTimeFormat = _dateTimeFormatController.text;
    });
    L10nKey.commonSaveSuccess.showSnack(context);
  }
}
