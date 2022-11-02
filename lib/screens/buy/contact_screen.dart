import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final DfxRequests dfxRequests = DfxRequests();
  String countryCode = 'US';
  String numberPrefix = '+1';
  bool isEnable = true;
  double contentWidth = 320;
  double buttonWidth = 217;

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
            fiatCubit.loadUserDetails(accountState.activeAccount!);
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
                      title: 'Buying crypto via bank transfer',
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
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        top: 44,
                                      ),
                                      child: Image(
                                        image: AssetImage(
                                          'assets/buying_crypto_logo.png',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: contentWidth,
                                      padding: EdgeInsets.only(
                                        top: 44,
                                      ),
                                      child: Text(
                                        'In order to complete your purchase\nwe need the following contact information.',
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6
                                            ?.apply(
                                              color: AppTheme.pinkColor,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      width: contentWidth,
                                      padding: EdgeInsets.only(
                                        top: 44,
                                      ),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            CustomTextFormField(
                                              isBorder: isFullScreen,
                                              addressController:
                                                  _emailController,
                                              validationRule: 'email',
                                              hintText: 'Email address',
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10)),
                                            CustomTextFormField(
                                              isBorder: isFullScreen,
                                              addressController:
                                                  _phoneController,
                                              hintText: 'Phone number',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: buttonWidth,
                                padding: EdgeInsets.only(bottom: 88),
                                child: PrimaryButton(
                                  label: 'Next',
                                  isCheckLock: false,
                                  callback: isEnable
                                      ? () async {
                                          await _authenticateWithEmailAndPassword(
                                              context, fiatState);
                                        }
                                      : null,
                                ),
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
