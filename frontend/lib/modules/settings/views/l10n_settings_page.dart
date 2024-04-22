import 'package:financrr_frontend/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../utils/text_utils.dart';
import 'settings_page.dart';

class L10nSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'languages');

  const L10nSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _L10nSettingsPageState();
}

class _L10nSettingsPageState extends State<L10nSettingsPage> {
  late final TextEditingController _decimalSeparatorController;
  late final TextEditingController _thousandSeparatorController;
  late final TextEditingController _dateTimeFormatController;

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
                  leading: const Text('Preview'),
                  title: Text(TextUtils.formatBalance(
                      123456789, 2, _decimalSeparatorController.text, _thousandSeparatorController.text)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                  controller: _decimalSeparatorController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Decimal Separator',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: _thousandSeparatorController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Thousand Separator',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(1)],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Card.outlined(
                  child: ListTile(
                    leading: const Text('Preview'),
                    title: Text(DateFormat(_dateTimeFormatController.text).format(DateTime.now())),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextFormField(
                    controller: _dateTimeFormatController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Date Format',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton(
                  onPressed: _isDifferent() ? () => _save() : null,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDifferent() {
    return _decimalSeparatorController.text != _decimalSeparator ||
        _thousandSeparatorController.text != _thousandSeparator ||
        _dateTimeFormatController.text != _dateTimeFormat;
  }

  void _save() {
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
      _decimalSeparator = _decimalSeparatorController.text;
      _thousandSeparator = _thousandSeparatorController.text;
      _dateTimeFormat = _dateTimeFormatController.text;
    });
    context.showSnackBar('Successfully saved changes!');
  }
}
