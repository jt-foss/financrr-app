import 'dart:async';

import 'package:financrr_frontend/pages/core/accounts/transactions/transaction_create_page.dart';
import 'package:financrr_frontend/pages/core/accounts/account_edit_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:financrr_frontend/widgets/entities/transaction_card.dart';
import 'package:financrr_frontend/widgets/paginated_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import 'accounts_overview_page.dart';

class AccountPage extends StatefulWidget {
  static const PagePathBuilder pagePath =
      PagePathBuilder.child(parent: AccountsOverviewPage.pagePath, path: ':accountId');

  final String? accountId;

  const AccountPage({super.key, required this.accountId});

  @override
  State<StatefulWidget> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  late final Restrr _api = context.api!;

  Future<Account?> _fetchAccount({bool forceRetrieve = false}) async {
    return _accountStreamController.fetchData(
        widget.accountId, (id) => _api.retrieveAccountById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();
    _fetchAccount();
  }

  @override
  void dispose() {
    _accountStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(verticalBuilder: (_, __, size) => SafeArea(child: _handleAccountStream(size)));
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
          child: ListView(
            children: [
              Column(
                children: [
                  Text(TextUtils.formatCurrency(account.balance, account.currencyId.get()!),
                      style: context.textTheme.titleLarge?.copyWith(color: context.theme.primaryColor)),
                  Text(account.name),
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                          onPressed: () => context.goPath(TransactionCreatePage.pagePath
                              .build(pathParams: {'accountId': account.id.value.toString()})),
                          icon: const Icon(Icons.add, size: 17),
                          label: const Text('Create Transaction')),
                      const Spacer(),
                      TextButton.icon(
                          onPressed: () => _deleteAccount(account),
                          icon: const Icon(Icons.delete_rounded, size: 17),
                          label: const Text('Delete Account')),
                      TextButton.icon(
                          onPressed: () => context.goPath(
                              AccountEditPage.pagePath.build(pathParams: {'accountId': account.id.value.toString()})),
                          icon: const Icon(Icons.create, size: 17),
                          label: const Text('Edit Account'))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _buildTransactionSection(account),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionSection(Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest Transactions', style: context.textTheme.titleMedium),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: PaginatedWrapper(
            initialPageFunction: () => account.retrieveAllTransactions(),
            onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
            onSuccess: (context, snap) {
              return Column(
                children: snap.data!.page.items.map((t) {
                  return TransactionCard(transaction: t);
                }).toList(),
              );
            },
          ),
        )
      ],
    );
  }

  void _deleteAccount(Account account) async {
    try {
      await account.delete();
      if (!mounted) return;
      context.showSnackBar('Successfully deleted "${account.name}"');
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
