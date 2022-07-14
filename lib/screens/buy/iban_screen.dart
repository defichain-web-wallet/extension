import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IbanScreen extends StatefulWidget {
  AssetByFiatModel asset;
  bool isNewIban;
  final Widget? routeWidget;

  IbanScreen(
      {Key? key, required this.asset, this.isNewIban = false, this.routeWidget})
      : super(key: key);

  @override
  _IbanScreenState createState() => _IbanScreenState();
}

class _IbanScreenState extends State<IbanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final GlobalKey<IbanSelectorState> selectKeyIban =
      GlobalKey<IbanSelectorState>();

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountState>(
        builder: (BuildContext context, accountState) {
      return BlocBuilder<FiatCubit, FiatState>(
        builder: (BuildContext context, state) {
          return ScaffoldConstrainedBox(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                      title: 'Buying Token with Fiat',
                    ),
                    body: _buildBody(state, accountState),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'Buying Token with Fiat',
                        isSmall: true,
                      ),
                      body: _buildBody(state, accountState, isFullSize: true),
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildBody(state, accountState, {isFullSize = false}) {
    if (state.status == FiatStatusList.loading) {
      return Loader();
    } else {
      List<IbanModel> ibanList =
          state.ibanList.where((element) => element.type == "Wallet").toList();

      return Container(
        color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
        padding:
            const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
        child: Center(
          child: StretchBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 24,
                        ),
                        child: Image(
                          image: AssetImage('assets/buying_crypto_logo.png'),
                        ),
                      ),
                      Container(
                        width: 380,
                        padding: EdgeInsets.only(
                          top: 44,
                        ),
                        child: Text(
                          'The purchase of the selected token is carried out by our partner company DFX AG. To be able to allocate your deposit your IBAN number is required.',
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      Container(
                        // width: 320,
                        padding: EdgeInsets.only(
                          top: 44,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              widget.isNewIban || state.activeIban == null
                                  ? IbanField(
                                      ibanController: _ibanController,
                                      hintText: 'DE89 3704 0044 0532 0130 00',
                                      maskFormat: 'AA## #### #### #### #### ##',
                                    )
                                  : IbanSelector(
                                      asset: widget.asset,
                                      key: selectKeyIban,
                                      onAnotherSelect: hideOverlay,
                                      routeWidget: widget.routeWidget,
                                      ibanList: ibanList,
                                      selectedIban: state.activeIban,
                                    )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: AccentButton(
                          label: 'Cancel',
                          callback: () => Navigator.of(context).pop()),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                          label: 'Next',
                          isCheckLock: false,
                          callback: () {
                            hideOverlay();
                            _authenticateWithEmailAndPassword(
                                context, accountState);
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  _authenticateWithEmailAndPassword(context, accountState) async {
    if (_formKey.currentState!.validate()) {
      FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
      fiatCubit.addIban(_ibanController.text);
      await fiatCubit.saveBuyDetails(
          _ibanController.text, widget.asset, accountState.accessToken!);
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                widget.routeWidget!,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    }
  }

  hideOverlay() {
    try {
      selectKeyIban.currentState!.hideOverlay();
    } catch (_) {}
  }
}
