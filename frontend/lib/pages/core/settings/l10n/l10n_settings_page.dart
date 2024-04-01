import 'package:financrr_frontend/util/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';
import '../../settings_page.dart';
import 'bloc/l10n_bloc.dart';

class L10nSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'languages');

  const L10nSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _L10nSettingsPageState();
}

class _L10nSettingsPageState extends State<L10nSettingsPage> {
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
          child: BlocBuilder<L10nBloc, L10nState>(
            builder: (context, state) {
              return ListView(
                children: [
                  Card.outlined(
                    child: ListTile(
                      leading: const Text('Preview'),
                      title:
                          Text(TextUtils.formatBalance(12345678, 2, state.decimalSeparator, state.thousandSeparator)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextFormField(
                      initialValue: state.decimalSeparator,
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        context.read<L10nBloc>().add(L10nDecimalSeparatorChanged(value));
                      },
                      decoration: const InputDecoration(
                        labelText: 'Decimal Separator',
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(1)],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                      initialValue: state.thousandSeparator,
                      onChanged: (value) {
                        if (value.isEmpty) return;
                        context.read<L10nBloc>().add(L10nThousandSeparatorChanged(value));
                      },
                      decoration: const InputDecoration(
                        labelText: 'Thousands Separator',
                      ),
                      inputFormatters: [LengthLimitingTextInputFormatter(1)],
                    ),
                  ),
                  const Divider(),
                  Card.outlined(
                    child: ListTile(
                      leading: const Text('Preview'),
                      title: Text(state.dateTimeFormat.format(DateTime.now())),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextFormField(
                        initialValue: state.dateTimeFormat.pattern,
                        onChanged: (value) {
                          if (value.isEmpty) return;
                          context.read<L10nBloc>().add(L10nDateTimeFormatChanged(value));
                        },
                        decoration: const InputDecoration(
                          labelText: 'Date Format',
                        )),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
