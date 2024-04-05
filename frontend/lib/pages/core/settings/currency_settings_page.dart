import 'package:financrr_frontend/pages/authentication/bloc/authentication_bloc.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/entities/currency_card.dart';
import 'package:financrr_frontend/widgets/paginated_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../settings_page.dart';
import 'currency/currency_create_page.dart';

class CurrencySettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'currencies');

  const CurrencySettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencySettingsPageState();
}

class _CurrencySettingsPageState extends State<CurrencySettingsPage> {
  final GlobalKey<PaginatedWrapperState<Currency>> _paginatedCurrencyKey = GlobalKey();
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
          child: RefreshIndicator(
            onRefresh: () async => _paginatedCurrencyKey.currentState?.reset(),
            child: ListView(
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => context.goPath(CurrencyCreatePage.pagePath.build()),
                      icon: const Icon(Icons.add),
                      label: const Text('Create'),
                    )
                  ],
                ),
                const Divider(),
                PaginatedWrapper(
                  key: _paginatedCurrencyKey,
                  initialPageFunction: (forceRetrieve) => _api.retrieveAllCurrencies(limit: 10, forceRetrieve: forceRetrieve),
                  onSuccess: (context, snap) {
                    final PaginatedWrapperState<Currency> state = _paginatedCurrencyKey.currentState!;
                    final List<Currency> currencies = snap.data!;
                    return Column(
                      children: [
                        for (Currency c in currencies)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: CurrencyCard(currency: c, onDelete: c is! CustomCurrency ? null : () => _deleteCurrency(c)),
                          ),
                        if (state.hasNext)
                          TextButton(
                            onPressed: () => state.nextPage(_api),
                            child: const Text('Load more'),
                          ),
                      ],
                    );
                  },
                )
              ],
            ),
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
