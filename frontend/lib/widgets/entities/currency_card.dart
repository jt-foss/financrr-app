import 'package:financrr_frontend/pages/core/settings/currency/currency_edit_page.dart';
import 'package:financrr_frontend/router.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/text_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restrr/restrr.dart';

import '../../pages/core/settings/l10n/bloc/l10n_bloc.dart';

class CurrencyCard extends StatelessWidget {
  final Id id;
  final String name;
  final String symbol;
  final int decimalPlaces;
  final String? isoCode;
  final bool isCustom;
  final bool interactive;
  final Function()? onDelete;

  CurrencyCard({super.key, required Currency currency, this.interactive = true, this.onDelete})
      : id = currency.id.value,
        name = currency.name,
        symbol = currency.symbol,
        decimalPlaces = currency.decimalPlaces,
        isoCode = currency.isoCode,
        isCustom = currency is CustomCurrency;

  const CurrencyCard.fromData(
      {super.key,
      required this.id,
      required this.name,
      required this.symbol,
      required this.decimalPlaces,
      this.isoCode,
      required this.isCustom,
      this.interactive = true,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<L10nBloc, L10nState>(
      builder: (context, state) {
        return Card.outlined(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                TextCircleAvatar(text: symbol, radius: 25),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.textTheme.titleSmall),
                    if (isoCode != null) Text(isoCode!),
                  ],
                ),
                const Spacer(),
                PopupMenuButton(
                  enabled: interactive && isCustom,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: () => context.goPath(CurrencyEditPage.pagePath.build(pathParams: {'currencyId': id.toString()})),
                        child: const Text('Edit'),
                      ),
                      if (onDelete != null)
                        PopupMenuItem(
                          onTap: onDelete,
                          child: const Text('Delete'),
                        ),
                    ];
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
