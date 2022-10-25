import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/sell/email_and_phone_sell.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddressSell extends StatefulWidget {
  const AddressSell({Key? key}) : super(key: key);

  @override
  _AddressSellState createState() => _AddressSellState();
}

class _AddressSellState extends State<AddressSell> {
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
    return BlocBuilder<FiatCubit, FiatState>(builder: (context, fiatState) {
      return ScaffoldConstrainedBox(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < ScreenSizes.medium) {
              return Scaffold(
                appBar: MainAppBar(
                  title: '3/4',
                ),
                body: _buildBody(fiatState),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: Scaffold(
                  appBar: MainAppBar(
                    title: '3/4',
                    isSmall: true,
                  ),
                  body: _buildBody(fiatState, isFullSize: true),
                ),
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildBody(fiatState, {isFullSize = false}) => Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding:
            const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
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
                                  ?.apply(color: AppTheme.pinkColor),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 3),
                            child: Text(
                              'What is your address?',
                              style: Theme.of(context).textTheme.headline5,
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
                                isBorder: isFullSize,
                                hintText: 'Street adress',
                                addressController: _streetAdressController,
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              CustomTextFormField(
                                isBorder: isFullSize,
                                hintText: 'City',
                                addressController: _cityController,
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              CustomTextFormField(
                                isBorder: isFullSize,
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
                    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
                    if (_formKey.currentState!.validate()) {
                      await fiatCubit.setAddress(
                        _streetAdressController.text,
                        _cityController.text,
                        _zipCodeController.text,
                        fiatState.accessToken,
                      );
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                EmailAndPhoneSell(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
}
