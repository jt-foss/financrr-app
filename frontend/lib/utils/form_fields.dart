import 'package:financrr_frontend/modules/settings/providers/theme.provider.dart';
import 'package:financrr_frontend/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../shared/models/store.dart';
import 'input_utils.dart';

/// A collection of form fields used throughout the application.
/// Typically used for both creating and editing entities.
class FormFields {
  const FormFields._();

  static List<Widget> transaction(ConsumerState state,
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
            segments: const [
              // TODO: localize
              ButtonSegment(label: Text('Deposit'), value: TransactionType.deposit),
              // TODO: localize
              ButtonSegment(label: Text('Withdrawal'), value: TransactionType.withdrawal),
              // TODO: localize
              ButtonSegment(label: Text('Transfer'), value: TransactionType.transfer),
            ],
            selected: {selectedType},
          ),
        ),
      ),
      if (selectedType == TransactionType.transfer)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField(
              // TODO: localize
              decoration: const InputDecoration(labelText: 'Transfer To'),
              // TODO: localize
              validator: (value) => InputValidators.nonNull('Transfer To', value?.id.value.toString()),
              items: currentAccount.api
                  .getAccounts()
                  .where((account) => account.id.value != currentAccount.id.value)
                  .map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name, style: state.ref.textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: onSecondaryChanged,
            )),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: amountController,
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Amount'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Amount', value),
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Name'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Name', value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
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
          decoration: const InputDecoration(labelText: 'Executed At'),
        ),
      )
    ];
  }

  static List<Widget> account(WidgetRef ref,
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Name'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Name', value),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          inputFormatters: [
            LengthLimitingTextInputFormatter(64),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextFormField(
          controller: ibanController,
          decoration: const InputDecoration(labelText: 'IBAN'),
          validator: (value) =>
              value == null || value.trim().isEmpty || TextUtils.formatIBAN(value) != null ? null : 'Invalid IBAN',
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Original Balance'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Original Balance', value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField(
            // TODO: localize
            decoration: const InputDecoration(labelText: 'Currency'),
            // TODO: localize
            validator: (value) => InputValidators.nonNull('Currency', value?.id.value.toString()),
            value: initialCurrency,
            items: api.getCurrencies().map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text('${currency.name} (${currency.symbol})', style: ref.textTheme.bodyMedium),
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Name'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Name', value),
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Symbol'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Symbol', value),
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'ISO Code'),
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
          // TODO: localize
          decoration: const InputDecoration(labelText: 'Decimal Places'),
          // TODO: localize
          validator: (value) => InputValidators.nonNull('Decimal Places', value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
        ),
      ),
    ];
  }
}
