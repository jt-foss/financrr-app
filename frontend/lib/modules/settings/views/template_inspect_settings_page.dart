import 'dart:async';

import 'package:financrr_frontend/modules/auth/providers/authentication.provider.dart';
import 'package:financrr_frontend/modules/settings/views/template_overview_settings_page.dart';
import 'package:financrr_frontend/utils/extensions.dart';
import 'package:financrr_frontend/utils/l10n_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../shared/models/store.dart';
import '../../../shared/ui/adaptive_scaffold.dart';
import '../../../../routing/page_path.dart';
import '../../../shared/ui/async_wrapper.dart';
import '../../../shared/ui/links/account_link.dart';
import '../providers/l10n.provider.dart';
import '../providers/theme.provider.dart';

class TemplateInspectSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath =
      PagePathBuilder.child(parent: TemplateOverviewSettingsPage.pagePath, path: ':templateId');

  final String? templateId;

  const TemplateInspectSettingsPage({super.key, required this.templateId});

  @override
  ConsumerState<TemplateInspectSettingsPage> createState() => _TemplateInspectSettingsPageState();
}

class _TemplateInspectSettingsPageState extends ConsumerState<TemplateInspectSettingsPage> {
  final StreamController<TransactionTemplate> _templateStreamController = StreamController.broadcast();
  late final Restrr _api = api;

  Future<TransactionTemplate?> _fetchTemplate({bool forceRetrieve = false}) async {
    return _templateStreamController.fetchData(
        widget.templateId, (id) => _api.retrieveTransactionTemplateById(id, forceRetrieve: forceRetrieve));
  }

  @override
  void initState() {
    super.initState();
    _fetchTemplate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = ref.watch(themeProvider);
    var l10n = ref.watch(l10nProvider);

    buildTableRow(L10nKey label, dynamic value) {
      return TableRow(children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: label.toText(
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: value is Account ? AccountLink(account: value) : Text(value),
        ),
      ]);
    }

    buildVerticalLayout(TransactionTemplate template, Size size) {
      final Currency currency = (template.sourceId ?? template.destinationId!).get()!.currencyId.get()!;
      final String amountStr =
          template.amount.formatWithCurrency(currency, l10n.decimalSeparator, thousandsSeparator: l10n.thousandSeparator);

      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Center(
          child: SizedBox(
            width: size.width / 1.1,
            child: ListView(
              children: [
                Column(
                  children: [
                    L10nKey.templateTitleTransfer.toStyledText(ref, style: theme.textTheme.titleMedium, namedArgs: {
                      'amount': amountStr,
                      'source': template.sourceId?.get()?.name ?? 'N/A',
                      'destination': template.destinationId?.get()?.name ?? 'N/A'
                    }),
                    if (template.description != null) Text(template.description!),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(tooltip: 'Execute now', onPressed: () {}, icon: const Icon(Icons.play_arrow_outlined, size: 17)),
                    IconButton(
                      tooltip: 'Schedule',
                      onPressed: () {},
                      icon: const Icon(Icons.schedule_rounded, size: 17),
                    ),
                    const Spacer(),
                    IconButton(
                        tooltip: 'Delete Template',
                        onPressed: () => _deleteTemplate(template),
                        icon: const Icon(Icons.delete_outline, size: 17)),
                    IconButton(tooltip: 'Edit Template', onPressed: () {}, icon: const Icon(Icons.create_outlined, size: 17))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Table(
                    border: TableBorder.all(
                        borderRadius: BorderRadius.circular(10), color: theme.financrrExtension.surfaceVariant1, width: 3),
                    children: [
                      buildTableRow(L10nKey.transactionPropertiesAmount, amountStr),
                      buildTableRow(L10nKey.transactionPropertiesName, template.name),
                      buildTableRow(L10nKey.transactionPropertiesDescription, template.description ?? 'N/A'),
                      buildTableRow(L10nKey.transactionPropertiesFrom, template.sourceId?.get() ?? 'N/A'),
                      buildTableRow(L10nKey.transactionPropertiesTo, template.destinationId?.get() ?? 'N/A'),
                      buildTableRow(L10nKey.transactionPropertiesCreatedAt,
                          StoreKey.dateTimeFormat.readSync()!.format(template.createdAt)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    handleTemplateStream(Size size) {
      return StreamWrapper(
          stream: _templateStreamController.stream,
          onSuccess: (_, snap) => buildVerticalLayout(snap.data!, size),
          onLoading: (_, __) => const Center(child: CircularProgressIndicator()),
          onError: (_, __) => L10nKey.templateNotFound.toText());
    }

    return AdaptiveScaffold(
      resizeToAvoidBottomInset: false,
      verticalBuilder: (_, __, size) => handleTemplateStream(size),
    );
  }

  void _deleteTemplate(TransactionTemplate template) async {
    try {
      await template.delete();
      if (!mounted) return;
      L10nKey.commonDeleteObjectSuccess.showSnack(context, namedArgs: {'object': template.name});
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
