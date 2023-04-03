import 'dart:async';
import 'dart:ui';

import 'package:defi_wallet/bloc/easter_egg/easter_egg_cubit.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/easter_egg_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/easter_eggs/typing_dotted.dart';
import 'package:defi_wallet/widgets/easter_eggs/scale_animation.dart';
import 'package:defi_wallet/widgets/easter_eggs/jelly_custom_animation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class EggDialog extends StatefulWidget {
  final String prase;
  final String firstMessageText;
  final String gifPath;
  final int eggNumber;
  final bool isVisibleBg;

  const EggDialog({
    Key? key,
    required this.prase,
    required this.firstMessageText,
    required this.gifPath,
    required this.eggNumber,
    required this.isVisibleBg,
  }) : super(key: key);

  @override
  State<EggDialog> createState() => _EggDialogState();
}

class _EggDialogState extends State<EggDialog> with ThemeMixin {
  late double mainEggTopPadding;
  int iterator = 0;
  late Timer timer;
  bool isJellyFaceVisible = false;
  bool isShowFirstMessage = false;
  bool isShowSecondMessage = false;
  bool isShowThirdMessage = false;
  bool isTypingDottedVisible = false;
  bool isShowCancel = false;
  bool isCopied = false;
  int globalDuration = 100;
  Color bgPhrase = AppColors.white;

  @override
  void initState() {
    mainEggTopPadding = 90;
    timer = Timer.periodic(Duration(milliseconds: globalDuration), (timer) {
      if (iterator == 5) {
        setState(() {
          isJellyFaceVisible = true;
          isTypingDottedVisible = true;
        });
      }
      if (iterator == 15) {
        setState(() {
          isShowFirstMessage = true;
          isTypingDottedVisible = false;
        });
      }
      if (iterator == 16) {
        setState(() {
          isTypingDottedVisible = true;
        });
      }
      if (iterator == 31) {
        setState(() {
          isShowSecondMessage = true;
          isTypingDottedVisible = false;
        });
      }
      if (iterator == 32) {
        setState(() {
          isTypingDottedVisible = true;
        });
      }
      if (iterator == 47) {
        setState(() {
          isTypingDottedVisible = false;
          isShowThirdMessage = true;
          isShowCancel = true;
          timer.cancel();
        });
      }
      iterator++;
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EasterEggCubit easterEggCubit = BlocProvider.of<EasterEggCubit>(context);
    return BlocBuilder<EasterEggCubit, EasterEggState>(
        builder: (BuildContext easterEggContext, easterEggState) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
        child: AlertDialog(
          insetPadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.zero,
          backgroundColor: widget.isVisibleBg ? Color(0xff352D92).withOpacity(0.33) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: isDarkTheme()
                ? BorderSide(color: DarkColors.drawerBorderColor)
                : BorderSide.none,
          ),
          content: Container(
            width: 360,
            height: double.infinity,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: mainEggTopPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleAnimation(
                        width: 140,
                        height: 132,
                        duration: Duration(milliseconds: 200),
                        child: Container(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 87.0),
                                child: Image.asset(
                                  'assets/easter_eggs/ellipse_white.png',
                                  width: 140,
                                  height: 31,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 92.0, left: 53),
                                child: Image.asset(
                                  'assets/easter_eggs/ellipse_pink.png',
                                  width: 87,
                                  height: 19,
                                ),
                              ),
                              Image.asset(
                                widget.gifPath,
                                width: 131,
                                height: 173,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isJellyFaceVisible)
                  JellyCustomAnimation(
                    begin: Offset(25, 600),
                    end: Offset(25, 400),
                    child: Image.asset(
                      'assets/easter_eggs/jelly_face.png',
                      width: 360,
                      height: 203,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 260),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isShowFirstMessage)
                        ScaleAnimation(
                          width: 213,
                          height: 51,
                          duration: Duration(milliseconds: 100),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 213),
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: AppColors.white),
                            child: Text(
                              widget.firstMessageText,
                              softWrap: true,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(fontSize: 15),
                            ),
                          ),
                        ),
                      if (isShowSecondMessage)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ScaleAnimation(
                            width: 313,
                            height: 75,
                            duration: Duration(milliseconds: 100),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 203),
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(11),
                                  color: AppColors.white),
                              child: RichText(
                                softWrap: true,
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'After you\'ve found all five words you can paste them ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                            fontSize: 15,
                                          ),
                                    ),
                                    TextSpan(
                                      mouseCursor: SystemMouseCursors.click,
                                      text: 'here',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppColors.pinkColor,
                                              fontSize: 15),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launch(
                                              'https://gleam.io/UypGT/jellywallet-easter-egg-hunt');
                                        },
                                    ),
                                    TextSpan(
                                      text: ' to become the lucky winner:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                            fontSize: 15,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isShowThirdMessage)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ScaleAnimation(
                            width: 144,
                            height: 61,
                            duration: Duration(milliseconds: 100),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: widget.prase),
                                );
                                setState(() {
                                  isCopied = true;
                                });
                              },
                              child: Center(
                                child: Text(
                                  '${widget.eggNumber}. ${widget.prase}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isTypingDottedVisible)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 10),
                          child: TypingDotted(dotSize: 10.0, spacing: 10.0),
                        ),
                      if (isCopied)
                        Container(
                          width: 144,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                width: 117,
                                height: 27,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xffEFEDF8),
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  ),
                                  color: AppColors.white.withOpacity(0.65),
                                ),
                                child: Center(
                                  child: Text(
                                    'Copied to clipboard!',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff0C0321).withOpacity(0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isShowCancel)
                  Padding(
                    padding: EdgeInsets.only(top: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              await easterEggCubit.saveStatuses(getStatuses(
                                easterEggState.eggsStatus!,
                                widget.eggNumber,
                              ));
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.close,
                              size: 28,
                              color: AppColors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  getStatuses(
    EasterEggModel model,
    int i,
  ) {
    EasterEggModel localModel;
    localModel = EasterEggModel(
      isCollectFirstEgg: i == 1 ? true : model.isCollectFirstEgg,
      isCollectSecondEgg: i == 2 ? true : model.isCollectSecondEgg,
      isCollectThirdEgg: i == 3 ? true : model.isCollectThirdEgg,
      isCollectFourthEgg: i == 4 ? true : model.isCollectFourthEgg,
      isCollectFifthEgg: i == 5 ? true : model.isCollectFifthEgg,
    );
    return localModel;
  }
}
