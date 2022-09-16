import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EmailAndPhoneSell extends StatefulWidget {
  const EmailAndPhoneSell({Key? key}) : super(key: key);

  @override
  _EmailAndPhoneSellState createState() => _EmailAndPhoneSellState();
}

class _EmailAndPhoneSellState extends State<EmailAndPhoneSell> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String countryCode = 'US';
  String numberPrefix = '+1';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiatCubit, FiatState>(
      builder: (context, fiatState) {
        return BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              if (fiatState.email != null) {
                _emailController.text = fiatState.email!;
              }
              if (fiatState.phone != null) {
                _phoneController.text = fiatState.phone!;
              }
              return ScaffoldConstrainedBox(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < ScreenSizes.medium) {
                      return Scaffold(
                        appBar: MainAppBar(
                          title: '4/4',
                        ),
                        body: _buildBody(state),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: Scaffold(
                          appBar: MainAppBar(
                            title: '4/4',
                            isSmall: true,
                          ),
                          body: _buildBody(state, isFullSize: true),
                        ),
                      );
                    }
                  },
                ),
              );
            }
        );
      },
    );
  }

  Widget _buildBody(state, {isFullSize = false}) => Container(
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
                          '4.',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.apply(color: AppTheme.pinkColor),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 3),
                        child: Text(
                          'Email address and mobile number',
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
                            hintText: 'Email',
                            validationRule: 'email',
                            addressController: _emailController,
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          CustomTextFormField(
                            isBorder: isFullSize,
                            addressController: _phoneController,
                            hintText: 'Phone number (optional)',
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
                _authenticateWithEmail(context, state);
              },
            ),
          ],
        ),
      ),
    ),
  );
  _authenticateWithEmail(context, state) async {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    if (_formKey.currentState!.validate()) {

      await fiatCubit.createUser(
        _emailController.text,
        _phoneController.text,
        state.accessToken,
      );
      var box = await Hive.openBox(HiveBoxes.client);
      String kycStatus = 'skip';
      await box.put(HiveNames.kycStatus, kycStatus);
      await box.close();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              Selling(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
