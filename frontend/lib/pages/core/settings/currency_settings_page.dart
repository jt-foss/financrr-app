import 'dart:async';

import 'package:financrr_frontend/layout/scaffold_navbar_shell.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:financrr_frontend/widgets/paginated_table.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../../../widgets/paginated_wrapper.dart';
import '../settings_page.dart';

class CurrencySettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'currency');

  const CurrencySettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
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
              const Divider(),
              PaginatedTable(
                api: _api,
                initialPageFunction: (api) => api.retrieveAllCurrencies(limit: 10),
                fillWithEmptyRows: true,
                width: size.width,
                columns: const [
                  DataColumn(label: Text('Symbol')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('ISO')),
                ],
                rowBuilder: (currency) => DataRow(cells: [
                  DataCell(Text(currency.symbol)),
                  DataCell(Text(currency.name)),
                  DataCell(Text(currency.isoCode)),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
