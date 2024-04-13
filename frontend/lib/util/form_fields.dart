import 'package:financrr_frontend/data/bloc/repository_bloc.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restrr/restrr.dart';

import 'input_utils.dart';

/// A collection of form fields used throughout the application.
/// Typically used for both creating and editing entities.
class FormFields {
  const FormFields._();

  static List<Widget> transaction(BuildContext context,
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
              ButtonSegment(label: Text('Deposit'), value: TransactionType.deposit),
              ButtonSegment(label: Text('Withdrawal'), value: TransactionType.withdrawal),
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
              decoration: const InputDecoration(labelText: 'Transfer To'),
              validator: (value) => InputValidators.nonNull('Transfer To', value?.id.value.toString()),
              items: currentAccount.api
                  .getAccounts()
                  .where((account) => account.id.value != currentAccount.id.value)
                  .map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name, style: context.textTheme.bodyMedium),
                );
              }).toList(),
              onChanged: onSecondaryChanged,
            )),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
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
          decoration: const InputDecoration(labelText: 'Name'),
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
      BlocBuilder<RepositoryBloc, RepositoryState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextFormField(
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  firstDate: (executedAt ?? DateTime.now()).subtract(const Duration(days: 365)),
                  lastDate: (executedAt ?? DateTime.now()).add(const Duration(days: 365)),
                );
                if (date == null) return;
                final TimeOfDay? time = await showTimePicker(
                    context: context, initialTime: executedAt != null ? TimeOfDay.fromDateTime(executedAt) : TimeOfDay.now());
                if (time == null) return;
                onExecutedAtChanged?.call(date.copyWith(hour: time.hour, minute: time.minute));
              },
              initialValue: state.dateTimeFormat.format(executedAt ?? DateTime.now()),
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Executed At'),
            ),
          );
        },
      ),
    ];
  }

  static List<Widget> account(BuildContext context,
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
          decoration: const InputDecoration(labelText: 'Name'),
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
          decoration: const InputDecoration(labelText: 'Original Balance'),
          validator: (value) => InputValidators.nonNull('Original Balance', value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField(
            decoration: const InputDecoration(labelText: 'Currency'),
            validator: (value) => InputValidators.nonNull('Currency', value?.id.value.toString()),
            value: initialCurrency,
            items: api.getCurrencies().map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text('${currency.name} (${currency.symbol})', style: context.textTheme.bodyMedium),
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
          decoration: const InputDecoration(labelText: 'Name'),
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
          decoration: const InputDecoration(labelText: 'Symbol'),
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
          decoration: const InputDecoration(labelText: 'Decimal Places'),
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
