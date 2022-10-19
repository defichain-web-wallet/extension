import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select_field.dart';
import 'package:defi_wallet/screens/send/send_form.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';

class SendNew extends StatefulWidget {
  final String selectedAddress;

  const SendNew({
    Key? key,
    this.selectedAddress = '',
  }) : super(key: key);

  @override
  State<SendNew> createState() => _SendNewState();
}

class _SendNewState extends State<SendNew> {
  GlobalKey<AssetSelectState> selectKeyFrom = GlobalKey<AssetSelectState>();
  GlobalKey<AssetSelectFieldState> selectKeyFieldFrom =
      GlobalKey<AssetSelectFieldState>();
  GlobalKey globalKey = GlobalKey();

  void hideOverlay() {
    try {
      selectKeyFieldFrom.currentState?.hideOverlay();
      selectKeyFrom.currentState?.hideOverlay();
    } catch (_) {
      print(_);
    }
  }

  @override
  Widget build(BuildContext context) {
    double toolbarHeight = 55;
    double toolbarHeightWithBottom = 105;

    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          appBar: MainAppBar(
            title: 'Send',
            hideOverlay: () => hideOverlay(),
            isShowBottom: !(txState is TransactionInitialState),
            height: !(txState is TransactionInitialState)
                ? toolbarHeightWithBottom
                : toolbarHeight,
            isSmall: isFullScreen,
          ),
          body: SendForm(
            selectedAddress: widget.selectedAddress,
            selectKeyFrom: selectKeyFrom,
            selectKeyFieldFrom: selectKeyFieldFrom,
            hideOverlay: hideOverlay,
            isFullScreen: isFullScreen,
          ),
        );
      },
    );
  }
}
