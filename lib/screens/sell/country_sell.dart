import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/sell/address_sell.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CountrySell extends StatefulWidget {
  const CountrySell({Key? key}) : super(key: key);

  @override
  _CountrySellState createState() => _CountrySellState();
}

class _CountrySellState extends State<CountrySell> {
  final _formKey = GlobalKey<FormState>();
  late Map selectedCountry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiatCubit, FiatState>(builder: (context, state) {
      if (state.personalInfo!.country != null) {
        selectedCountry = state.personalInfo!.country!;
      } else {
        selectedCountry = state.countryList![0];
      }
      return ScaffoldConstrainedBox(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < ScreenSizes.medium) {
              return Scaffold(
                appBar: MainAppBar(
                  title: '2/4',
                  isSmall: true,
                ),
                body: _buildBody(state),
              );
            } else {
              return Container(
                padding: const EdgeInsets.only(top: 20),
                child: Scaffold(
                  appBar: MainAppBar(
                    title: '2/4',
                  ),
                  body: _buildBody(state, isFullSize: true),
                ),
              );
            }
          },
        ),
      );
    });
  }

  Widget _buildBody(state, {isFullSize = false}) => Container(
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
                              CountryListPick(
                                initialSelection: selectedCountry['symbol'],
                                  theme: CountryTheme(
                                    isShowFlag: true,
                                    isShowTitle: true,
                                    isShowCode: false,
                                    isDownIcon: true,
                                    showEnglishName: true,
                                    labelColor: Colors.blueAccent,
                                  ),
                                  onChanged: (CountryCode? code) {
                                    print(code!.code);
                                    selectedCountry = getFormatCountry(
                                        code.code!, state.countryList);
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
                    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
                    fiatCubit.setCountry(selectedCountry);
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AddressSell(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ));
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Map getFormatCountry(String symbol, List<dynamic> countries) {
    return countries.firstWhere((element) => element['symbol'] == symbol);
  }
}
