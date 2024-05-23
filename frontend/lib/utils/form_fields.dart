import 'package:financrr_frontend/shared/ui/custom_replacements/custom_text_field.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../modules/settings/models/themes/theme.state.dart';
import '../shared/models/store.dart';
import 'input_utils.dart';

/// A collection of form fields used throughout the application.
/// Typically used for both creating and editing entities.
class FormFields {
  const FormFields._();

  static List<Widget> transaction(ConsumerState state, ThemeState theme,
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
              validator: (value) =>
                  InputValidators.nonNull(L10nKey.transactionCreateTransferTo.toString(), value?.id.value.toString()),
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
        child: FinancrrTextField(
          controller: amountController,
          label: L10nKey.transactionPropertiesAmount,
          validator: (value) => InputValidators.nonNull(L10nKey.transactionPropertiesAmount.toString(), value),
          required: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: nameController,
          label: L10nKey.transactionPropertiesName,
          validator: (value) => InputValidators.nonNull(L10nKey.transactionPropertiesName.toString(), value),
          required: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: descriptionController,
          label: L10nKey.transactionPropertiesDescription,
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
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
          label: L10nKey.transactionPropertiesExecutedAt,
        ),
      )
    ];
  }

  static List<Widget> account(WidgetRef ref, ThemeState theme,
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
        child: FinancrrTextField(
          controller: nameController,
          label: L10nKey.accountPropertiesName,
          validator: (value) => InputValidators.nonNull(L10nKey.accountPropertiesName.toString(), value),
          required: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: descriptionController,
          label: L10nKey.accountPropertiesDescription,
          inputFormatters: [
            LengthLimitingTextInputFormatter(64),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: ibanController,
          label: L10nKey.accountPropertiesIban,
          validator: (value) => InputValidators.iban(value),
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            LengthLimitingTextInputFormatter(22),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: originalBalanceController,
          label: L10nKey.accountPropertiesOriginalBalance,
          validator: (value) => InputValidators.nonNull(L10nKey.accountPropertiesOriginalBalance.toString(), value),
          required: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField(
            decoration: InputDecoration(labelText: L10nKey.accountPropertiesCurrency.toString()),
            validator: (value) =>
                InputValidators.nonNull(L10nKey.accountPropertiesCurrency.toString(), value?.id.value.toString()),
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
        child: FinancrrTextField(
          controller: nameController,
          readOnly: readOnly,
          label: L10nKey.currencyPropertiesName,
          validator: (value) => InputValidators.nonNull(L10nKey.currencyPropertiesName.toString(), value),
          required: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: symbolController,
          readOnly: readOnly,
          label: L10nKey.currencyPropertiesSymbol,
          validator: (value) => InputValidators.nonNull(L10nKey.currencyPropertiesSymbol.toString(), value),
          required: true,
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: isoCodeController,
          readOnly: readOnly,
          label: L10nKey.currencyPropertiesIsoCode,
          inputFormatters: [
            LengthLimitingTextInputFormatter(3),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FinancrrTextField(
          controller: decimalPlacesController,
          readOnly: readOnly,
          label: L10nKey.currencyPropertiesDecimalPlaces,
          validator: (value) => InputValidators.nonNull(L10nKey.currencyPropertiesDecimalPlaces.toString(), value),
          required: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
        ),
      ),
    ];
  }
}
