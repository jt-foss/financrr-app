import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../../../util/text_utils.dart';
import '../../../widgets/entities/account_card.dart';
import 'account_create_page.dart';
import 'account_edit_page.dart';

class AccountsOverviewPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/accounts');

  const AccountsOverviewPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountsOverviewPageState();
}

class _AccountsOverviewPageState extends State<AccountsOverviewPage> {
  late final Restrr _api = context.api!;

  late final Map<Currency, int> _currencies = _api.getAccounts().fold(
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
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _currencies.entries.map((entry) {
                      return Text(TextUtils.formatCurrency(entry.value, entry.key),
                          style: context.textTheme.titleSmall?.copyWith(color: context.theme.primaryColor));
                    }).toList(),
                  ),
                  TextButton.icon(
                    label: const Text('Create Account'),
                    icon: const Icon(Icons.add, size: 17),
                    onPressed: () => context.goPath(AccountCreatePage.pagePath.build()),
                  ),
                ],
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
                          child: Text(account.name, style: context.textTheme.titleSmall),
                        ),
                        const Spacer(),
                        PopupMenuButton(
                            icon: const Icon(Icons.more_horiz),
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                    child: ListTile(
                                  title: const Text('Edit Account'),
                                  leading: const Icon(Icons.edit_rounded),
                                  onTap: () => context.goPath(
                                      AccountEditPage.pagePath.build(pathParams: {'accountId': account.id.value.toString()})),
                                )),
                                PopupMenuItem(
                                    child: ListTile(
                                  title: const Text('Delete Account'),
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
