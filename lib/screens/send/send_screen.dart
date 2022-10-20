import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select.dart';
import 'package:defi_wallet/screens/home/widgets/asset_select_field.dart';
import 'package:defi_wallet/screens/send/forms/send_form.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';

class SendScreen extends StatefulWidget {
  final String selectedAddress;

  const SendScreen({
    Key? key,
    this.selectedAddress = '',
  }) : super(key: key);

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  GlobalKey<AssetSelectState> selectKeyFrom = GlobalKey<AssetSelectState>();
  GlobalKey<AssetSelectFieldState> selectKeyFieldFrom =
      GlobalKey<AssetSelectFieldState>();
  GlobalKey globalKey = GlobalKey();
  double toolbarHeight = 55;
  double toolbarHeightWithBottom = 105;

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
