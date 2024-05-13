import 'dart:async';

import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../shared/ui/async_wrapper.dart';
import '../../../shared/ui/account_card.dart';
import '../../../utils/form_fields.dart';
import '../../settings/providers/theme.provider.dart';
import 'account_page.dart';

class AccountEditPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: AccountPage.pagePath, path: 'edit');

  final String? accountId;

  const AccountEditPage({super.key, required this.accountId});

  @override
  ConsumerState<AccountEditPage> createState() => AccountEditPageState();
}

class AccountEditPageState extends ConsumerState<AccountEditPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final Restrr _api = api;

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
        _currency = account.currencyId.get()!;
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
    var theme = ref.watch(themeProvider);

    buildVerticalLayout(Account account, Size size) {
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
                  ...FormFields.account(ref, theme,
                      api: _api,
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      ibanController: _ibanController,
                      originalBalanceController: _originalBalanceController,
                      onCurrencyChanged: (currency) => _currency = currency!,
                      initialCurrency: _currency),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isValid ? () => _editAccount(account) : null,
                      child: _nameController.text.isEmpty
                          ? L10nKey.accountEdit.toText()
                          : L10nKey.commonEditObject.toText(namedArgs: {'object': _nameController.text}),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
      );
    }

    handleAccountStream(Size size) {
      return StreamWrapper(
          stream: _accountStreamController.stream,
          onSuccess: (_, snap) => buildVerticalLayout(snap.data!, size),
          onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
          onError: (_, __) => L10nKey.accountNotFound.toText());
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => handleAccountStream(size),
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
        currencyId: _currency!.id.value,
      );
      if (!mounted) return;
      L10nKey.commonEditObjectSuccess.showSnack(context, namedArgs: {'object': _nameController.text});
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
