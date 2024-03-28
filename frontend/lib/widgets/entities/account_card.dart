import 'dart:math';

import 'package:financrr_frontend/pages/core/accounts/account_page.dart';
import 'package:financrr_frontend/router.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../util/text_utils.dart';

class AccountCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !interactive
          ? null
          : () => context.goPath(AccountPage.pagePath.build(pathParams: {'accountId': id.toString()})),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              _buildAccountAvatar(name),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.textTheme.titleSmall),
                  if (iban != null || description != null) Text(TextUtils.formatIBAN(iban) ?? description!),
                ],
              ),
              const Spacer(),
              Text(TextUtils.formatCurrency(balance, currency!),
                  style: context.textTheme.titleSmall?.copyWith(color: context.theme.primaryColor))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountAvatar(String accountName) {
    return CircleAvatar(
      radius: 25,
      child: Text(accountName.isEmpty ? '?' : accountName.substring(0, min(accountName.length, 2)).toUpperCase()),
    );
  }
}
