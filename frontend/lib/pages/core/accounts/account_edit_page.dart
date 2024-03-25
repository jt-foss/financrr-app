import 'dart:async';

import 'package:financrr_frontend/pages/core/accounts/accounts_overview_page.dart';
import 'package:financrr_frontend/pages/core/accounts/account_create_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restrr/restrr.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';
import '../../../widgets/async_wrapper.dart';
import 'account_page.dart';

class AccountEditPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: AccountPage.pagePath, path: 'edit');

  final String? accountId;

  const AccountEditPage({super.key, required this.accountId});

  @override
  State<StatefulWidget> createState() => AccountEditPageState();
}

class AccountEditPageState extends State<AccountEditPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final Restrr _api = context.api!;

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _ibanController;
  late final TextEditingController _originalBalanceController;

  Currency? _currency;

  bool _isValid = false;

  Future<Account?> _fetchAccount({bool forceRetrieve = false}) async {
    return _accountStreamController.fetchData(
        widget.accountId, (id) => _api.retrieveAccountById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();
    _fetchAccount().then((account) {
      if (account != null) {
        _nameController = TextEditingController(text: account.name);
        _descriptionController = TextEditingController(text: account.description);
        _ibanController = TextEditingController(text: account.iban);
        _originalBalanceController = TextEditingController(text: account.originalBalance.toString());
        _currency = account.getCurrency()!;
      }
    });

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
      verticalBuilder: (_, __, size) => SafeArea(child: _handleAccountStream(size)),
    );
  }

  Widget _handleAccountStream(Size size) {
    return StreamWrapper(
      stream: _accountStreamController.stream,
      onSuccess: (ctx, snap) {
        return _buildVerticalLayout(snap.data!, size);
      },
      onLoading: (ctx, snap) {
        return const Center(child: CircularProgressIndicator());
      },
      onError: (ctx, snap) {
        return const Text('Could not find account');
      },
    );
  }

  Widget _buildVerticalLayout(Account account, Size size) {
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
                AccountCreatePageState.buildAccountPreview(
                    context,
                    size,
                    _nameController.text,
                    _descriptionController.text,
                    _ibanController.text,
                    _originalBalanceController.text,
                    _currency ?? _api.getCurrencies().first),
                const Divider(),
                ...AccountCreatePageState.buildFormFields(context, _api, _nameController, _descriptionController,
                    _ibanController, _originalBalanceController, false,
                    onCurrencyChanged: (currency) => _currency = currency!, initialCurrency: _currency),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isValid ? () => _editAccount(account) : null,
                    child: Text(_nameController.text.isEmpty ? 'Edit Account' : 'Edit "${_nameController.text}"'),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Future<void> _editAccount(Account account) async {
    if (!_isValid || _currency == null) return;
    try {
      await account.update(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        iban: _ibanController.text.isEmpty ? null : _ibanController.text,
        originalBalance: int.tryParse(_originalBalanceController.text) ?? 0,
        currency: _currency!.id,
      );
      if (!mounted) return;
      context.showSnackBar('Successfully edited "${_nameController.text}"');
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
