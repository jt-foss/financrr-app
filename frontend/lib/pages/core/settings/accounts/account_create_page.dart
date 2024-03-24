import 'package:financrr_frontend/pages/core/settings/account_settings_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/input_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:restrr/restrr.dart';

import '../../../../../layout/adaptive_scaffold.dart';
import '../../../../../router.dart';
import '../../../../widgets/entities/account_card.dart';

class AccountCreatePage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: AccountSettingsPage.pagePath, path: 'create');

  const AccountCreatePage({super.key});

  @override
  State<StatefulWidget> createState() => AccountCreatePageState();
}

class AccountCreatePageState extends State<AccountCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final Restrr _api = context.api!;

  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _ibanController = TextEditingController();
  late final TextEditingController _originalBalanceController = TextEditingController();

  Currency? _currency;

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _isValid = _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ibanController.dispose();
    _originalBalanceController.dispose();
    super.dispose();
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
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: size.width / 1.1,
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            onChanged: () => setState(() => _isValid = _formKey.currentState?.validate() ?? false),
            child: Column(
              children: [
                buildAccountPreview(context, size, _nameController.text, _descriptionController.text,
                    _ibanController.text, _originalBalanceController.text, _currency ?? _api.getCurrencies().first),
                const Divider(),
                ...buildFormFields(context, _api, _nameController, _descriptionController, _ibanController,
                    _originalBalanceController, false,
                    onCurrencyChanged: (currency) => _currency = currency!),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isValid ? () => _createAccount() : null,
                    child: Text(_nameController.text.isEmpty ? 'Create Account' : 'Create "${_nameController.text}"'),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  static Widget buildAccountPreview(BuildContext context, Size size, String name, String description, String iban,
      String originalBalance, Currency currency) {
    return AccountCard.fromData(
      id: 0,
      name: name,
      iban: iban,
      description: description,
      balance: int.tryParse(originalBalance) ?? 0,
      currency: currency,
    );
  }

  static List<Widget> buildFormFields(
      BuildContext context,
      Restrr api,
      TextEditingController nameController,
      TextEditingController descriptionController,
      TextEditingController ibanController,
      TextEditingController decimalPlacesController,
      bool readOnly,
      {void Function(Currency?)? onCurrencyChanged,
      Currency? initialCurrency}) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: nameController,
          readOnly: readOnly,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) => InputValidators.nonNull('Name', value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: descriptionController,
          readOnly: readOnly,
          decoration: const InputDecoration(labelText: 'Description'),
          inputFormatters: [
            LengthLimitingTextInputFormatter(64),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: ibanController,
          readOnly: readOnly,
          decoration: const InputDecoration(labelText: 'IBAN'),
          inputFormatters: [
            LengthLimitingTextInputFormatter(22),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: decimalPlacesController,
          readOnly: readOnly,
          decoration: const InputDecoration(labelText: 'Original Balance'),
          validator: (value) => InputValidators.nonNull('Original Balance', value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Currency'),
            validator: (value) => InputValidators.nonNull('Currency', value?.id.toString()),
            value: initialCurrency,
            items: api.getCurrencies().map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text('${currency.name} (${currency.symbol})', style: context.textTheme.bodyMedium),
              );
            }).toList(),
            onChanged: onCurrencyChanged),
      )
    ];
  }

  Future<void> _createAccount() async {
    if (!_isValid || _currency == null) return;
    try {
      await _api.createAccount(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        iban: _ibanController.text.isEmpty ? null : _ibanController.text,
        originalBalance: int.tryParse(_originalBalanceController.text) ?? 0,
        currency: _currency!.id,
      );
      if (!mounted) return;
      context.showSnackBar('Successfully created "${_nameController.text}"');
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
