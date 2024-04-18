import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/util/form_fields.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../../../layout/adaptive_scaffold.dart';
import '../../../../data/store.dart';
import '../../../../widgets/async_wrapper.dart';
import '../../../../widgets/entities/transaction_card.dart';

@RoutePage()
class TransactionCreatePage extends StatefulWidget {
  final String? accountId;

  const TransactionCreatePage({super.key, required this.accountId});

  @override
  State<StatefulWidget> createState() => _TransactionCreatePageState();
}

class _TransactionCreatePageState extends State<TransactionCreatePage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final GlobalKey<FormState> _formKey = GlobalKey();
  late final Restrr _api = context.api!;

  late final TextEditingController _nameController = TextEditingController(text: 'Transaction');
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _executedAtController;

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
    _executedAtController = TextEditingController(text: StoreKey.dateTimeFormat.readSync()!.format(_executedAt));
    _fetchAccount();
    _isValid = _formKey.currentState?.validate() ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _executedAtController.dispose();
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
                TransactionCard.fromData(
                  id: 0,
                  amount: int.tryParse(_amountController.text) ?? 0,
                  account: account,
                  name: _nameController.text,
                  description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                  type: _type,
                  createdAt: DateTime.now(),
                  executedAt: _executedAt,
                  interactive: false,
                ),
                const Divider(),
                ...FormFields.transaction(
                  context,
                  currentAccount: account,
                  nameController: _nameController,
                  amountController: _amountController,
                  descriptionController: _descriptionController,
                  executedAtController: _executedAtController,
                  selectedType: _type,
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

  Future<void> _createTransaction(Account account, TransactionType type, {Account? secondary}) async {
    if (!_isValid) return;
    final (Id?, Id?) sourceAndDest = switch (_type) {
      TransactionType.deposit => (null, account.id.value),
      TransactionType.withdrawal => (account.id.value, null),
      TransactionType.transfer => (account.id.value, secondary!.id.value),
    };
    try {
      await _api.createTransaction(
          sourceId: sourceAndDest.$1,
          destinationId: sourceAndDest.$2,
          amount: int.parse(_amountController.text),
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          executedAt: _executedAt,
          currencyId: account.currencyId.value);
      if (!mounted) return;
      context.showSnackBar('Successfully created transaction');
      context.maybePop();
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
