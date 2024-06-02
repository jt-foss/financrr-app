import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/routing/router_extensions.dart';
import 'package:financrr_frontend/shared/ui/custom_replacements/custom_card.dart';
import 'package:financrr_frontend/shared/ui/links/account_link.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../modules/settings/providers/l10n.provider.dart';
import '../../../modules/settings/views/template_inspect_settings_page.dart';

class TransactionTemplateCard extends ConsumerWidget {
  final Id id;
  final AccountId? source;
  final AccountId? destination;
  final UnformattedAmount amount;
  final String name;
  final String? description;
  final Function()? onDelete;

  final bool interactive;

  TransactionTemplateCard({super.key, required TransactionTemplate template, this.onDelete, this.interactive = true})
      : id = template.id.value,
        source = template.sourceId,
        destination = template.destinationId,
        amount = template.amount,
        name = template.name,
        description = template.description;

  const TransactionTemplateCard.fromData(
      {super.key,
      required this.id,
      this.source,
      this.destination,
      required this.amount,
      required this.name,
      required this.description,
      this.onDelete,
      this.interactive = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var theme = ref.watch(themeProvider);
    var l10n = ref.watch(l10nProvider);

    final AccountId effectiveId = source ?? destination!;
    final Currency currency = effectiveId.get()!.currencyId.get()!;
    const int scheduled = 3; // TODO: _api.getRecurringTransactions().where((r) => r.templateId == id).length;

    return FinancrrCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      onTap: !interactive ? null : () => context.goPath(TemplateInspectSettingsPage.pagePath.build(params: {'templateId': id.toString()})),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: theme.textTheme.titleSmall),
          if (description != null) Text(description!, style: theme.textTheme.bodyMedium),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'From '),
                source == null
                    ? TextSpan(text: 'Somewhere', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))
                    : WidgetSpan(child: AccountLink(account: source!.get()!)),
                const TextSpan(text: ' to '),
                destination == null
                    ? TextSpan(text: 'Somewhere', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))
                    : WidgetSpan(child: AccountLink(account: destination!.get()!)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: scheduled > 0 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
            children: [
              if (scheduled > 0)
                const Row(
                  children: [
                    Icon(Icons.schedule, size: 17),
                    SizedBox(width: 5),
                    Text('$scheduled scheduled')
                  ],
                ),
              Text(amount.formatWithCurrency(currency, l10n.decimalSeparator, thousandsSeparator: l10n.thousandSeparator),
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: amount.rawAmount < 0 ? theme.financrrExtension.error : theme.financrrExtension.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
