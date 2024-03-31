import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/pages/core/accounts/accounts_overview_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:financrr_frontend/widgets/entities/account_card.dart';
import 'package:financrr_frontend/widgets/entities/transaction_card.dart';
import 'package:financrr_frontend/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';
import 'accounts/account_create_page.dart';
import 'accounts/transactions/transaction_create_page.dart';

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
            child: RefreshIndicator(
              onRefresh: () => _fetchLatestTransactions(forceRetrieve: true),
              child: ListView(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account and Cards', style: context.textTheme.titleSmall),
                    PopupMenuButton(
                        icon: const Icon(Icons.more_horiz),
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                                child: ListTile(
                              title: const Text('Manage Accounts'),
                              leading: const Icon(Icons.manage_accounts_rounded),
                              onTap: () => context.goPath(AccountsOverviewPage.pagePath.build()),
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
                const Divider(),
                for (Account a in _api.getAccounts()) AccountCard(account: a),
                if (_api.getAccounts().isEmpty)
                  Center(
                      child: NoticeCard(
                          title: 'No accounts found',
                          description: 'Create an account to get started',
                          onTap: () => context.goPath(AccountCreatePage.pagePath.build()))),
                if (_api.getAccounts().isNotEmpty) _buildTransactionSection()
              ]),
            )),
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text('Latest Transactions', style: context.textTheme.titleSmall),
        ),
        const Divider(),
        StreamWrapper(
            stream: _transactionStreamController.stream,
            onError: (context, snap) => const Text('Error'),
            onLoading: (context, snap) => const Center(child: CircularProgressIndicator()),
            onSuccess: (context, snap) {
              final List<Transaction> transactions = snap.data!.items;
              if (transactions.isEmpty) {
                return const Center(
                    child:
                        NoticeCard(title: 'No transactions found', description: 'Your transactions will appear here'));
              }
              return Column(
                children: [
                  for (Transaction t in transactions)
                    SizedBox(width: double.infinity, child: TransactionCard(transaction: t))
                ],
              );
            })
      ],
    );
  }
}
