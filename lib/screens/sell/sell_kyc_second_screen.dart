import 'package:country_list_pick/country_list_pick.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/lock_screen.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_third_screen.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/common/page_title.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SellKycSecondScreen extends StatefulWidget {
  const SellKycSecondScreen({Key? key}) : super(key: key);

  @override
  _SellKycSecondScreenState createState() => _SellKycSecondScreenState();
}

class _SellKycSecondScreenState extends State<SellKycSecondScreen>
    with ThemeMixin, SnackBarMixin {
  final _formKey = GlobalKey<FormState>();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final FocusNode streetAddressFocusNode = FocusNode();
  final FocusNode cityFocusNode = FocusNode();
  final FocusNode zipCodeFocusNode = FocusNode();
  final String titleText = '2/3. Let us know where do you live';
  final String subtitleText = 'We should know your Address for ...';
  late Map selectedCountry;
  bool _isShowDropdown = false;

  @override
  void dispose() {
    _streetAddressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    streetAddressFocusNode.dispose();
    cityFocusNode.dispose();
    zipCodeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double arrowRotateDeg = _isShowDropdown ? 180 : 0;

    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (BuildContext context, fiatState) {
            if (fiatState.personalInfo!.country != null) {
              selectedCountry = fiatState.personalInfo!.country!;
            } else {
              selectedCountry = fiatState.countryList![0];
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
                    left: 0,
                    right: 0,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32,
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Your Country',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          CountryListPick(
                                              pickerBuilder:
                                                  (context, country) {
                                                return Container(
                                                  height: 44,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: AppColors.portage
                                                          .withOpacity(0.12),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        selectedCountry['name'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline6!
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      RotationTransition(
                                                        turns:
                                                            AlwaysStoppedAnimation(
                                                                arrowRotateDeg /
                                                                    360),
                                                        child: SizedBox(
                                                          width: 10,
                                                          height: 10,
                                                          child:
                                                              SvgPicture.asset(
                                                            'assets/icons/arrow_down.svg',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              initialSelection:
                                                  selectedCountry['symbol'],
                                              onChanged: (CountryCode? code) {
                                                print(code!.code);
                                                selectedCountry =
                                                    getFormatCountry(code.code!,
                                                        fiatState.countryList!);
                                              }),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Street Address',
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
                                                    streetAddressFocusNode.requestFocus();
                                                    if (_streetAddressController.text.isNotEmpty) {
                                                      _streetAddressController.selection =
                                                          TextSelection(
                                                              baseOffset: 0,
                                                              extentOffset:
                                                              _streetAddressController
                                                                  .text.length);
                                                    }
                                                  },
                                                  child: TextFormField(
                                                    focusNode: streetAddressFocusNode,
                                                    controller:
                                                        _streetAddressController,
                                                    decoration: InputDecoration(
                                                      hoverColor: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .hoverColor,
                                                      filled: true,
                                                      fillColor: Theme.of(context)
                                                          .inputDecorationTheme
                                                          .fillColor,
                                                      enabledBorder: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .enabledBorder,
                                                      focusedBorder: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .focusedBorder,
                                                      hintStyle:
                                                          passwordField.copyWith(
                                                        color: isDarkTheme()
                                                            ? DarkColors
                                                                .hintTextColor
                                                            : LightColors
                                                                .hintTextColor,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 12),
                                                      hintText:
                                                          'Enter your Street Address',
                                                    ),
                                                    validator: (value) {
                                                      return value == null ||
                                                              value.isEmpty
                                                          ? 'Please enter this field'
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
                                                      'City',
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
                                                    cityFocusNode.requestFocus();
                                                    if (_cityController.text.isNotEmpty) {
                                                      _cityController.selection =
                                                          TextSelection(
                                                              baseOffset: 0,
                                                              extentOffset:
                                                              _cityController
                                                                  .text.length);
                                                    }
                                                  },
                                                  child: TextFormField(
                                                    focusNode: cityFocusNode,
                                                    controller: _cityController,
                                                    decoration: InputDecoration(
                                                      hoverColor: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .hoverColor,
                                                      filled: true,
                                                      fillColor: Theme.of(context)
                                                          .inputDecorationTheme
                                                          .fillColor,
                                                      enabledBorder: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .enabledBorder,
                                                      focusedBorder: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .focusedBorder,
                                                      hintStyle:
                                                          passwordField.copyWith(
                                                        color: isDarkTheme()
                                                            ? DarkColors
                                                                .hintTextColor
                                                            : LightColors
                                                                .hintTextColor,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 12),
                                                      hintText: 'Enter your City',
                                                    ),
                                                    validator: (value) {
                                                      return value == null ||
                                                              value.isEmpty
                                                          ? 'Please enter this field'
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
                                                      'Zip code',
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
                                                    zipCodeFocusNode.requestFocus();
                                                    if (_zipCodeController.text.isNotEmpty) {
                                                      _zipCodeController.selection =
                                                          TextSelection(
                                                              baseOffset: 0,
                                                              extentOffset:
                                                              _zipCodeController
                                                                  .text.length);
                                                    }
                                                  },
                                                  child: TextFormField(
                                                    focusNode: zipCodeFocusNode,
                                                    controller:
                                                        _zipCodeController,
                                                    decoration: InputDecoration(
                                                      hoverColor: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .hoverColor,
                                                      filled: true,
                                                      fillColor: Theme.of(context)
                                                          .inputDecorationTheme
                                                          .fillColor,
                                                      enabledBorder: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .enabledBorder,
                                                      focusedBorder: Theme.of(
                                                              context)
                                                          .inputDecorationTheme
                                                          .focusedBorder,
                                                      hintStyle:
                                                          passwordField.copyWith(
                                                        color: isDarkTheme()
                                                            ? DarkColors
                                                                .hintTextColor
                                                            : LightColors
                                                                .hintTextColor,
                                                      ),
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              left: 12),
                                                      hintText:
                                                          'Enter your Zip Code',
                                                    ),
                                                    validator: (value) {
                                                      return value == null ||
                                                              value.isEmpty
                                                          ? 'Please enter this field'
                                                          : null;
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 24,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                    NavigatorService.pop(context);
                                  },
                                  label: 'Back',
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: NewPrimaryButton(
                                  width: 104,
                                  callback: () async {
                                    FiatCubit fiatCubit =
                                        BlocProvider.of<FiatCubit>(context);
                                    fiatCubit.setCountry(selectedCountry);
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        await fiatCubit.setAddress(
                                          _streetAddressController.text,
                                          _cityController.text,
                                          _zipCodeController.text,
                                          fiatState.accessToken!,
                                        );
                                        NavigatorService.push(
                                          context,
                                          SellKycThirdScreen(),
                                        );
                                      } catch (err) {
                                        showSnackBar(
                                          context,
                                          title: err
                                              .toString()
                                              .replaceAll('"', ''),
                                          color: AppColors.txStatusError
                                              .withOpacity(0.1),
                                          prefix: Icon(
                                            Icons.close,
                                            color: AppColors.txStatusError,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  title: 'Next',
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

  Map getFormatCountry(String symbol, List<dynamic> countries) {
    return countries.firstWhere((element) => element['symbol'] == symbol);
  }
}
