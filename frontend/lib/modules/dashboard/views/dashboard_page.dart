import 'dart:async';

import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/shared/ui/async_wrapper.dart';
import 'package:financrr_frontend/shared/ui/account_card.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../shared/ui/notice_card.dart';
import '../../../shared/ui/transaction_card.dart';
import '../../accounts/views/account_create_page.dart';
import '../../accounts/views/accounts_overview_page.dart';

class DashboardPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/dashboard');

  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late final Restrr _api = api;

  final StreamController<Paginated<Transaction>> _transactionStreamController = StreamController.broadcast();

  Future<Paginated<Transaction>> _fetchLatestTransactions({bool forceRetrieve = false}) async {
    final Paginated<Transaction> transactions = await _api.retrieveAllTransactions(limit: 10, forceRetrieve: forceRetrieve);
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
    var theme = ref.watch(themeProvider);

    buildTransactionSection() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: L10nKey.dashboardTransactions.toText(style: theme.textTheme.titleMedium),
          ),
          const Divider(),
          StreamWrapper(
              stream: _transactionStreamController.stream,
              onError: (_, __) => const Text('Error'),
              onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
              onSuccess: (context, snap) {
                final List<Transaction> transactions = snap.data!.items;
                if (transactions.isEmpty) {
                  return Center(
                      child: NoticeCard(
                          title: L10nKey.transactionNoneFoundTitle.toString(),
                          description: L10nKey.transactionNoneFoundBody.toString()));
                }
                return Column(
                  children: [
                    for (Transaction t in transactions) SizedBox(width: double.infinity, child: TransactionCard(transaction: t))
                  ],
                );
              })
        ],
      );
    }

    buildVerticalLayout(Size size) {
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
                      L10nKey.dashboardAccounts.toText(style: theme.textTheme.titleSmall),
                      PopupMenuButton(
                          icon: const Icon(Icons.more_horiz),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                  child: ListTile(
                                title: L10nKey.accountListManage.toText(),
                                leading: const Icon(Icons.manage_accounts_rounded),
                                onTap: () => context.goPath(AccountsOverviewPage.pagePath.build()),
                              )),
                              PopupMenuItem(
                                  child: ListTile(
                                title: L10nKey.accountCreate.toText(),
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
                            title: L10nKey.accountNoneFoundTitle.toString(),
                            description: L10nKey.accountNoneFoundBody.toString(),
                            onTap: () => context.goPath(AccountCreatePage.pagePath.build()))),
                  if (_api.getAccounts().isNotEmpty) buildTransactionSection()
                ]),
              )),
        ),
      );
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => buildVerticalLayout(size),
    );
  }
}
