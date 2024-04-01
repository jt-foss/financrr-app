import 'package:financrr_frontend/data/l10n_repository.dart';
import 'package:financrr_frontend/pages/authentication/bloc/authentication_bloc.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/paginated_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restrr/restrr.dart';

import '../../../layout/adaptive_scaffold.dart';
import '../../../router.dart';
import '../settings_page.dart';
import 'l10n/bloc/l10n_bloc.dart';

class SessionSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'sessions');

  const SessionSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends State<SessionSettingsPage> {
  final GlobalKey<PaginatedTableState<PartialSession>> _tableKey = GlobalKey();
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
              Card.outlined(
                child: ListTile(
                  title: const Text('Current Session'),
                  trailing: Text('Id: ${_api.session.id.value}'),
                  subtitle: _api.session.name == null ? null : Text(_api.session.name!),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _deleteAllSessions(),
                    label: const Text('Delete all & Log out'),
                    icon: const Icon(Icons.delete_sweep_rounded),
                  ),
                  TextButton.icon(
                    onPressed: () => _tableKey.currentState?.reset(),
                    label: const Text('Refresh'),
                    icon: const Icon(Icons.refresh),
                  )
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: BlocBuilder<L10nBloc, L10nState>(
                  builder: (context, state) {
                    return PaginatedTable(
                      key: _tableKey,
                      api: _api,
                      initialPageFunction: (forceRetrieve) =>
                          _api.retrieveAllSessions(limit: 10, forceRetrieve: forceRetrieve),
                      fillWithEmptyRows: true,
                      width: size.width,
                      columns: const [
                        DataColumn(label: Text('Id')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Created')),
                        DataColumn(label: Text('Expires')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rowBuilder: (session) {
                        final bool isCurrentSession = session.id.value == _api.session.id.value;
                        return DataRow(cells: [
                          DataCell(Text(session.id.value.toString())),
                          DataCell(Text(session.name ?? 'N/A')),
                          DataCell(Text(state.dateTimeFormat.format(session.createdAt))),
                          DataCell(Text(state.dateTimeFormat.format(session.expiresAt))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(isCurrentSession ? Icons.logout_rounded : Icons.delete_rounded),
                                onPressed: () => isCurrentSession
                                    ? context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested(api: _api))
                                    : _deleteSession(session),
                              ),
                            ],
                          )),
                        ]);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteSession(PartialSession session) async {
    try {
      await session.delete();
      if (!mounted) return;
      context.showSnackBar('Successfully deleted "${session.name ?? 'Session ${session.id.value}'}"');
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }

  void _deleteAllSessions() async {
    try {
      await _api.deleteAllSessions();
      if (!mounted) return;
      context.showSnackBar('Successfully deleted all Sessions!');
      context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested(api: _api));
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
