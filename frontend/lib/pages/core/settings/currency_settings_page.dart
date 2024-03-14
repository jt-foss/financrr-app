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
  final StreamController<List<Currency>> _currenciesController = StreamController<List<Currency>>.broadcast();

  late final Restrr _api = context.api!;

  @override
  void initState() {
    super.initState();
    _api.retrieveAllCurrencies().then((currencies) => _currenciesController.sink.add(currencies ?? []));
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
                  final List<Currency> currencies = snap.data as List<Currency>;
                  final Currency preferredCurrency =
                      currencies.firstWhere((c) => c.isoCode == 'EUR', orElse: () => currencies.first);
                  final List<Currency> customCurrencies =
                      currencies.where((c) => c.isCustom && c != preferredCurrency).toList();
                  final List<Currency> defaultCurrencies =
                      currencies.where((c) => !c.isCustom && c != preferredCurrency).toList();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: [
                      _buildCurrencyCard(preferredCurrency, isPreferred: true),
                      Card.outlined(
                        child: ListTile(
                          title: Text('${customCurrencies.length} custom currencies'),
                          trailing: TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/@me/settings/currency/add'),
                            child: const Text('Add'),
                          ),
                        ),
                      ),
                      for (final currency in customCurrencies) _buildCurrencyCard(currency),
                      const Divider(),
                      for (final currency in defaultCurrencies) _buildCurrencyCard(currency),
                    ]),
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
