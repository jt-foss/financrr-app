import 'package:financrr_frontend/router.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../data/l10n_repository.dart';
import '../../pages/core/accounts/transactions/transaction_page.dart';
import '../../util/text_utils.dart';

class TransactionCard extends StatelessWidget {
  final Id id;
  final Id? source;
  final Id? destination;
  final int amount;
  final String name;
  final String? description;
  final DateTime executedAt;
  final DateTime createdAt;
  final Account account;
  final TransactionType type;

  final bool interactive;

  TransactionCard({super.key, required Transaction transaction, this.interactive = true})
      : id = transaction.id.value,
        source = transaction.sourceId?.value,
        destination = transaction.destinationId?.value,
        amount = transaction.amount,
        name = transaction.name,
        description = transaction.description,
        executedAt = transaction.executedAt,
        createdAt = transaction.createdAt,
        account = (transaction.sourceId ?? transaction.destinationId)!.get()!,
        type = transaction.type;

  const TransactionCard.fromData(
      {super.key,
      required this.id,
      this.source,
      this.destination,
      required this.amount,
      required this.name,
      required this.description,
      required this.executedAt,
      required this.createdAt,
      required this.account,
      required this.type,
      this.interactive = true});

  @override
  Widget build(BuildContext context) {
    final String amountStr = TextUtils.formatCurrency(amount, account.currencyId.get()!);
    return GestureDetector(
      onTap: !interactive
          ? null
          : () => context.goPath(TransactionPage.pagePath
              .build(pathParams: {'accountId': account.id.value.toString(), 'transactionId': id.toString()})),
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: context.textTheme.titleSmall),
              if (description != null) Text(description!, style: context.textTheme.bodyMedium),
              Text(TextUtils.formatIBAN(account.iban) ?? account.name),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(dateTimeFormat.format(executedAt)),
                  Text('${type == TransactionType.deposit ? '' : '-'}$amountStr',
                      style: context.textTheme.titleMedium?.copyWith(
                          color: type == TransactionType.deposit
                              ? context.theme.primaryColor
                              : context.theme.colorScheme.error)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
