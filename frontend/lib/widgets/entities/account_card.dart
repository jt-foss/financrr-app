import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../util/text_utils.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            _buildAccountAvatar(),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.name, style: context.textTheme.titleSmall),
                if (account.iban != null || account.description != null) Text(account.iban ?? account.description!),
              ],
            ),
            const Spacer(),
            Text(TextUtils.formatCurrency(account.balance, account.getCurrency()!, decimalSeparator: ','),
                style: context.textTheme.titleSmall?.copyWith(color: context.theme.primaryColor))
          ],
        ),
      ),
    );
  }

  Widget _buildAccountAvatar() {
    return CircleAvatar(
      radius: 25,
      child: Text(account.name[0].toUpperCase()),
    );
  }
}
