import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/screens/buy/contact_screen.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/screens/home/widgets/action_buttons_list.dart';
import 'package:defi_wallet/screens/sell/account_type_sell.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectBuyOrSellScreen extends StatefulWidget {
  const SelectBuyOrSellScreen({Key? key}) : super(key: key);

  @override
  _SelectBuyOrSellScreenState createState() => _SelectBuyOrSellScreenState();
}

class _SelectBuyOrSellScreenState extends State<SelectBuyOrSellScreen> {
  BalancesHelper balancesHelper = BalancesHelper();

  @override
  Widget build(BuildContext context) {
    var buyCallback = (state) {
      if (state.isShowTutorial) {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => ContactScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      } else {
        Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  SearchBuyToken(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ));
      }
    };

    var sellCallback = (state) async {
      var box = await Hive.openBox(HiveBoxes.client);
      var kycStatus = await box.get(HiveNames.kycStatus);
      bool isSkipKyc = kycStatus == 'skip';
      await box.close();
      Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                isSkipKyc ? Selling() : AccountTypeSell(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
    };

    return BlocBuilder<FiatCubit, FiatState>(
      builder: (BuildContext context, fiatState) {
        return ScaffoldConstrainedBoxNew(
          appBar: MainAppBar(
            title: 'Buy & Sell with DFX Swiss',
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowColor.withOpacity(0.05),
                        spreadRadius: 2,
                        blurRadius: 3,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12.5),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          'Your limit',
                          style: Theme.of(context).textTheme.headline2!.apply(
                                fontFamily: 'IBM Plex Sans',
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Text(
                          '${balancesHelper.numberStyling(fiatState.limit! / 100)}€ / Day',
                          style: Theme.of(context).textTheme.headline1!.apply(
                                fontFamily: 'IBM Plex Medium',
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                            ),
                            ActionButton(
                              iconPath: 'assets/images/buy.png',
                              label: 'Buy',
                              onPressed: () => buyCallback(fiatState),
                            ),
                            SizedBox(
                              width: 26,
                            ),
                            ActionButton(
                              iconPath: 'assets/images/sell.png',
                              label: 'Sell',
                              onPressed: () => sellCallback(fiatState),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            ActionButton(
                              iconPath: 'assets/images/increase.png',
                              label: 'Increase limit',
                              onPressed: () {
                                String kycHash = fiatState.kycHash!;
                                launch('https://payment.dfx.swiss/kyc?code=$kycHash');
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                SvgPicture.asset('assets/powered_of_dfx.svg'),
              ],
            ),
          ),
        );
      },
    );
  }
}
