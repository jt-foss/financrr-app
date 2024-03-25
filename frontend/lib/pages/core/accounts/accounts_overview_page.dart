import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/paginated_table.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../../../widgets/entities/account_card.dart';
import '../settings_page.dart';
import '../settings/currency/currency_create_page.dart';
import '../settings/currency/currency_edit_page.dart';

class AccountsOverviewPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/accounts');

  const AccountsOverviewPage({super.key});

  @override
  State<StatefulWidget> createState() => _AccountsOverviewPageState();
}

class _AccountsOverviewPageState extends State<AccountsOverviewPage> {
  late final Restrr _api = context.api!;

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
          child: ListView(
            children: [
             for (Account account in _api.getAccounts())
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: AccountCard(account: account),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
