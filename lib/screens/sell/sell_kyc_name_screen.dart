import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_country_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellKycNameScreen extends StatefulWidget {
  const SellKycNameScreen({Key? key}) : super(key: key);

  @override
  _SellKycNameScreenState createState() => _SellKycNameScreenState();
}

class _SellKycNameScreenState extends State<SellKycNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

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
            } else if (fiatState.status == FiatStatusList.failure) {
              Future.microtask(
                () => Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        LockScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              );
              return Container();
            } else {
              return Scaffold(
                appBar: MainAppBar(
                  title: '1/4',
                  isSmall: isFullScreen,
                ),
                body: Container(
                  color: Theme.of(context).dialogBackgroundColor,
                  padding: AppTheme.screenPadding,
                  child: Center(
                    child: StretchBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Text(
                                        '1.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            ?.apply(
                                              color: AppTheme.pinkColor,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 3),
                                      child: Text(
                                        'Let´s start with your first and last name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        CustomTextFormField(
                                          isBorder: isFullScreen,
                                          hintText: 'Satoshi',
                                          addressController: _nameController,
                                          validationRule: 'name',
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        CustomTextFormField(
                                          isBorder: isFullScreen,
                                          hintText: 'Nakamoto',
                                          addressController: _surnameController,
                                          validationRule: 'surname',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PrimaryButton(
                            label: 'OK',
                            callback: () {
                              if (_formKey.currentState!.validate()) {
                                lockHelper.provideWithLockChecker(
                                  context,
                                  () {
                                    FiatCubit fiatCubit =
                                        BlocProvider.of<FiatCubit>(context);
                                    fiatCubit.setUserName(_nameController.text,
                                        _surnameController.text);
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                                SellKycCountryScreen(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                    );
                                  },
                                );
                              }
                            },
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
