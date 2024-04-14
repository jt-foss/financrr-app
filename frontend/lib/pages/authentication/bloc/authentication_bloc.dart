import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restrr/restrr.dart';

import '../../../data/bloc/store_bloc.dart';
import '../../../data/store.dart';

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
      StoreBloc().write(StoreKey.sessionToken, api.session.token);
      emit(AuthenticationState.authenticated(api));
    } catch (e) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  void _onAuthenticationRecoveryRequested(AuthenticationRecoveryRequested event, Emitter<AuthenticationState> emit) async {
    final String? token = await StoreKey.sessionToken.readAsync();
    final String? hostUrl = await StoreKey.hostUrl.readAsync();
    if (token == null || hostUrl == null) {
      emit(const AuthenticationState.unauthenticated());
      return;
    }
    try {
      final Restrr api = await _getRestrrBuilder(Uri.parse(hostUrl)).refresh(sessionToken: token);
      StoreKey.sessionToken.write(api.session.token);
      emit(AuthenticationState.authenticated(api));
    } on RestrrException catch (_) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  void _onAuthenticationLogoutRequested(AuthenticationLogoutRequested event, Emitter<AuthenticationState> emit) async {
    try {
      await event.api.session.delete();
    } catch (_) {}
    await StoreKey.sessionToken.delete();
    emit(const AuthenticationState.unauthenticated());
  }

  RestrrBuilder _getRestrrBuilder(Uri uri) => RestrrBuilder(uri: uri)..options = (RestrrOptions()..isWeb = kIsWeb);
}
