import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/router_helper.dart';
import 'package:defi_wallet/models/forms/kyc_name_former.dart';
import 'package:defi_wallet/screens/auth_screen/lock_screen.dart';
import 'package:defi_wallet/screens/sell/country_sell.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/routes.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/fields/custom_text_form_field.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountTypeSell extends StatefulWidget {
  KycNameFormer? former;
  bool isSaveRoute;

  AccountTypeSell({
    this.former,
    this.isSaveRoute = true,
    Key? key,
  }) : super(key: key) {
    this.former = this.former ?? KycNameFormer.init();
  }
  @override
  _AccountTypeSellState createState() => _AccountTypeSellState();
}

class _AccountTypeSellState extends State<AccountTypeSell> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  LockHelper lockHelper = LockHelper();
  RouterHelper routerHelper = RouterHelper();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.isSaveRoute) {
        await routerHelper.setCurrentRoute(Routes.kycName);
      }
    });
    _nameController.text = widget.former!.firstName!;
    _surnameController.text = widget.former!.lastName!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      widget.former!.reset();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);

    return BlocBuilder<AccountCubit, AccountState>(
        builder: (context, accountState) {
      fiatCubit.loadCountryList(accountState.accessToken!);
      return BlocBuilder<FiatCubit, FiatState>(
          builder: (BuildContext context, state) {
        if (state.personalInfo != null) {
          _nameController.text = state.personalInfo!.firstname!;
          _surnameController.text = state.personalInfo!.surname!;
        }
        return ScaffoldConstrainedBox(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < ScreenSizes.medium) {
                return Scaffold(
                  appBar: MainAppBar(
                    title: '1/4',
                  ),
                  body: _buildBody(state),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Scaffold(
                    appBar: MainAppBar(
                      title: '1/4',
                      isSmall: true,
                    ),
                    body: _buildBody(state, isFullSize: true),
                  ),
                );
              }
            },
          ),
        );
      });
    });
  }

  Widget _buildBody(state, {isFullSize = false}) {
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
        color: isFullSize ? Theme.of(context).dialogBackgroundColor : null,
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
                              '1.',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.apply(color: AppTheme.pinkColor),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 3),
                            child: Text(
                              'Let´s start with your first and last name',
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
                                hintText: 'Satoshi',
                                addressController: _nameController,
                                validationRule: 'name',
                                onChanged: (value) {
                                  widget.former!.firstName = value;
                                  widget.former!.save();
                                },
                              ),
                              Padding(padding: EdgeInsets.only(top: 10)),
                              CustomTextFormField(
                                hintText: 'Nakamoto',
                                addressController: _surnameController,
                                validationRule: 'surname',
                                onChanged: (value) {
                                  widget.former!.lastName = value;
                                  widget.former!.save();
                                },
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
                      lockHelper.provideWithLockChecker(context, () {
                        FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
                        fiatCubit.setUserName(
                            _nameController.text, _surnameController.text);
                        Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  CountrySell(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ));
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
