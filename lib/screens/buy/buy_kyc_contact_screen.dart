import 'package:defi_wallet/bloc/refactoring/ramp/ramp_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/buy/buy_select_currency_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
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
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
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
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
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
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (BuildContext context, accountState) {
            return BlocBuilder<RampCubit, RampState>(
              builder: (BuildContext context, rampState) {
                if (rampState.rampUserModel!.email != null) {
                  _emailController.text = rampState.rampUserModel!.email!;
                }
                if (rampState.rampUserModel!.phone != null) {
                  _phoneController.text = rampState.rampUserModel!.phone!;
                }
                if (rampState.status == RampStatusList.loading) {
                  return Loader();
                } else if (rampState.status == RampStatusList.expired) {
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
                    drawerScrimColor: AppColors.tolopea.withOpacity(0.06),
                    endDrawer: isFullScreen ? null : AccountDrawer(
                      width: buttonSmallWidth,
                    ),
                    appBar: isFullScreen ? null : NewMainAppBar(
                      isShowLogo: false,
                    ),
                    body: Container(
                      padding: EdgeInsets.only(
                        top: 22,
                        bottom: 22,
                        left: 16,
                        right: 16,
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkTheme()
                            ? DarkColors.drawerBgColor
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
                          bottomLeft: Radius.circular(isFullScreen ? 20 : 0),
                          bottomRight: Radius.circular(isFullScreen ? 20 : 0),
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
                                      PageTitle(
                                        title: titleText,
                                        isFullScreen: isFullScreen,
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
                                      GestureDetector(
                                        onDoubleTap: () {
                                          emailFocusNode.requestFocus();
                                          if (_emailController.text.isNotEmpty) {
                                            _emailController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                    _emailController
                                                        .text.length);
                                          }
                                        },
                                        child: TextFormField(
                                          focusNode: emailFocusNode,
                                          controller: _emailController,
                                          decoration: InputDecoration(
                                            hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                                            filled: true,
                                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                            enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                            focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                            hintStyle: passwordField.copyWith(
                                              color: isDarkTheme() ? DarkColors.hintTextColor : LightColors.hintTextColor,
                                            ),
                                              contentPadding:
                                                  EdgeInsets.only(left: 12),
                                              hintText: 'Enter email address',
                                          ),
                                          validator: (val) {
                                            return val != null &&
                                                    !EmailValidator.validate(val)
                                                ? 'Enter a valid email'
                                                : null;
                                          },
                                        ),
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
                                      GestureDetector(
                                        onDoubleTap: () {
                                          phoneFocusNode.requestFocus();
                                          if (_phoneController.text.isNotEmpty) {
                                            _phoneController.selection =
                                                TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                    _phoneController
                                                        .text.length);
                                          }
                                        },
                                        child: TextFormField(
                                          focusNode: phoneFocusNode,
                                          controller: _phoneController,
                                          decoration: InputDecoration(
                                              hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                                              filled: true,
                                              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                              enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                              focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                              hintStyle: passwordField.copyWith(
                                                color: isDarkTheme() ? DarkColors.hintTextColor : LightColors.hintTextColor,
                                              ),
                                              contentPadding:
                                                  EdgeInsets.only(left: 12),
                                              hintText: 'Enter phone number'),
                                        ),
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
                                        NavigatorService.pop(context);
                                      },
                                      label: 'Back',
                                    ),
                                  ),
                                  NewPrimaryButton(
                                    width: 104,
                                    callback: isEnable
                                        ? () async {
                                            await _authenticateWithEmailAndPassword(
                                                context,);
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

  _authenticateWithEmailAndPassword(context) async {
    if (_formKey.currentState!.validate()) {
      RampCubit rampCubit = BlocProvider.of<RampCubit>(context);

      await rampCubit.createUser(
        _emailController.text,
        _phoneController.text,
      );
      NavigatorService.push(context, BuySelectCurrencyScreen());
    }
  }
}
