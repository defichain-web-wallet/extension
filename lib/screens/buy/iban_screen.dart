import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/available_asset_model.dart';
import 'package:defi_wallet/models/iban_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/fields/iban_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/iban_selector.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
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

class _IbanScreenState extends State<IbanScreen> with ThemeMixin {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final GlobalKey<IbanSelectorState> selectKeyIban =
      GlobalKey<IbanSelectorState>();
  String titleText = 'Select IBAN';
  String subtitleText = 'The purchase of the selected token '
      'is carried out by our partner company DFX AG. '
      'To be able to allocate your deposit your IBAN number is required. ';

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
          builder: (context, fiatState) {
            if (fiatState.status == FiatStatusList.loading) {
              return Loader();
            } else {
              List<IbanModel> ibanList = fiatState.ibanList!
                  .where((element) => element.type == "Wallet")
                  .toList();

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
                drawerScrimColor: Color(0x0f180245),
                endDrawer: AccountDrawer(
                  width: buttonSmallWidth,
                ),
                appBar: NewMainAppBar(
                  isShowLogo: false,
                ),
                body: Container(
                  padding: EdgeInsets.only(
                    top: 22,
                    bottom: 24,
                    left: 16,
                    right: 16,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkTheme()
                        ? DarkColors.scaffoldContainerBgColor
                        : LightColors.scaffoldContainerBgColor,
                    border: isDarkTheme()
                        ? Border.all(
                            width: 1.0,
                            color: Colors.white.withOpacity(0.05),
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    titleText,
                                    style: headline2.copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                subtitleText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .apply(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .color!
                                          .withOpacity(0.6),
                                    ),
                                softWrap: true,
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    widget.isNewIban ||
                                            fiatState.activeIban == null
                                        ? IbanField(
                                            ibanController: _ibanController,
                                            hintText:
                                                'DE89 37XX XXXX XXXX XXXX XX',
                                            maskFormat:
                                                'AA## #### #### #### #### ##',
                                          )
                                        : IbanSelector(
                                            asset: widget.asset,
                                            key: selectKeyIban,
                                            onAnotherSelect: hideOverlay,
                                            routeWidget: widget.routeWidget,
                                            ibanList: uniqueIbans,
                                            selectedIban: fiatState.activeIban!,
                                          )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 104,
                                child: AccentButton(
                                  label: 'Cancel',
                                  callback: () => Navigator.of(context).pop(),
                                ),
                              ),
                              NewPrimaryButton(
                                width: 104,
                                callback: () {
                                  hideOverlay();
                                  submit(context, fiatState);
                                },
                                title: 'Next',
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
