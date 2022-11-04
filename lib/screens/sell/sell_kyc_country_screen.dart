import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/screens/sell/sell_kyc_address_screen.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellKycCountryScreen extends StatefulWidget {
  const SellKycCountryScreen({Key? key}) : super(key: key);

  @override
  _SellKycCountryScreenState createState() => _SellKycCountryScreenState();
}

class _SellKycCountryScreenState extends State<SellKycCountryScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map selectedCountry;

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
            if (fiatState.personalInfo!.country != null) {
              selectedCountry = fiatState.personalInfo!.country!;
            } else {
              selectedCountry = fiatState.countryList![0];
            }

            return Scaffold(
              appBar: MainAppBar(
                title: '2/4',
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
                                      '2.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          ?.apply(color: AppTheme.pinkColor),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(left: 3),
                                    child: Text(
                                      'What country do you live in?',
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
                                      CountryListPick(
                                          initialSelection:
                                              selectedCountry['symbol'],
                                          theme: CountryTheme(
                                            isShowFlag: true,
                                            isShowTitle: true,
                                            isShowCode: false,
                                            isDownIcon: true,
                                            showEnglishName: true,
                                            labelColor: Colors.blueAccent,
                                          ),
                                          onChanged: (CountryCode? code) {
                                            selectedCountry = getFormatCountry(
                                                code!.code!,
                                                fiatState.countryList!);
                                          })
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
                            FiatCubit fiatCubit =
                                BlocProvider.of<FiatCubit>(context);
                            fiatCubit.setCountry(selectedCountry);
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        SellKycAddressScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
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

  Map getFormatCountry(String symbol, List<dynamic> countries) {
    return countries.firstWhere((element) => element['symbol'] == symbol);
  }
}
