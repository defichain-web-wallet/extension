import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef ScaffoldWrapperBuilder = Widget Function(
    BuildContext context, bool isFullScreen, TransactionState txState);

class ScaffoldWrapper extends StatefulWidget {
  final ScaffoldWrapperBuilder builder;

  ScaffoldWrapper({required this.builder});

  @override
  State<ScaffoldWrapper> createState() => _ScaffoldWrapperState();
}

class _ScaffoldWrapperState extends State<ScaffoldWrapper> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ScreenSizes.medium),
          child: LayoutBuilder(builder: (context, constraints) {
            return BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, txState) {
              bool isFullScreenMode =
                  constraints.maxWidth == ScreenSizes.medium;
              return Container(
                padding: EdgeInsets.only(top: isFullScreenMode ? 20 : 0),
                child: widget.builder(
                  context,
                  isFullScreenMode,
                  txState,
                ),
              );
            });
          }),
        ),
      ),
    );
  }
}
