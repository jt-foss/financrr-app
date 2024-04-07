import 'package:financrr_frontend/cache/cache_service.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:flutter/material.dart';
import 'package:restrr/restrr.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';
import '../../settings_page.dart';
import 'cache_stats_inspect_page.dart';

class CacheStatsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'cache-stats');

  const CacheStatsPage({super.key});

  @override
  State<StatefulWidget> createState() => _CacheStatsPageState();
}

class _CacheStatsPageState extends State<CacheStatsPage> {
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
              _buildCacheStats('Accounts', CacheService.accountCache),
              _buildCacheStats('Transactions', CacheService.transactionCache),
              _buildCacheStats('Users', CacheService.userCache),
              _buildCacheStats('Sessions', CacheService.sessionCache),
              _buildCacheStats('Currencies', CacheService.currencyCache),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCacheStats<E extends RestrrEntity<E, ID>, ID extends EntityId<E>>(
      String title, DefaultEntityCacheStrategy<E, ID> cache) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: context.textTheme.titleSmall),
              const Spacer(),
              Text('${cache.getAll().length.toString()} cached'),
              PopupMenuButton(itemBuilder: (context) {
                return [
                  PopupMenuItem(
                      onTap: () {
                        cache.invalidate();
                        setState(() {});
                      },
                      child: const Text('Invalidate Cache')),
                  PopupMenuItem(
                      onTap: () => context.goPath(CacheStatsInspectPage.pagePath.build(), extra: cache),
                      child: Text('Inspect "$title"'))
                ];
              })
            ],
          ),
          const Divider(),
          if (cache.pageCache.isNotEmpty)
            Table(
            border: TableBorder.all(color: context.theme.dividerColor),
            children: [
              const TableRow(children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Page'),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Size'),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Amount'),
                ),
              ]),
              for (MapEntry<(int, int), List<Id>> entry in cache.pageCache.entries)
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(entry.key.$1.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(entry.key.$2.toString()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text('${entry.value.length}'),
                  ),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}
