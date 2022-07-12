import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/screens/liquidity/remove_liquidity.dart';
import 'package:defi_wallet/screens/staking/unstake_confirm.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/buttons/accent_button.dart';
import 'package:defi_wallet/widgets/buttons/primary_button.dart';
import 'package:defi_wallet/widgets/scaffold_constrained_box_new.dart';
import 'package:defi_wallet/widgets/toolbar/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UnstakeScreen extends StatefulWidget {
  const UnstakeScreen({Key? key}) : super(key: key);

  @override
  _UnstakeScreenState createState() => _UnstakeScreenState();
}

class _UnstakeScreenState extends State<UnstakeScreen> {
  double currentSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldConstrainedBoxNew(
      appBar: MainAppBar(
        title: 'Unstake',
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      padding: const EdgeInsets.only(
                          top: 12, right: 16, bottom: 42, left: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount',
                                  style: TextStyle(
                                      color: Color(0xffAFAFAF),
                                      fontWeight: FontWeight.bold),
                                ),
                                // AssetPair(
                                //   pair: widget.assetPair.symbol!,
                                //   isRotate: isFullSize,
                                // )
                                SvgPicture.asset('assets/tokens/defi.svg')
                              ],
                            ),
                          ),
                          Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${getCurrentSliderValue()}%',
                                style: Theme.of(context).textTheme.headline1,
                              ),
                            ),
                          ),
                          Container(
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbShape:
                                    RoundSliderThumbShape(enabledThumbRadius: 6),
                                inactiveTrackColor: AppTheme.pinkColor,
                                trackHeight: 1,
                                trackShape: RectangularSliderTrackShape(),
                                thumbColor: AppTheme.pinkColor,
                              ),
                              child: Slider(
                                value: currentSliderValue,
                                max: 100,
                                divisions: 100,
                                label: currentSliderValue.round().toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    currentSliderValue = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SliderButton(

                                  value: 25,
                                  onPressed: () {
                                    setState(() {
                                      currentSliderValue = 25;
                                    });

                                  },
                                ),
                                SliderButton(

                                  value: 50,
                                  onPressed: () {
                                    setState(() {
                                      currentSliderValue = 50;
                                    });

                                  },
                                ),
                                SliderButton(
                                  value: 75,
                                  onPressed: () {
                                    setState(() {
                                      currentSliderValue = 75;
                                    });

                                  },
                                ),
                                SliderButton(
                                  value: 100,
                                  onPressed: () {
                                    setState(() {
                                      currentSliderValue = 100;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 65),
                    child: Column(
                      children: [
                        Container(
                          height: 34,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                  style: BorderStyle.solid),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Currently staked',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2,
                              ),
                              Text(
                                '3719 DFI',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 34,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                  style: BorderStyle.solid),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Amount to unstake',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2,
                              ),
                              Text(
                                '2184 DFI',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 34,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1.0,
                                  color: Colors.black.withOpacity(0.1),
                                  style: BorderStyle.solid),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'New staking Balance',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2,
                              ),
                              Text(
                                '948 DFI',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AccentButton(
                    label: 'Cancel',
                    callback: () => Navigator.of(context).pop()),
              ),
              SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: 'Unstake',
                  isCheckLock: false,
                  callback: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              UnstakeConfirmScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int getCurrentSliderValue() => currentSliderValue.round();
}

class SliderButton extends StatelessWidget {
  final double value;
  final onPressed;

  const SliderButton({
    Key? key,
    required this.value,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('${value.round().toString()}%',
          style: Theme.of(context)
              .textTheme
              .headline3!
              .apply(color: AppTheme.pinkColor, fontWeightDelta: 2)),
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          primary: Color(0xfff1f1f1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          side: BorderSide(
            color: Colors.transparent,
          )),
    );
  }
}
