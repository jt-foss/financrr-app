import 'package:financrr_frontend/pages/authentication/state/authentication_provider.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/form_fields.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../routing/router.dart';
import '../../../widgets/entities/account_card.dart';
import 'accounts_overview_page.dart';

class AccountCreatePage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: AccountsOverviewPage.pagePath, path: 'create');

  const AccountCreatePage({super.key});

  @override
  ConsumerState<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends ConsumerState<AccountCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final Restrr _api = api;

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
                AccountCard.fromData(
                  id: 0,
                  name: _nameController.text,
                  iban: _ibanController.text,
                  description: _descriptionController.text,
                  balance: int.tryParse(_originalBalanceController.text) ?? 0,
                  currency: _currency ?? _api.getCurrencies().first,
                ),
                const Divider(),
                ...FormFields.account(context,
                    api: _api,
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    ibanController: _ibanController,
                    originalBalanceController: _originalBalanceController,
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

  Future<void> _createAccount() async {
    if (!_isValid || _currency == null) return;
    try {
      await _api.createAccount(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        iban: _ibanController.text.isEmpty ? null : TextUtils.formatIBAN(_ibanController.text),
        originalBalance: int.tryParse(_originalBalanceController.text) ?? 0,
        currencyId: _currency!.id.value,
      );
      if (!mounted) return;
      context.showSnackBar('Successfully created "${_nameController.text}"');
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
