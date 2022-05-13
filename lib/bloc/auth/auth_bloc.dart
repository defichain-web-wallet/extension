import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthBloc extends Cubit<AuthState> {
  AuthBloc() : super(AuthState(isLoading: false, mnemonic: []));

  Future<void> storeMnemonic(List<String> mnemonic) async {
    state.copyWith(isLoading: true, mnemonic: mnemonic);
  }
}
