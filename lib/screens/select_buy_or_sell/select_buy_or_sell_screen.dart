import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/fiat/fiat_cubit.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/screens/buy/contact_screen.dart';
import 'package:defi_wallet/screens/buy/search_buy_token.dart';
import 'package:defi_wallet/screens/home/widgets/action_buttons_list.dart';
import 'package:defi_wallet/screens/sell/account_type_sell.dart';
import 'package:defi_wallet/screens/sell/selling.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/utils/convert.dart';
import 'package:defi_wallet/widgets/loader/loader.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box.dart';
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
  void initState() {
    super.initState();
    FiatCubit fiatCubit = BlocProvider.of<FiatCubit>(context);
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await fiatCubit.loadUserDetails(accountCubit.state.accessToken!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FiatCubit, FiatState>(
      builder: (BuildContext context, fiatState) {
        if (fiatState.status == FiatStatusList.success) {
          return ScaffoldConstrainedBox(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < ScreenSizes.medium) {
                  return Scaffold(
                    appBar: MainAppBar(
                      title: 'Buy & Sell with DFX Swiss',
                    ),
                    body: _buildBody(fiatState),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Scaffold(
                      appBar: MainAppBar(
                        title: 'Buy & Sell with DFX Swiss',
                        isSmall: true,
                      ),
                      body: _buildBody(fiatState, isFullSize: true),
                    ),
                  );
                }
              },
            ),
          );
        } else {
          return ScaffoldConstrainedBox(
            child: Scaffold(
              appBar: MainAppBar(
                title: 'Buy & Sell with DFX Swiss',
              ),
              body: Loader(),
            ),
          );
        }
      },
    );
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
                Container(
                  padding: EdgeInsets.only(top: 20, bottom: 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
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
                              onPressed: () => buyCallback(context, fiatState),
                            ),
                            SizedBox(
                              width: 26,
                            ),
                            ActionButton(
                              iconPath: 'assets/images/sell.png',
                              label: 'Sell',
                              onPressed: () => sellCallback(context, fiatState),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            ActionButton(
                              iconPath: 'assets/images/increase.png',
                              label: 'Increase limit',
                              onPressed: () {
                                String kycHash = fiatState.kycHash!;
                                launch(
                                    'https://payment.dfx.swiss/kyc?code=$kycHash');
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: fiatState.history.length > 0
                      ? ListView.builder(
                          itemCount: fiatState.history.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (fiatState.history[index].type! ==
                                      'Withdrawal')
                                    SvgPicture.asset(
                                        'assets/images/withdrawal.svg')
                                  else
                                    SvgPicture.asset(
                                        'assets/images/deposit.svg')
                                ],
                              ),
                              title: Text(fiatState.history[index].type!),
                              subtitle: Text(fiatState.history[index].date!),
                              trailing: (fiatState.history[index].buyAsset !=
                                      null)
                                  ? Text(
                                      '${toFixed(fiatState.history[index].buyAmount!, 4)} ${fiatState.history[index].buyAsset}')
                                  : Text(
                                      '${toFixed(fiatState.history[index].sellAmount!, 4)} ${fiatState.history[index].sellAsset}'),
                            );
                          },
                        )
                      : Center(
                          child: Text('Not yet any transaction'),
                        ),
                ),
                SvgPicture.asset('assets/powered_of_dfx.svg'),
              ],
            ),
          ),
        ),
      );

  buyCallback(context, state) {
    if (state.isShowTutorial) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => ContactScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
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

  sellCallback(context, state) async {
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
      ),
    );
  }
}
