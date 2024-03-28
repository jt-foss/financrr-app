import 'dart:async';

import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_create_page.dart';
import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restrr/restrr.dart';

import '../../../../../layout/adaptive_scaffold.dart';
import '../../../../../router.dart';
import '../../../../widgets/async_wrapper.dart';

class TransactionEditPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: TransactionPage.pagePath, path: 'edit');

  final String? accountId;
  final String? transactionId;

  const TransactionEditPage({super.key, required this.accountId, required this.transactionId});

  @override
  State<StatefulWidget> createState() => TransactionEditPageState();
}

class TransactionEditPageState extends State<TransactionEditPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final StreamController<Transaction> _transactionStreamController = StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey();

  late final Restrr _api = context.api!;

  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  bool _isValid = false;
  TransactionType _type = TransactionType.deposit;
  DateTime _executedAt = DateTime.now();

  Future<Account?> _fetchAccount({bool forceRetrieve = false}) async {
    return _accountStreamController.fetchData(
        widget.accountId, (id) => _api.retrieveAccountById(id, forceRetrieve: forceRetrieve));
  }

  Future<Transaction?> _fetchTransaction({bool forceRetrieve = false}) async {
    return _transactionStreamController.fetchData(
        widget.transactionId, (id) => _api.retrieveTransactionById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();

    _fetchAccount().then((_) {
      Future.delayed(
          const Duration(milliseconds: 100),
          () => _fetchTransaction().then((transaction) {
                if (transaction != null) {
                  _amountController = TextEditingController(text: transaction.amount.toString());
                  _descriptionController = TextEditingController(text: transaction.description);
                  _isValid = _formKey.currentState?.validate() ?? false;
                  _type = transaction.type;
                  _executedAt = transaction.executedAt;
                }
              }));
    });
  }

  @override
  void dispose() {
    _accountStreamController.close();
    _transactionStreamController.close();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(verticalBuilder: (_, __, size) => SafeArea(child: _handleAccountStream(size)));
  }

  Widget _handleAccountStream(Size size) {
    return StreamWrapper(
      stream: _accountStreamController.stream,
      onSuccess: (ctx, snap) => _handleTransactionStream(snap.data!, size),
      onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
      onError: (_, __) => const Text('Could not find account'),
    );
  }

  Widget _handleTransactionStream(Account account, Size size) {
    return StreamWrapper(
      stream: _transactionStreamController.stream,
      onSuccess: (ctx, snap) => _buildVerticalLayout(account, snap.data!, size),
      onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
      onError: (_, __) => const Text('Could not find transaction'),
    );
  }

  Widget _buildVerticalLayout(Account account, Transaction transaction, Size size) {
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
                TransactionCreatePageState.buildTransactionPreview(
                  _amountController.text,
                  _descriptionController.text,
                  account,
                  _type,
                ),
                const Divider(),
                ...TransactionCreatePageState.buildFormFields(
                  context,
                  account,
                  _amountController,
                  _descriptionController,
                  _type,
                  false,
                  executedAt: _executedAt,
                  onSelectionChanged: (types) {
                    setState(() => _type = types.first);
                  },
                  onExecutedAtChanged: (date) {
                    setState(() => _executedAt = date);
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isValid ? () => _editTransaction(account, transaction, _type) : null,
                    child: const Text('Edit Transaction'),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Future<void> _editTransaction(Account account, Transaction transaction, TransactionType type,
      {Account? secondary}) async {
    if (!_isValid) return;
    final (Id?, Id?) sourceAndDest = switch (_type) {
      TransactionType.deposit => (null, account.id.value),
      TransactionType.withdrawal => (account.id.value, null),
      TransactionType.transfer => (account.id.value, secondary!.id.value),
    };
    try {
      await transaction.update(
          sourceId: sourceAndDest.$1,
          destinationId: sourceAndDest.$2,
          amount: int.parse(_amountController.text),
          description: _descriptionController.text,
          executedAt: _executedAt,
          currencyId: account.currencyId.value);
      if (!mounted) return;
      context.showSnackBar('Successfully edited transaction');
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
