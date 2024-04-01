import 'package:financrr_frontend/data/l10n_repository.dart';
import 'package:financrr_frontend/main.dart';
import 'package:financrr_frontend/pages/authentication/bloc/authentication_bloc.dart';
import 'package:financrr_frontend/themes.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../../../util/input_utils.dart';
import '../settings_page.dart';

class L10nSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'languages');

  const L10nSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _L10nSettingsPageState();
}

class _L10nSettingsPageState extends State<L10nSettingsPage> {
  late final Restrr _api = context.api!;

  late final TextEditingController _decimalSeparatorController = TextEditingController(text: decimalSeparator);
  late final TextEditingController _thousandsSeparatorController = TextEditingController(text: thousandsSeparator);

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView(
            children: [
              Card.outlined(
                child: ListTile(
                  title: Text(TextUtils.formatBalance(12345678, 2, _decimalSeparatorController.text, _thousandsSeparatorController.text)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  controller: _decimalSeparatorController,
                  onChanged: (value) {
                    if (value.isEmpty) return;
                    L10nService.setL10nPreferences(decimalSeparator: value);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: 'Decimal Separator',
                  ),
                  validator: (value) => InputValidators.nonNull('Decimal Separator', value),
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: _thousandsSeparatorController,
                  onChanged: (value) {
                    if (value.isEmpty) return;
                    L10nService.setL10nPreferences(thousandSeparator: value);
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: 'Thousands Separator',
                  ),
                  validator: (value) => InputValidators.nonNull('Thousands Separator', value),
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
