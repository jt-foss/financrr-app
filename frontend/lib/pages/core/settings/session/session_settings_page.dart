import 'package:financrr_frontend/pages/authentication/state/authentication_provider.dart';
import 'package:financrr_frontend/util/common_actions.dart';
import 'package:financrr_frontend/util/extensions.dart';
import 'package:financrr_frontend/widgets/entities/session_card.dart';
import 'package:financrr_frontend/widgets/paginated_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restrr/restrr.dart';

import '../../../../layout/adaptive_scaffold.dart';
import '../../../../routing/page_path.dart';
import '../../settings_page.dart';

class SessionSettingsPage extends StatefulHookConsumerWidget {
  static const PagePathBuilder pagePath = PagePathBuilder.child(parent: SettingsPage.pagePath, path: 'session');

  const SessionSettingsPage({super.key});

  @override
  ConsumerState<SessionSettingsPage> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends ConsumerState<SessionSettingsPage> {
  final GlobalKey<PaginatedWrapperState<PartialSession>> _paginatedSessionKey = GlobalKey();
  late final Restrr _api = api;

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
                SessionCard(session: _api.session, onDelete: () => CommonActions.logOut(this, ref)),
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
                        })
                  ],
                ),
                const Divider(),
                PaginatedWrapper(
                  key: _paginatedSessionKey,
                  initialPageFunction: (forceRetrieve) =>
                      _api.retrieveAllSessions(limit: 10, forceRetrieve: forceRetrieve),
                  onError: (context, snap) {
                    if (snap.error is ServerException) {
                      CommonActions.logOut(this, ref);
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
        CommonActions.logOut(this, ref);
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
      CommonActions.logOut(this, ref);
    } on RestrrException catch (e) {
      context.showSnackBar(e.message!);
    }
  }
}
