import 'dart:async';

import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';

class CurrencySettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/settings/currency');

  const CurrencySettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
  final StreamController<Paginated<Currency>> _currenciesController = StreamController<Paginated<Currency>>.broadcast();

  late final Restrr _api = context.api!;

  @override
  void initState() {
    super.initState();
    _api.retrieveAllCurrencies().then((currencies) => _currenciesController.sink.add(currencies));
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Currencies'),
          actions: [
            IconButton(
              tooltip: 'Add custom currency',
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).pushNamed('/@me/settings/currency/add'),
            ),
          ],
        ),
        body: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: SingleChildScrollView(
              child: StreamWrapper(
                stream: _currenciesController.stream,
                onError: (context, snap) => const Text('Error'),
                onLoading: (context, snap) => const CircularProgressIndicator(),
                onSuccess: (context, snap) {
                  final Paginated<Currency> currencyPage = snap.data as Paginated<Currency>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: PaginatedDataTable(
                      header: const Text('Currencies'),
                      columns: const [
                        DataColumn(label: Text('Symbol')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('ISO Code')),
                      ],
                      source: _CurrencyDataSource(currencyPage),
                    )
                  );
                },
              ),
            ),
          ),
        ));
  }

  Widget _buildCurrencyCard(Currency currency, {bool isPreferred = false}) {
    return Card.outlined(
      child: ListTile(
        leading: Text(currency.symbol),
        title: Text(currency.name),
        subtitle: Text(currency.isoCode),
        trailing: isPreferred ? const Text('Preferred') : null,
      ),
    );
  }
}

class _CurrencyDataSource extends DataTableSource {
  final Paginated<Currency> currencies;

  _CurrencyDataSource(this.currencies);

  @override
  int get rowCount => currencies.limit;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow? getRow(int index) {
    if (index >= currencies.length) {
      return null;
    }
    final Currency currency = currencies.items[index];
    return DataRow(
      cells: [
        DataCell(Text(currency.symbol)),
        DataCell(Text(currency.name)),
        DataCell(Text(currency.isoCode)),
      ],
    );
  }
}
