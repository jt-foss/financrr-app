import 'dart:async';

import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../../../routing/page_path.dart';
import '../../../shared/ui/async_wrapper.dart';
import '../../../shared/ui/transaction_card.dart';
import '../../../utils/form_fields.dart';
import '../../accounts/views/account_page.dart';
import '../../settings/providers/theme.provider.dart';

class TransactionCreatePage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: AccountPage.pagePath, path: 'transactions/create');

  final String? accountId;

  const TransactionCreatePage({super.key, required this.accountId});

  @override
  ConsumerState<TransactionCreatePage> createState() => _TransactionCreatePageState();
}

class _TransactionCreatePageState extends ConsumerState<TransactionCreatePage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final Restrr _api = api;

  late final TextEditingController _nameController = TextEditingController(text: 'Transaction');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _executedAtController;

  bool _isValid = false;
  TransactionType _type = TransactionType.deposit;
  DateTime _executedAt = DateTime.now();

  Future<Account?> _fetchAccount({bool forceRetrieve = false}) async {
    return _accountStreamController.fetchData(
        widget.accountId, (id) => _api.retrieveAccountById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();
    _executedAtController = TextEditingController(text: StoreKey.dateTimeFormat.readSync()!.format(_executedAt));
    _fetchAccount();
    _isValid = _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _executedAtController.dispose();
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
                  TransactionCard.fromData(
                    id: 0,
                    amount: int.tryParse(_amountController.text) ?? 0,
                    account: account,
                    name: _nameController.text,
                    description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                    type: _type,
                    createdAt: DateTime.now(),
                    executedAt: _executedAt,
                    interactive: false,
                  ),
                  const Divider(),
                  ...FormFields.transaction(
                    this,
                    theme,
                    currentAccount: account,
                    nameController: _nameController,
                    amountController: _amountController,
                    descriptionController: _descriptionController,
                    executedAtController: _executedAtController,
                    selectedType: _type,
                    onSelectionChanged: (types) {
                      setState(() => _type = types.first);
                    },
                    onExecutedAtChanged: (date) => setState(() => _executedAt = date),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isValid ? () => _createTransaction(account, _type) : null,
                      child: L10nKey.transactionCreate.toText(),
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
        onError: (ctx, snap) => L10nKey.accountNotFound.toText(),
      );
    }

    return AdaptiveScaffold(verticalBuilder: (_, __, size) => SafeArea(child: handleAccountStream(size)));
  }

  Future<void> _createTransaction(Account account, TransactionType type, {Account? secondary}) async {
    if (!_isValid) return;
    final (Id?, Id?) sourceAndDest = switch (_type) {
      TransactionType.deposit => (null, account.id.value),
      TransactionType.withdrawal => (account.id.value, null),
      TransactionType.transfer => (account.id.value, secondary!.id.value),
    };
    try {
      Transaction transaction = await _api.createTransaction(
          sourceId: sourceAndDest.$1,
          destinationId: sourceAndDest.$2,
          amount: int.parse(_amountController.text),
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          executedAt: _executedAt,
          currencyId: account.currencyId.value);
      if (!mounted) return;
      L10nKey.commonCreateObjectSuccess.showSnack(context, namedArgs: {'object': transaction.name});
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
