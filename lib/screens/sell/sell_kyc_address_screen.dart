import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_contact_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellKycAddressScreen extends StatefulWidget {
  const SellKycAddressScreen({Key? key}) : super(key: key);

  @override
  _SellKycAddressScreenState createState() => _SellKycAddressScreenState();
}

class _SellKycAddressScreenState extends State<SellKycAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetAdressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void dispose() {
    _streetAdressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
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
            return Scaffold(
              appBar: MainAppBar(
                title: '3/4',
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
                                      '3.',
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
                                      'What is your address?',
                                      style:
                                          Theme.of(context).textTheme.headline5,
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
                                        hintText: 'Street adress',
                                        addressController:
                                            _streetAdressController,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextFormField(
                                        isBorder: isFullScreen,
                                        hintText: 'City',
                                        addressController: _cityController,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextFormField(
                                        isBorder: isFullScreen,
                                        hintText: 'Zip code',
                                        addressController: _zipCodeController,
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
                          callback: () async {
                            FiatCubit fiatCubit =
                                BlocProvider.of<FiatCubit>(context);
                            if (_formKey.currentState!.validate()) {
                              await fiatCubit.setAddress(
                                _streetAdressController.text,
                                _cityController.text,
                                _zipCodeController.text,
                                fiatState.accessToken!,
                              );
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          SellKycContactScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
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
          },
        );
      },
    );
  }
}
