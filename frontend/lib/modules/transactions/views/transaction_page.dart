import 'dart:async';

import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/modules/transactions/views/transaction_edit_page.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
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
import '../../../utils/text_utils.dart';
import '../../accounts/views/account_page.dart';

class TransactionPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath =
      PagePathBuilder.child(parent: AccountPage.pagePath, path: 'transactions/:transactionId');

  final String? accountId;
  final String? transactionId;

  const TransactionPage({super.key, required this.accountId, required this.transactionId});

  @override
  ConsumerState<TransactionPage> createState() => TransactionPageState();
}

class TransactionPageState extends ConsumerState<TransactionPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final StreamController<Transaction> _transactionStreamController = StreamController.broadcast();

  late final Restrr _api = api;

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
      // TODO: localize
      onError: (_, __) => const Text('Could not find account'),
    );
  }

  Widget _handleTransactionStream(Account account, Size size) {
    return StreamWrapper(
      stream: _transactionStreamController.stream,
      onSuccess: (ctx, snap) => _buildVerticalLayout(account, snap.data!, size),
      onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
      // TODO: localize
      onError: (_, __) => const Text('Could not find transaction'),
    );
  }

  Widget _buildVerticalLayout(Account account, Transaction transaction, Size size) {
    final String amountStr = (transaction.type == TransactionType.deposit ? '' : '-') +
        TextUtils.formatBalanceWithCurrency(transaction.amount, account.currencyId.get()!);
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
                          style: ref.textTheme.titleLarge?.copyWith(
                              color: transaction.type == TransactionType.deposit
                                  ? ref.themeData.primaryColor
                                  : ref.themeData.colorScheme.error)),
                      Text(transaction.description ?? StoreKey.dateTimeFormat.readSync()!.format(transaction.executedAt)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          tooltip: 'Delete Transaction',
                          onPressed: () => _deleteTransaction(transaction),
                          icon: const Icon(Icons.delete_rounded, size: 17)),
                      IconButton(
                          tooltip: 'Edit Transaction',
                          onPressed: () => context.goPath(TransactionEditPage.pagePath.build(params: {
                                'accountId': account.id.value.toString(),
                                'transactionId': transaction.id.value.toString()
                              })),
                          icon: const Icon(Icons.create_rounded, size: 17))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Table(
                      border: TableBorder.all(color: ref.themeData.dividerColor),
                      children: [
                        // TODO: localize
                        _buildTableRow('Type', transaction.type.name),
                        // TODO: localize
                        _buildTableRow('Amount', amountStr),
                        // TODO: localize
                        _buildTableRow('Name', transaction.name),
                        // TODO: localize
                        _buildTableRow('Description', transaction.description ?? 'N/A'),
                        // TODO: localize
                        _buildTableRow('From', transaction.sourceId?.get()?.name ?? 'N/A'),
                        // TODO: localize
                        _buildTableRow('To', transaction.destinationId?.get()?.name ?? 'N/A'),
                        // TODO: localize
                        _buildTableRow('Executed at', StoreKey.dateTimeFormat.readSync()!.format(transaction.executedAt)),
                        // TODO: localize
                        _buildTableRow('Created at', StoreKey.dateTimeFormat.readSync()!.format(transaction.createdAt)),
                      ],
                    ),
                  )
                ],
              )),
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
      L10nKey.commonDeleteObjectSuccess.showSnack(context, namedArgs: {'object': transaction.description ?? 'transaction'});
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
