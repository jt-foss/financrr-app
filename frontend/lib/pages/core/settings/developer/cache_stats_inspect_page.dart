import 'package:financrr_frontend/pages/core/settings/developer/cache_stats_settings_page.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restrr/restrr.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';

class CacheStatsInspectPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: CacheStatsPage.pagePath, path: 'inspect');

  final EntityCacheStrategy? cacheStrategy;

  const CacheStatsInspectPage({super.key, required this.cacheStrategy});

  @override
  State<StatefulWidget> createState() => _CacheStatsInspectPageState();
}

class _CacheStatsInspectPageState extends State<CacheStatsInspectPage> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => SafeArea(child: _buildVerticalLayout(size)),
    );
  }

  Widget _buildVerticalLayout(Size size) {
    if (widget.cacheStrategy == null) {
      return const Center(
        child: NoticeCard(
          iconData: Icons.warning_amber_outlined,
          title: 'No Cache Strategy',
          description: 'No cache strategy was provided for this page.',
        )
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          width: size.width / 1.1,
          child: ListView.separated(
            separatorBuilder: (_, __) => const Divider(),
            itemCount: widget.cacheStrategy!.getAll().length,
            itemBuilder: (_, index) {
              final dynamic entity = widget.cacheStrategy!.getAll()[index];
              final String s = entity.toString();
              return ListTile(
                title: Text(entity.runtimeType.toString(), style: context.textTheme.titleSmall),
                subtitle: Text(s.replaceAll(entity.runtimeType.toString(), '')),
                onTap: () async {
                  context.showSnackBar('Copied to clipboard!');
                  await Clipboard.setData(ClipboardData(text: s));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
