import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/buy/buy_select_currency_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';

class BuyKycContactScreen extends StatefulWidget {
  const BuyKycContactScreen({Key? key}) : super(key: key);

  @override
  _BuyKycContactScreenState createState() => _BuyKycContactScreenState();
}

class _BuyKycContactScreenState extends State<BuyKycContactScreen>
    with ThemeMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final DfxRequests dfxRequests = DfxRequests();
  String countryCode = 'US';
  String numberPrefix = '+1';
  bool isEnable = true;
  String titleText = 'Contact Info';
  String subtitleText =
      'In order to complete your purchase we need the following contact information.';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
        FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (BuildContext context, accountState) {
            // fiatCubit.loadUserDetails(accountState.activeAccount!);
            return BlocBuilder<FiatCubit, FiatState>(
              builder: (BuildContext context, fiatState) {
                if (fiatState.email != null) {
                  _emailController.text = fiatState.email!;
                }
                if (fiatState.phone != null) {
                  _phoneController.text = fiatState.phone!;
                }
                if (fiatState.status == FiatStatusList.loading) {
                  return Loader();
                } else if (fiatState.status == FiatStatusList.failure) {
                  Future.microtask(() => Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            LockScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      )));
                  return Container();
                } else {
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            titleText,
                                            style: headline2.copyWith(
                                                fontWeight: FontWeight.w700),
                                            textAlign: TextAlign.start,
                                            softWrap: true,
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
                                      Row(
                                        children: [
                                          Text(
                                            'Email Address',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 12),
                                            hintText: 'Enter email address'),
                                        validator: (val) {
                                          return val != null &&
                                                  !EmailValidator.validate(val)
                                              ? 'Enter a valid email'
                                              : null;
                                        },
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Phone number',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      TextFormField(
                                        controller: _phoneController,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(left: 12),
                                            hintText: 'Enter phone number'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 104,
                                    child: AccentButton(
                                      callback: () {
                                        Navigator.pop(context);
                                      },
                                      label: 'Back',
                                    ),
                                  ),
                                  NewPrimaryButton(
                                    width: 104,
                                    callback: isEnable
                                        ? () async {
                                            await _authenticateWithEmailAndPassword(
                                                context, fiatState);
                                          }
                                        : null,
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
      },
    );
  }

  _authenticateWithEmailAndPassword(context, state) async {
    if (_formKey.currentState!.validate()) {
      FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

      await fiatCubit.createUser(
        _emailController.text,
        _phoneController.text,
        state.accessToken,
      );
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SearchBuyToken(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
