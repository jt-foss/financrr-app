import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../modules/settings/models/theme.state.dart';
import '../shared/models/store.dart';
import 'input_utils.dart';

/// A collection of form fields used throughout the application.
/// Typically used for both creating and editing entities.
class FormFields {
  const FormFields._();

  static List<Widget> transaction(ConsumerState state,
      ThemeState theme,
      {required Account currentAccount,
      required TextEditingController nameController,
      required TextEditingController amountController,
      required TextEditingController descriptionController,
      required TextEditingController executedAtController,
      required TransactionType selectedType,
      DateTime? executedAt,
      Function(Set<TransactionType>)? onSelectionChanged,
      Function(Account?)? onSecondaryChanged,
      Function(DateTime)? onExecutedAtChanged}) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: SegmentedButton(
            onSelectionChanged: onSelectionChanged,
            segments: [
              ButtonSegment(label: L10nKey.transactionCreateDeposit.toText(), value: TransactionType.deposit),
              ButtonSegment(label: L10nKey.transactionCreateWithdrawal.toText(), value: TransactionType.withdrawal),
              ButtonSegment(label: L10nKey.transactionCreateTransfer.toText(), value: TransactionType.transfer),
            ],
            selected: {selectedType},
          ),
        ),
      ),
      if (selectedType == TransactionType.transfer)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField(
              decoration: InputDecoration(labelText: L10nKey.transactionCreateTransferTo.toString()),
              validator: (value) => InputValidators.nonNull(L10nKey.transactionCreateTransferTo.toString(), value?.id.value.toString()),
              items: currentAccount.api
                  .getAccounts()
                  .where((account) => account.id.value != currentAccount.id.value)
                  .map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name, style: theme.textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: onSecondaryChanged,
            )),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: amountController,
          decoration: InputDecoration(labelText: L10nKey.transactionPropertiesAmount.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.transactionPropertiesAmount.toString(), value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: nameController,
          decoration: InputDecoration(labelText: L10nKey.transactionPropertiesName.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.transactionPropertiesName.toString(), value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: L10nKey.transactionPropertiesDescription.toString()),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          onTap: () async {
            final DateTime? date = await showDatePicker(
              context: state.context,
              firstDate: (executedAt ?? DateTime.now()).subtract(const Duration(days: 365)),
              lastDate: (executedAt ?? DateTime.now()).add(const Duration(days: 365)),
            );
            if (date == null || !state.mounted) return;
            final TimeOfDay? time = await showTimePicker(
                context: state.context, initialTime: executedAt != null ? TimeOfDay.fromDateTime(executedAt) : TimeOfDay.now());
            if (time == null) return;
            onExecutedAtChanged?.call(date.copyWith(hour: time.hour, minute: time.minute));
          },
          initialValue: StoreKey.dateTimeFormat.readSync()!.format(executedAt ?? DateTime.now()),
          readOnly: true,
          decoration: InputDecoration(labelText: L10nKey.transactionPropertiesExecutedAt.toString()),
        ),
      )
    ];
  }

  static List<Widget> account(WidgetRef ref,
      ThemeState theme,
      {required Restrr api,
      required TextEditingController nameController,
      required TextEditingController descriptionController,
      required TextEditingController ibanController,
      required TextEditingController originalBalanceController,
      void Function(Currency?)? onCurrencyChanged,
      Currency? initialCurrency}) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: nameController,
          decoration: InputDecoration(labelText: L10nKey.accountPropertiesName.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.accountPropertiesName.toString(), value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(labelText: L10nKey.accountPropertiesDescription.toString()),
          inputFormatters: [
            LengthLimitingTextInputFormatter(64),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: ibanController,
          decoration: InputDecoration(labelText: L10nKey.accountPropertiesIban.toString()),
          validator: (value) => InputValidators.iban(value),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(22),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: originalBalanceController,
          decoration: InputDecoration(labelText: L10nKey.accountPropertiesOriginalBalance.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.accountPropertiesOriginalBalance.toString(), value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField(
            decoration: InputDecoration(labelText: L10nKey.accountPropertiesCurrency.toString()),
            validator: (value) => InputValidators.nonNull(L10nKey.accountPropertiesCurrency.toString(), value?.id.value.toString()),
            value: initialCurrency,
            items: api.getCurrencies().map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text('${currency.name} (${currency.symbol})', style: theme.textTheme.bodyMedium),
              );
            }).toList(),
            onChanged: onCurrencyChanged),
      )
    ];
  }

  static List<Widget> currency(
      {required TextEditingController nameController,
      required TextEditingController symbolController,
      required TextEditingController isoCodeController,
      required TextEditingController decimalPlacesController,
      bool readOnly = false}) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: nameController,
          readOnly: readOnly,
          decoration: InputDecoration(labelText: L10nKey.currencyPropertiesName.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.currencyPropertiesName.toString(), value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: symbolController,
          readOnly: readOnly,
          decoration: InputDecoration(labelText: L10nKey.currencyPropertiesSymbol.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.currencyPropertiesSymbol.toString(), value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: isoCodeController,
          readOnly: readOnly,
          decoration: InputDecoration(labelText: L10nKey.currencyPropertiesIsoCode.toString()),
          inputFormatters: [
            LengthLimitingTextInputFormatter(3),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: decimalPlacesController,
          readOnly: readOnly,
          decoration: InputDecoration(labelText: L10nKey.currencyPropertiesDecimalPlaces.toString()),
          validator: (value) => InputValidators.nonNull(L10nKey.currencyPropertiesDecimalPlaces.toString(), value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
        ),
      ),
    ];
  }
}
