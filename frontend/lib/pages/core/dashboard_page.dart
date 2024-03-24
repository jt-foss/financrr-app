import 'dart:async';

import 'package:financrr_frontend/pages/core/settings/account_settings_page.dart';
import 'package:financrr_frontend/pages/core/transactions_list_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:financrr_frontend/widgets/entities/account_card.dart';
import 'package:financrr_frontend/widgets/entities/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';
import 'settings/accounts/account_create_page.dart';

class DashboardPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/dashboard');

  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Restrr _api = context.api!;

  final StreamController<Paginated<Transaction>> _transactionStreamController = StreamController.broadcast();

  Future<Paginated<Transaction>> _fetchLatestTransactions({bool forceRetrieve = false}) async {
    final Paginated<Transaction> transactions =
        await _api.retrieveAllTransactions(limit: 10, forceRetrieve: forceRetrieve);
    _transactionStreamController.add(transactions);
    return transactions;
  }

  @override
  void initState() {
    super.initState();
    _fetchLatestTransactions();
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
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account and Cards', style: context.textTheme.titleMedium),
                    PopupMenuButton(
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                child: ListTile(
                              title: const Text('Manage Accounts'),
                              leading: const Icon(Icons.manage_accounts_rounded),
                              onTap: () => context.goPath(AccountSettingsPage.pagePath.build()),
                            )),
                            PopupMenuItem(
                                child: ListTile(
                              title: const Text('Create Account'),
                              leading: const Icon(Icons.add),
                              onTap: () => context.goPath(AccountCreatePage.pagePath.build()),
                            ))
                          ];
                        })
                  ],
                ),
              ),
              for (Account a in _api.getAccounts())
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: AccountCard(account: a),
                ),
              if (_api.getAccounts().isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                      child: Column(
                    children: [
                      Text('No accounts found',
                          style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('Create an account to get started'),
                      TextButton.icon(
                        onPressed: () => context.goPath(AccountCreatePage.pagePath.build()),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Account'),
                      )
                    ],
                  )),
                ),
              if (_api.getAccounts().isNotEmpty) _buildTransactionSection()
            ])),
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Latest Transactions', style: context.textTheme.titleMedium),
              TextButton.icon(
                  label: const Text('View all'),
                  icon: const Icon(Icons.manage_search),
                  onPressed: () => context.goPath(TransactionListPage.pagePath.build()))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: StreamWrapper(
              stream: _transactionStreamController.stream,
              onError: (context, snap) => const Text('Error'),
              onLoading: (context, snap) => const Center(child: CircularProgressIndicator()),
              onSuccess: (context, snap) {
                return Column(
                  children: [
                    for (Transaction t in snap.data!.items)
                      SizedBox(width: double.infinity, child: TransactionCard(transaction: t))
                  ],
                );
              }),
        )
      ],
    );
  }
}
