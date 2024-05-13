import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/shared/ui/text_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../modules/accounts/views/account_page.dart';
import '../../modules/settings/providers/l10n.provider.dart';
import '../../utils/text_utils.dart';

class AccountCard extends ConsumerWidget {
  final Id id;
  final String name;
  final String? iban;
  final String? description;
  final int balance;
  final Currency? currency;
  final bool interactive;

  AccountCard({super.key, required Account account, this.interactive = true})
      : id = account.id.value,
        name = account.name,
        iban = account.iban,
        description = account.description,
        balance = account.balance,
        currency = account.currencyId.get();

  const AccountCard.fromData(
      {super.key,
      required this.id,
      required this.name,
      this.iban,
      this.description,
      required this.balance,
      required this.currency,
      this.interactive = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var l10n = ref.watch(l10nProvider);

    return GestureDetector(
      onTap: !interactive ? null : () => context.goPath(AccountPage.pagePath.build(params: {'accountId': id.toString()})),
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              TextCircleAvatar(text: name, radius: 25),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: theme.textTheme.titleSmall),
                    if (iban != null || description != null) Text(TextUtils.formatIBAN(iban) ?? description!),
                  ],
                ),
              ),
              Text(TextUtils.formatBalanceWithCurrency(l10n, balance, currency!),
                  style: theme.textTheme.titleSmall?.copyWith(color: theme.themeData.primaryColor))
            ],
          ),
        ),
      ),
    );
  }
}
