import 'package:defi_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef ScaffoldWrapperBuilder = Widget Function(
  BuildContext context,
  bool isFullScreen,
  TransactionState txState,
);

class ScaffoldWrapper extends StatefulWidget {
  final ScaffoldWrapperBuilder builder;
  final bool isUpdate;

  ScaffoldWrapper({required this.builder, this.isUpdate = false});

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
          constraints: BoxConstraints(maxWidth: ScreenSizes.large),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return BlocBuilder<TransactionCubit, TransactionState>(
                buildWhen: (prev, current) => widget.isUpdate,
                builder: (context, txState) {
                  double width = MediaQuery.of(context).size.width;
                  bool isFullScreenMode = width > ScreenSizes.medium;
                  return Container(
                    child: widget.builder(
                      context,
                      isFullScreenMode,
                      txState,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
