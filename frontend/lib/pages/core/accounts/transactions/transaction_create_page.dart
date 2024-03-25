import 'dart:async';

import 'package:financrr_frontend/pages/core/accounts/account_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/input_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:restrr/restrr.dart';

import '../../../../../layout/adaptive_scaffold.dart';
import '../../../../../router.dart';
import '../../../../data/l10n_repository.dart';
import '../../../../widgets/async_wrapper.dart';
import '../../../../widgets/entities/transaction_card.dart';

class TransactionCreatePage extends StatefulWidget {
  static const PagePathBuilder pagePath =
      PagePathBuilder.child(parent: AccountPage.pagePath, path: 'transactions/create');

  final String? accountId;

  const TransactionCreatePage({super.key, required this.accountId});

  @override
  State<StatefulWidget> createState() => TransactionCreatePageState();
}

class TransactionCreatePageState extends State<TransactionCreatePage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final Restrr _api = context.api!;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isValid = false;
  TransactionType _type = TransactionType.deposit;
  DateTime _executedAt = DateTime.now();

  Future<Account?> _fetchAccount({bool forceRetrieve = false}) async {
    return _accountStreamController.fetchData(
        widget.accountId, (id) => _api.retrieveAccountById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();
    _fetchAccount();
    _isValid = _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(verticalBuilder: (_, __, size) => SafeArea(child: _handleAccountStream(size)));
  }

  Widget _handleAccountStream(Size size) {
    return StreamWrapper(
      stream: _accountStreamController.stream,
      onSuccess: (ctx, snap) {
        return _buildVerticalLayout(snap.data!, size);
      },
      onLoading: (ctx, snap) {
        return const Center(child: CircularProgressIndicator());
      },
      onError: (ctx, snap) {
        return const Text('Could not find account');
      },
    );
  }

  Widget _buildVerticalLayout(Account account, Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: size.width / 1.1,
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            onChanged: () => setState(() => _isValid = _formKey.currentState?.validate() ?? false),
            child: Column(
              children: [
                buildTransactionPreview(
                  _amountController.text,
                  _descriptionController.text,
                  account,
                  _type,
                ),
                const Divider(),
                ...buildFormFields(
                  context,
                  account,
                  _amountController,
                  _descriptionController,
                  _type,
                  false,
                  onSelectionChanged: (types) {
                    setState(() => _type = types.first);
                  },
                  onExecutedAtChanged: (date) => setState(() => _executedAt = date),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isValid ? () => _createTransaction(account, _type) : null,
                    child: const Text('Create Transaction'),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  static Widget buildTransactionPreview(String amount, String description, Account account, TransactionType type) {
    return TransactionCard.fromData(
      id: 0,
      amount: int.tryParse(amount) ?? 0,
      account: account,
      description: description.isEmpty ? null : description,
      type: type,
      createdAt: DateTime.now(),
      executedAt: DateTime.now(),
      interactive: false,
    );
  }

  static List<Widget> buildFormFields(
      BuildContext context,
      Account currentAccount,
      TextEditingController amountController,
      TextEditingController descriptionController,
      TransactionType selected,
      bool readOnly,
      {DateTime? executedAt,
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
            selected: {selected},
          ),
        ),
      ),
      if (selected == TransactionType.transfer)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Transfer To'),
              validator: (value) => InputValidators.nonNull('Transfer To', value?.id.toString()),
              items:
                  currentAccount.api.getAccounts().where((account) => account.id != currentAccount.id).map((account) {
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
          readOnly: readOnly,
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
          controller: descriptionController,
          readOnly: readOnly,
          decoration: const InputDecoration(labelText: 'Description'),
          validator: (value) => InputValidators.nonNull('Description', value),
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
              context: context,
              firstDate: (executedAt ?? DateTime.now()).subtract(const Duration(days: 365)),
              lastDate: (executedAt ?? DateTime.now()).add(const Duration(days: 365)),
            );
            if (date == null) return;
            final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: executedAt != null ? TimeOfDay.fromDateTime(executedAt) : TimeOfDay.now());
            if (time == null) return;
            onExecutedAtChanged?.call(date.copyWith(hour: time.hour, minute: time.minute));
          },
          initialValue: dateTimeFormat.format(executedAt ?? DateTime.now()),
          readOnly: true,
          decoration: const InputDecoration(labelText: 'Executed At'),
        ),
      ),
    ];
  }

  Future<void> _createTransaction(Account account, TransactionType type, {Account? secondary}) async {
    if (!_isValid) return;
    final (Id?, Id?) sourceAndDest = switch (_type) {
      TransactionType.deposit => (null, account.id),
      TransactionType.withdrawal => (account.id, null),
      TransactionType.transfer => (account.id, secondary!.id),
    };
    try {
      await _api.createTransaction(
          source: sourceAndDest.$1,
          destination: sourceAndDest.$2,
          amount: int.parse(_amountController.text),
          description: _descriptionController.text,
          executedAt: _executedAt,
          currency: account.currency);
      if (!mounted) return;
      context.showSnackBar('Successfully created transaction');
      context.pop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
