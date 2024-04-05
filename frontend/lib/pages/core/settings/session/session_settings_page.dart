import 'package:financrr_frontend/pages/authentication/bloc/authentication_bloc.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/entities/session_card.dart';
import 'package:financrr_frontend/widgets/paginated_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restrr/restrr.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../../router.dart';
import '../../settings_page.dart';
import 'bloc/session_bloc.dart';

class SessionSettingsPage extends StatefulWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'session');

  const SessionSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends State<SessionSettingsPage> {
  final GlobalKey<PaginatedWrapperState<PartialSession>> _paginatedSessionKey = GlobalKey();
  late final Restrr _api = context.api!;

  final ValueNotifier<int> _amount = ValueNotifier(0);

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
            onRefresh: () async => _paginatedSessionKey.currentState?.reset(),
            child: ListView(
              children: [
                SessionCard(
                    session: _api.session,
                    onDelete: () => context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested(api: _api))),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _deleteAllSessions(),
                      label: const Text('Delete all'),
                      icon: const Icon(Icons.delete_sweep_rounded),
                    ),
                    ValueListenableBuilder(
                        valueListenable: _amount,
                        builder: (context, value, child) {
                          return Text('${_amount.value} session(s)');
                        }
                    )
                  ],
                ),
                const Divider(),
                BlocListener<SessionBloc, SessionState>(
                  listener: (context, state) => _paginatedSessionKey.currentState?.reset(),
                  child: PaginatedWrapper(
                    key: _paginatedSessionKey,
                    initialPageFunction: (forceRetrieve) =>
                        _api.retrieveAllSessions(limit: 10, forceRetrieve: forceRetrieve),
                    onError: (context, snap) {
                      if (snap.error is ServerException) {
                        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested(api: _api));
                      }
                      return Text(snap.error.toString());
                    },
                    onSuccess: (context, snap) {
                      final PaginatedDataResult<PartialSession> sessions = snap.data!;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _amount.value = sessions.total;
                      });
                      sessions.items.removeWhere((s) => s.id.value == _api.session.id.value);
                      return Column(
                        children: [
                          for (PartialSession s in sessions.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SessionCard(session: s, onDelete: () => _deleteSession(s)),
                            ),
                          if (sessions.nextPage != null)
                            TextButton(
                              onPressed: () => sessions.nextPage!(_api),
                              child: const Text('Load more'),
                            ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
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
      if (session.id.value == _api.session.id.value) {
        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested(api: _api));
      } else {
        context.read<SessionBloc>().add(const SessionUpdateEvent());
      }
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
