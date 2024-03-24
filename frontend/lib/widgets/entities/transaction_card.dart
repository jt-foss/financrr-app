import 'package:easy_localization/easy_localization.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restrr/restrr.dart';

import '../../util/text_utils.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final String amount = TextUtils.formatCurrency(transaction.amount, _getEffectiveAccount().getCurrency()!, decimalSeparator: ',');
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.description ?? 'UNKNOWN', style: context.textTheme.titleSmall),
            Text(_getEffectiveAccount().iban ?? _getEffectiveAccount().name),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('dd.mm.yyyy HH:mm').format(transaction.executedAt)),
                Text('${transaction.type == TransactionType.deposit ? '' : '-'}$amount',
                    style: context.textTheme.titleSmall?.copyWith(color: context.theme.primaryColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Account _getEffectiveAccount() {
    return transaction.getSourceAccount() ?? transaction.getDestinationAccount()!;
  }
}
