import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/screens/sell/selling_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SellKycContactScreen extends StatefulWidget {
  const SellKycContactScreen({Key? key}) : super(key: key);

  @override
  _SellKycContactScreenState createState() => _SellKycContactScreenState();
}

class _SellKycContactScreenState extends State<SellKycContactScreen> {
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
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return BlocBuilder<FiatCubit, FiatState>(
          builder: (context, fiatState) {
            if (fiatState.email != null) {
              _emailController.text = fiatState.email!;
            }
            if (fiatState.phone != null) {
              _phoneController.text = fiatState.phone!;
            }
            return Scaffold(
              appBar: MainAppBar(
                title: '4/4',
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
                                      '4.',
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
                                      'Email address and mobile number',
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
                                        hintText: 'Email',
                                        validationRule: 'email',
                                        addressController: _emailController,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      CustomTextFormField(
                                        isBorder: isFullScreen,
                                        addressController: _phoneController,
                                        hintText: 'Phone number',
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
                            _authenticateWithEmail(context, fiatState);
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

  _authenticateWithEmail(context, fiatState) async {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    if (_formKey.currentState!.validate()) {
      await fiatCubit.createUser(
        _emailController.text,
        _phoneController.text,
        fiatState.accessToken,
      );
      var box = await Hive.openBox(HiveBoxes.client);
      String kycStatus = 'skip';
      await box.put(HiveNames.kycStatus, kycStatus);
      await box.close();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => SellingScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
