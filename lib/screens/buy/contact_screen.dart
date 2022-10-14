import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/requests/dfx_requests.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/buy/tutorials/first_step_buy_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

    return BlocBuilder<AccountCubit, AccountState>(
        builder: (BuildContext context, accountState) {
          fiatCubit.loadUserDetails(accountState.activeAccount!);
          return BlocBuilder<FiatCubit, FiatState>(
        builder: (BuildContext context, state) {
          if (state.email != null) {
            _emailController.text = state.email!;
          }
          if (state.phone != null) {
            _phoneController.text = state.phone!;
          }
          return ScaffoldConstrainedBox(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                      title: 'Buying crypto via bank transfer',
                    ),
                    body: _buildBody(state, accountState),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'Buying crypto via bank transfer',
                        isSmall: true,
                      ),
                      body: _buildBody(state, accountState, isFullSize: true),
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildBody(state, accountState, {isFullSize = false}) {
    if (state.status == FiatStatusList.loading) {
      return Loader();
    } else if (state.status == FiatStatusList.failure) {
      Future.microtask(() => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                LockScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ))
      );
      return Container();
    } else {
      return Container(
        color: Theme.of(context).dialogBackgroundColor,
        padding:
        const EdgeInsets.only(left: 18, right: 12, top: 24, bottom: 24),
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
                          image: AssetImage('assets/buying_crypto_logo.png'),
                        ),
                      ),
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(
                          top: 44,
                        ),
                        child: Text(
                          'In order to complete your purchase\nwe need the following contact information.',
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6?.apply(
                            color: AppTheme.pinkColor,
                          ),
                        ),
                      ),
                      Container(
                        width: 320,
                        padding: EdgeInsets.only(
                          top: 44,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextFormField(
                                isBorder: isFullSize,
                                addressController: _emailController,
                                validationRule: 'email',
                                hintText: 'Email address (optional)',
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
                Container(
                  width: 217,
                  padding: EdgeInsets.only(bottom: 88),
                  child: PrimaryButton(
                    label: 'Next',
                    isCheckLock: false,
                    callback: isEnable
                        ? () async {
                      await _authenticateWithEmailAndPassword(
                          context, state);
                    }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
          pageBuilder: (context, animation1, animation2) =>
              FirstStepBuyScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
