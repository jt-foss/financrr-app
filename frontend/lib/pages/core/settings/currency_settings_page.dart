import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/paginated_table.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../settings_page.dart';
import 'currency/currency_create_page.dart';
import 'currency/currency_edit_page.dart';

class CurrencySettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'currency');

  const CurrencySettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
  final GlobalKey<PaginatedTableState<Currency>> _tableKey = GlobalKey();
  late final Restrr _api = context.api!;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView(
            children: [
              const Card(
                child: ListTile(
                  title: Text('Preferred Currency'),
                  trailing: Text('US\$'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => context.goPath(CurrencyCreatePage.pagePath.build()),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Currency'),
                  ),
                  TextButton.icon(
                    onPressed: () => _tableKey.currentState?.reset(),
                    label: const Text('Refresh'),
                    icon: const Icon(Icons.refresh),
                  )
                ],
              ),
              const Divider(),
              PaginatedTable(
                key: _tableKey,
                api: _api,
                initialPageFunction: (api) => api.retrieveAllCurrencies(limit: 10),
                fillWithEmptyRows: true,
                width: size.width,
                columns: const [
                  DataColumn(label: Text('Symbol')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('ISO')),
                  DataColumn(label: Text('Actions')),
                ],
                rowBuilder: (currency) {
                  return DataRow(cells: [
                    DataCell(Text(currency.symbol)),
                    DataCell(Text(currency.name)),
                    DataCell(Text(currency.isoCode ?? 'N/A')),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: currency is! CustomCurrency
                              ? null
                              : () => context
                                  .goPath(CurrencyEditPage.pagePath.build(queryParams: {'currencyId': currency.id})),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: currency is! CustomCurrency ? null : () => _deleteCurrency(currency),
                        ),
                      ],
                    )),
                  ]);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteCurrency(CustomCurrency currency) async {
    try {
      await currency.delete();
      if (!mounted) return;
      context.showSnackBar('Successfully deleted "${currency.name}"');
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
