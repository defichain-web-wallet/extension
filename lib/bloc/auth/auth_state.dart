import 'package:flutter/material.dart';

@immutable
class AuthState {
  final bool? isLoading;
  List<String>? mnemonic;

  AuthState({this.isLoading, this.mnemonic});

  AuthState copyWith({
    bool? isLoading = false,
    List<String>? mnemonic,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      mnemonic: mnemonic ?? this.mnemonic,
    );
  }
}