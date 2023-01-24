import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/screens/liquidity/liquidity_remove_screen.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/account_drawer/account_drawer.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/responsive/stretch_box.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/sliders/polygon_slider_thumb.dart';
import 'package:defi_wallet/widgets/toolbar/new_main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class StakeUnstakeScreen extends StatefulWidget {
  final bool isUnstake;

  const StakeUnstakeScreen({
    Key? key,
    this.isUnstake = false,
  }) : super(key: key);

  @override
  State<StakeUnstakeScreen> createState() => _StakeUnstakeScreenState();
}

class _StakeUnstakeScreenState extends State<StakeUnstakeScreen>
    with ThemeMixin {
  final String changeDfiText = 'Please note that currently only DFI UTXO can '
      'be added to staking. You can exchange DFI tokens by pressing here.';
  final String warningText = 'You can also deposit DFI directly from an other '
      'DeFiChain address. Simply send the DFI to this staking deposit address.';
  final FocusNode _focusNode = FocusNode();
  TextEditingController controller = TextEditingController();
  bool _onFocused = false;
  double currentSliderValue = 0;

  late String titleText;

  @override
  void initState() {
    _focusNode.addListener(_onFocusChange);
    titleText = widget.isUnstake ? 'Unstake' : 'Stake';
    controller.text = '0';
    // TODO: implement initState
    super.initState();
  }

  _onFocusChange() {
    if (controller.text == '') {
      controller.text = '0';
    }
    setState(() {
      _onFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      builder: (
        BuildContext context,
        bool isFullScreen,
        TransactionState txState,
      ) {
        return Scaffold(
          drawerScrimColor: Color(0x0f180245),
          endDrawer: AccountDrawer(
            width: buttonSmallWidth,
          ),
          appBar: NewMainAppBar(
            isShowLogo: false,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: AppColors.viridian.withOpacity(0.16),
            ),
            child: Container(
              padding: EdgeInsets.only(
                top: 22,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: isDarkTheme()
                    ? DarkColors.scaffoldContainerBgColor
                    : LightColors.scaffoldContainerBgColor,
                border: isDarkTheme()
                    ? Border.all(
                        width: 1.0,
                        color: Colors.white.withOpacity(0.05),
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: StretchBox(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                titleText,
                                style: headline2.copyWith(
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          GestureDetector(
                            onTap: () => _focusNode.requestFocus(),
                            child: Container(
                              // height: 80,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 8,
                                left: 12,
                                right: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: _onFocused
                                    ? GradientBoxBorder(
                                        gradient: gradientWrongMnemonicWord,
                                      )
                                    : Border.all(
                                        color: LightColors
                                            .amountFieldBorderColor
                                            .withOpacity(0.32),
                                      ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: SizedBox(
                                            height: 42,
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp("[0-9\.-]"),
                                                  replacementString: ('.'),
                                                ),
                                                FilteringTextInputFormatter
                                                    .deny(
                                                  RegExp(r'\.\.+'),
                                                  replacementString: '.',
                                                ),
                                                FilteringTextInputFormatter
                                                    .deny(
                                                  RegExp(r'^\.'),
                                                  replacementString: '0.',
                                                ),
                                                FilteringTextInputFormatter
                                                    .deny(
                                                  RegExp(r'\.\d+\.'),
                                                ),
                                                FilteringTextInputFormatter
                                                    .deny(
                                                  RegExp(r'\d+-'),
                                                ),
                                                FilteringTextInputFormatter
                                                    .deny(
                                                  RegExp(r'-\.+'),
                                                ),
                                                FilteringTextInputFormatter
                                                    .deny(
                                                  RegExp(r'^0\d+'),
                                                ),
                                              ],
                                              controller: controller,
                                              focusNode: _focusNode,
                                              onChanged: (value) {},
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline4!
                                                  .copyWith(
                                                    fontSize: 20,
                                                  ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.all(0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 38,
                                          padding: EdgeInsets.only(
                                            left: 6,
                                            bottom: 6,
                                            top: 6,
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDarkTheme()
                                                ? DarkColors
                                                    .assetSelectorBgColor
                                                    .withOpacity(0.07)
                                                : LightColors
                                                    .assetSelectorBgColor
                                                    .withOpacity(0.07),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/tokens/defi.svg'),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'DFI',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5!
                                                    .copyWith(
                                                        fontSize: 20,
                                                        height: 1.26),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TEST',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6!
                                                  .color!
                                                  .withOpacity(0.3),
                                            ),
                                      ),
                                      Text(
                                        'Available: TEST',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headline6!
                                                  .color!
                                                  .withOpacity(0.3),
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (widget.isUnstake)
                                    Column(
                                      children: [
                                        Container(
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              thumbShape: PolygonSliderThumb(
                                                thumbRadius: 16.0,
                                              ),
                                            ),
                                            child: Slider(
                                              value: currentSliderValue,
                                              max: 100,
                                              divisions: 100,
                                              label: currentSliderValue
                                                  .round()
                                                  .toString(),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SliderButton(
                                                isFullSize: isFullScreen,
                                                value: 25,
                                                onPressed: () {
                                                  setState(() {
                                                    currentSliderValue = 25;
                                                  });
                                                },
                                              ),
                                              SliderButton(
                                                isFullSize: isFullScreen,
                                                value: 50,
                                                onPressed: () {
                                                  setState(() {
                                                    currentSliderValue = 50;
                                                  });
                                                },
                                              ),
                                              SliderButton(
                                                isFullSize: isFullScreen,
                                                value: 75,
                                                onPressed: () {
                                                  setState(() {
                                                    currentSliderValue = 75;
                                                  });
                                                },
                                              ),
                                              SliderButton(
                                                isFullSize: isFullScreen,
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
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.viridian.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: SvgPicture.asset(
                                          'assets/icons/compare_arrow.svg'),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        changeDfiText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              Text(
                                'DFI Deposit address ',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .copyWith(
                                      fontSize: 16,
                                    ),
                              ),
                              Text(
                                '(optional)',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .color!
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.viridian.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 10),
                                      child: SvgPicture.asset(
                                          'assets/icons/copy.svg'),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'df1qx5hrapsrpzg8mqm473crdj0dz7y2j7e...6k0tf',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5!
                                            .copyWith(
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 10),
                                    child: SvgPicture.asset(
                                        'assets/icons/important_icon.svg'),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      warningText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        NewPrimaryButton(
                          width: buttonSmallWidth,
                          title: 'Continue',
                          callback: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
