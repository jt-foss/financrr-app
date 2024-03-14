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
        ),
        body: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: SingleChildScrollView(
              child: StreamWrapper(
                stream: _currenciesController.stream,
                onError: (context, snap) => const Text('Error'),
                onLoading: (context, snap) => const CircularProgressIndicator(),
                onSuccess: (context, snap) => Column(
                  children: snap.data!
                      .map((currency) => Card.outlined(
                    child: ListTile(
                      leading: Text(currency.symbol),
                      title: Text(currency.name),
                      subtitle: Text(currency.isoCode),
                    ),
                  ))
                      .toList(),
                ),
              ),
            ),
          ),
        ));
  }
}
