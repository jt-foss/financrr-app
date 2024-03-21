import 'dart:async';

import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/async_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../layout/adaptive_scaffold.dart';
import '../../router.dart';

class DashboardPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder('/@me/dashboard');

  const DashboardPage({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final Restrr _api = context.api!;

  final StreamController<Paginated<Transaction>> _transactionStreamController = StreamController.broadcast();

  Future<Paginated<Transaction>> _fetchLatestTransactions({bool forceRetrieve = false}) async {
    final Paginated<Transaction> transactions = await _api.retrieveAllTransactions(limit: 10, forceRetrieve: forceRetrieve);
    _transactionStreamController.add(transactions);
    return transactions;
  }

  @override
  void initState() {
    super.initState();
    _fetchLatestTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView(
            children: [
              Text('Quick Actions', style: context.textTheme.titleMedium),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 75,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (_, index) => _buildQuickActionButton(),
                    separatorBuilder: (_, __) => const SizedBox(width: 20)
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('Account and Cards', style: context.textTheme.titleMedium),
              ),
              for (Account a in _api.getAccounts())
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.theme.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text(a.name[0])),
                      ),
                      title: Text(a.name),
                      subtitle: a.iban == null && a.description == null ? null : Text(a.iban ?? a.description!),
                      trailing: Text('${a.balance.toStringAsFixed(2)}€'),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text('Latest Transactions', style: context.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: StreamWrapper<Paginated<Transaction>>(
                  stream: _transactionStreamController.stream,
                  onError: (context, snap) => const Text('Error'),
                  onLoading: (context, snap) => const Center(child: CircularProgressIndicator()),
                  onSuccess: (context, snap) {
                    return Column(
                    children: [
                      for (Transaction t in snap.data!.items)
                        ListTile(
                          title: Text(t.description ?? 'Transaction'),
                          subtitle: Text(t.amount.toString()),
                          trailing: Text(t.executedAt.toIso8601String()),
                        )
                    ],
                  );
                  }
                ),
              )
            ]
          )
        ),
      ),
    );
  }

  Widget _buildQuickActionButton() {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            shape: BoxShape.circle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: const Text('Action'),
        )
      ],
    );
  }
}
