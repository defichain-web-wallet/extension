import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IbanScreen extends StatefulWidget {
  final AssetByFiatModel asset;
  final bool isNewIban;
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
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (BuildContext context, fiatState) {
            if (fiatState.status == FiatStatusList.loading) {
              return Loader();
            } else {
              List<String> stringIbans = [];
              List<IbanModel> uniqueIbans = [];

              fiatState.ibanList!.forEach((element) {
                stringIbans.add(element.iban!);
              });

              var stringUniqueIbans = Set<String>.from(stringIbans).toList();

              stringUniqueIbans.forEach((element) {
                uniqueIbans.add(
                    fiatState.ibanList!.firstWhere((el) => el.iban == element));
              });

              return Scaffold(
                appBar: MainAppBar(
                  title: 'Buying Token with Fiat',
                  hideOverlay: () => hideOverlay(),
                  isSmall: isFullScreen,
                ),
                body: Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  padding: const EdgeInsets.only(
                      left: 18, right: 12, top: 24, bottom: 24),
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
                                    image: AssetImage(
                                        'assets/buying_crypto_logo.png'),
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
                                    style:
                                        Theme.of(context).textTheme.headline3,
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
                                        widget.isNewIban ||
                                                fiatState.activeIban == null
                                            ? IbanField(
                                                isBorder: isFullScreen,
                                                ibanController: _ibanController,
                                                hintText:
                                                    'DE89 37XX XXXX XXXX XXXX XX',
                                                maskFormat:
                                                    'AA## #### #### #### #### ##',
                                              )
                                            : IbanSelector(
                                                isBorder: isFullScreen,
                                                asset: widget.asset,
                                                key: selectKeyIban,
                                                onAnotherSelect: hideOverlay,
                                                routeWidget: widget.routeWidget,
                                                ibanList: uniqueIbans,
                                                selectedIban:
                                                    fiatState.activeIban!,
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
                                    callback: () {
                                      hideOverlay();
                                      Navigator.of(context).pop();
                                    }),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: PrimaryButton(
                                  label: 'Next',
                                  isCheckLock: false,
                                  callback: () {
                                    hideOverlay();
                                    submit(context, fiatState);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  submit(context, fiatState) async {
    if (_formKey.currentState!.validate()) {
      FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
      String iban = (widget.isNewIban || fiatState.activeIban == null)
          ? _ibanController.text
          : fiatState.activeIban.iban;
      print(_ibanController.text);
      await fiatCubit.saveBuyDetails(
          iban, widget.asset, fiatState.accessToken!);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => widget.routeWidget!,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  hideOverlay() {
    try {
      selectKeyIban.currentState!.hideOverlay();
    } catch (_) {}
  }
}
