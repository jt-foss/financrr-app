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
              _buildCacheStats('Currencies', CacheService.currencyCache),
              _buildCacheStats('Sessions', CacheService.sessionCache),
              _buildCacheStats('Accounts', CacheService.accountCache),
              _buildCacheStats('Transactions', CacheService.transactionCache),
              _buildCacheStats('Users', CacheService.userCache),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCacheStats<E extends RestrrEntity<E, ID>, ID extends EntityId<E>>(
      String title, DefaultEntityCacheStrategy<E, ID> cache) {
    final List<IdPage> idPages = cache.pageCache.toList();
    final Set<int> distinctPageSizes = idPages.map((e) => e.pageSize).toSet();
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
                TableRow(children: [
                  _buildTableRow('Page'),
                  _buildTableRow('Size'),
                  _buildTableRow('Amount'),
                  _buildTableRow('Split?'),
                ]),
                for (IdPage page in cache.pageCache.toList())
                  TableRow(children: [
                    _buildTableRow(page.pageNumber),
                    _buildTableRow(page.pageSize),
                    _buildTableRow(page.ids.length),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(page.fromSplit ? Icons.check : Icons.close, size: 17)
                    )
                  ]),
              ],
            ),
          for (int pageSize in distinctPageSizes)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text('[$pageSize]: Next Page: ${cache.getNextPageNumber(pageSize)}'),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic value) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(value.toString()),
    );
  }
}
