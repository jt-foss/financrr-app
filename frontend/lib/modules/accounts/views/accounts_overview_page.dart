import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../routing/page_path.dart';
import '../../../shared/ui/account_card.dart';
import '../../../shared/ui/notice_card.dart';
import '../../../utils/text_utils.dart';
import 'account_create_page.dart';
import 'account_edit_page.dart';

class AccountsOverviewPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/accounts');

  const AccountsOverviewPage({super.key});

  @override
  ConsumerState<AccountsOverviewPage> createState() => _AccountsOverviewPageState();
}

class _AccountsOverviewPageState extends ConsumerState<AccountsOverviewPage> {
  late final Restrr _api = api;

  late Map<Currency, int> _currencies = _api.getAccounts().fold(
    {},
    (map, account) {
      map.update(account.currencyId.get()!, (value) => value + account.balance, ifAbsent: () => account.balance);
      return map;
    },
  );

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: RefreshIndicator(
            onRefresh: () {
              setState(() {
                _currencies = _api.getAccounts().fold(
                  {},
                  (map, account) {
                    map.update(account.currencyId.get()!, (value) => value + account.balance, ifAbsent: () => account.balance);
                    return map;
                  },
                );
              });
              return Future.value();
            },
            child: ListView(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _currencies.entries.map((entry) {
                        return Text(TextUtils.formatBalanceWithCurrency(entry.value, entry.key),
                            style: ref.textTheme.titleSmall?.copyWith(color: ref.themeData.primaryColor));
                      }).toList(),
                    ),
                    TextButton.icon(
                      label: L10nKey.accountCreate.toText(),
                      icon: const Icon(Icons.add, size: 17),
                      onPressed: () => context.goPath(AccountCreatePage.pagePath.build()),
                    ),
                  ],
                ),
              ),
              if (_api.getAccounts().isEmpty)
                Center(
                  child: NoticeCard(
                    title: L10nKey.accountNoneFoundTitle.toString(),
                    description: L10nKey.accountNoneFoundBody.toString(),
                    onTap: () => context.goPath(AccountCreatePage.pagePath.build()),
                  ),
                ),
              for (Account account in _api.getAccounts())
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(account.name, style: ref.textTheme.titleSmall),
                          ),
                          const Spacer(),
                          PopupMenuButton(
                              icon: const Icon(Icons.more_horiz),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                      child: ListTile(
                                    title: L10nKey.accountEdit.toText(),
                                    leading: const Icon(Icons.edit_rounded),
                                    onTap: () => context.goPath(
                                        AccountEditPage.pagePath.build(params: {'accountId': account.id.value.toString()})),
                                  )),
                                  PopupMenuItem(
                                      child: ListTile(
                                    title: L10nKey.accountDelete.toText(),
                                    leading: const Icon(Icons.delete_rounded),
                                    onTap: () => _deleteAccount(account),
                                  ))
                                ];
                              })
                        ],
                      ),
                      const Divider(),
                      AccountCard(account: account),
                    ],
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  void _deleteAccount(Account account) async {
    try {
      await account.delete();
      if (!mounted) return;
      L10nKey.commonDeleteObjectSuccess.showSnack(context, namedArgs: {'object': account.name});
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
