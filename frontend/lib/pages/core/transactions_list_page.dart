import 'dart:async';

import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';
import '../../widgets/paginated_table.dart';

class TransactionListPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/account/{accountId}/transactions');

  final String? accountId;

  const TransactionListPage({super.key, required this.accountId});

  @override
  State<StatefulWidget> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final StreamController<Account> _accountStreamController = StreamController.broadcast();
  final GlobalKey<PaginatedTableState<Account>> _tableKey = GlobalKey();
  late final Restrr _api = context.api!;

  Future<Account?> _fetchAccount({bool forceRetrieve = false}) async {
    return _accountStreamController.fetchData(
        widget.accountId, (id) => _api.retrieveAccountById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();
    _fetchAccount();
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
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView(
            children: [
              Card(
                child: ListTile(
                  title: const Text('Selected Account'),
                  trailing: DropdownMenu(
                    initialSelection: account,
                    dropdownMenuEntries: _api.getAccounts().map((account) {
                      return DropdownMenuEntry(
                        value: account,
                        label: account.name,
                      );
                    }).toList(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    label: const Text('Create'),
                    icon: const Icon(Icons.create_rounded),
                  ),
                  TextButton.icon(
                    onPressed: () => _tableKey.currentState?.reset(),
                    label: const Text('Refresh'),
                    icon: const Icon(Icons.refresh),
                  )
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: PaginatedTable(
                  key: _tableKey,
                  api: _api,
                  initialPageFunction: (api) => account.retrieveAllTransactions(limit: 10),
                  fillWithEmptyRows: true,
                  width: size.width,
                  columns: const [
                    DataColumn(label: Text('Id')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rowBuilder: (transaction) {
                    return DataRow(cells: [
                      DataCell(Text(transaction.id.toString())),
                      DataCell(Text(transaction.amount.toString())),
                    ]);
                  },
                ),
              )
            ]
          )
        ),
      ),
    );
  }
}
