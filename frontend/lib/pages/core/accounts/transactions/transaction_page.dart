import 'dart:async';

import 'package:financrr_frontend/pages/core/accounts/account_page.dart';
import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_edit_page.dart';
import 'package:financrr_frontend/pages/login/bloc/auth_bloc.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restrr/restrr.dart';

import '../../../../../layout/adaptive_scaffold.dart';
import '../../../../../router.dart';
import '../../../../data/l10n_repository.dart';
import '../../../../widgets/async_wrapper.dart';

class TransactionPage extends StatefulWidget {
  static const PagePathBuilder pagePath =
      PagePathBuilder.child(parent: AccountPage.pagePath, path: 'transactions/:transactionId');

  final String? accountId;
  final String? transactionId;

  const TransactionPage({super.key, required this.accountId, required this.transactionId});

  @override
  State<StatefulWidget> createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final StreamController<Transaction> _transactionStreamController = StreamController.broadcast();

  late final Restrr _api = context.api!;

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
      Future.delayed(const Duration(milliseconds: 100), () => _fetchTransaction());
    });
  }

  @override
  void dispose() {
    _accountStreamController.close();
    _transactionStreamController.close();
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
    final String amountStr = (transaction.type == TransactionType.deposit ? '' : '-') +
        TextUtils.formatCurrency(transaction.amount, account.currencyId.get()!);
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: size.width / 1.1,
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchAccount(forceRetrieve: true);
              await _fetchTransaction(forceRetrieve: true);
            },
            child: ListView(
              children: [
                Column(
                  children: [
                    Text(amountStr,
                        style: context.textTheme.titleLarge?.copyWith(
                            color: transaction.type == TransactionType.deposit
                                ? context.theme.primaryColor
                                : context.theme.colorScheme.error)),
                    Text(transaction.description ?? transaction.executedAt.toIso8601String()),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                        onPressed: () => _deleteTransaction(transaction),
                        icon: const Icon(Icons.delete_rounded, size: 17),
                        label: const Text('Delete Transaction')),
                    TextButton.icon(
                        onPressed: () => context.goPath(TransactionEditPage.pagePath.build(pathParams: {
                              'accountId': account.id.value.toString(),
                              'transactionId': transaction.id.value.toString()
                            })),
                        icon: const Icon(Icons.create_rounded, size: 17),
                        label: const Text('Edit Transaction'))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Table(
                    border: TableBorder.all(color: context.theme.dividerColor),
                    children: [
                      _buildTableRow('Type', transaction.type.name),
                      _buildTableRow('Amount', amountStr),
                      _buildTableRow('Name', transaction.name),
                      _buildTableRow('Description', transaction.description ?? 'N/A'),
                      _buildTableRow('From', transaction.sourceId?.get()?.name ?? 'N/A'),
                      _buildTableRow('To', transaction.destinationId?.get()?.name ?? 'N/A'),
                      _buildTableRow('Executed at', dateTimeFormat.format(transaction.executedAt)),
                      _buildTableRow('Created at', dateTimeFormat.format(transaction.createdAt)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(label),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(value),
      ),
    ]);
  }

  void _deleteTransaction(Transaction transaction) async {
    try {
      await transaction.delete();
      if (!mounted) return;
      context.pop();
      context.showSnackBar('Successfully deleted "${transaction.description ?? 'transaction'}"');
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
