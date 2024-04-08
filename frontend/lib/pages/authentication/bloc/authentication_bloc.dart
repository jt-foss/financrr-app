import 'package:equatable/equatable.dart';
import 'package:financrr_frontend/cache/cache_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restrr/restrr.dart';

import '../../../data/host_repository.dart';
import '../../../data/repositories.dart';
import '../../../data/session_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

extension AuthenticationBlocExtension on BuildContext {
  Restrr? get api => BlocProvider.of<AuthenticationBloc>(this).state.api;
}

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(const AuthenticationState.unknown()) {
    on<AuthenticationLoginRequested>(_onAuthenticationLoginRequested);
    on<AuthenticationRecoveryRequested>(_onAuthenticationRecoveryRequested);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
  }

  void _onAuthenticationLoginRequested(AuthenticationLoginRequested event, Emitter<AuthenticationState> emit) async {
    try {
      final Restrr api = await _getRestrrBuilder(event.uri).login(username: event.username, password: event.password);
      await Repositories.sessionRepository.write(api.session.token);
      emit(AuthenticationState.authenticated(api));
    } catch (e) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  void _onAuthenticationRecoveryRequested(AuthenticationRecoveryRequested event, Emitter<AuthenticationState> emit) async {
    final HostPreferences hostPrefs = HostService.get();
    if (!(await SessionService.hasSession()) || hostPrefs.hostUrl.isEmpty) {
      emit(const AuthenticationState.unauthenticated());
      return;
    }
    final String token = (await Repositories.sessionRepository.read())!;
    try {
      final Restrr api = await _getRestrrBuilder(Uri.parse(hostPrefs.hostUrl)).refresh(sessionToken: token);
      await Repositories.sessionRepository.write(api.session.token);
      emit(AuthenticationState.authenticated(api));
    } on RestrrException catch (_) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  void _onAuthenticationLogoutRequested(AuthenticationLogoutRequested event, Emitter<AuthenticationState> emit) async {
    try {
      await event.api.session.delete();
    } catch (_) {}
    await Repositories.sessionRepository.delete();
    emit(const AuthenticationState.unauthenticated());
  }

  RestrrBuilder _getRestrrBuilder(Uri uri) => RestrrBuilder(
      uri: uri,
      options: RestrrOptions(
        isWeb: kIsWeb,
        currencyCacheStrategy: CacheService.currencyCache,
        sessionCacheStrategy: CacheService.sessionCache,
        accountCacheStrategy: CacheService.accountCache,
        transactionCacheStrategy: CacheService.transactionCache,
        userCacheStrategy: CacheService.userCache,
      ));
}
