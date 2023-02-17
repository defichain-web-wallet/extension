import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/sell/country_sell.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_second_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountTypeSell extends StatefulWidget {
  const AccountTypeSell({Key? key}) : super(key: key);

  @override
  _AccountTypeSellState createState() => _AccountTypeSellState();
}

class _AccountTypeSellState extends State<AccountTypeSell> with ThemeMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final String titleText = '1/3. Introduce yourself';
  final String subtitleText = 'Let´s start with your first and last name';

  LockHelper lockHelper = LockHelper();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
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
        fiatCubit.loadCountryList();
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (BuildContext context, fiatState) {
            if (fiatState.personalInfo != null) {
              _nameController.text = fiatState.personalInfo!.firstname!;
              _surnameController.text = fiatState.personalInfo!.surname!;
            }
            if (fiatState.status == FiatStatusList.loading) {
              return Loader();
            } else if (fiatState.status == FiatStatusList.expired) {
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
                                    height: 32,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'First Name',
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
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                                      filled: true,
                                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                      enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                      focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                      hintStyle: passwordField.copyWith(
                                        color: isDarkTheme() ? DarkColors.hintTextColor : LightColors.hintTextColor,
                                      ),
                                      contentPadding: EdgeInsets.only(left: 12),
                                      hintText: 'Enter your First name',
                                    ),
                                    validator: (value) {
                                      return value == null || value.isEmpty
                                          ? "Enter your name"
                                          : null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Last name',
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
                                    controller: _surnameController,
                                    decoration: InputDecoration(
                                      hoverColor: Theme.of(context).inputDecorationTheme.hoverColor,
                                      filled: true,
                                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                      enabledBorder: Theme.of(context).inputDecorationTheme.enabledBorder,
                                      focusedBorder: Theme.of(context).inputDecorationTheme.focusedBorder,
                                      hintStyle: passwordField.copyWith(
                                        color: isDarkTheme() ? DarkColors.hintTextColor : LightColors.hintTextColor,
                                      ),
                                      contentPadding: EdgeInsets.only(left: 12),
                                      hintText: 'Enter your Last name',
                                    ),
                                    validator: (value) {
                                      return value == null || value.isEmpty
                                          ? "Enter your surname"
                                          : null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                callback: () {
                                  if (_formKey.currentState!.validate()) {
                                    lockHelper.provideWithLockChecker(context,
                                        () {
                                      FiatCubit fiatCubit =
                                          BlocProvider.of<FiatCubit>(context);
                                      fiatCubit.setUserName(
                                          _nameController.text,
                                          _surnameController.text);
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation1,
                                                    animation2) =>
                                                SellKycSecondScreen(),
                                            transitionDuration: Duration.zero,
                                            reverseTransitionDuration:
                                                Duration.zero,
                                          ));
                                    });
                                  }
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
}
