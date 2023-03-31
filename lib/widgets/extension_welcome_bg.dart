import 'package:defi_wallet/bloc/easter_egg/easter_egg_cubit.dart';
import 'package:defi_wallet/widgets/easter_eggs/egg_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ExtensionWelcomeBg extends StatefulWidget {
  const ExtensionWelcomeBg({Key? key}) : super(key: key);

  @override
  State<ExtensionWelcomeBg> createState() => _ExtensionWelcomeBgState();
}

class _ExtensionWelcomeBgState extends State<ExtensionWelcomeBg> {
  final String coordsLink = 'https://www.google.com/maps/place/7%C2%B009\''
      '39.8%22N+134%C2%B022\'36.0%22E/@7.1642247,134.3802637,13.92z/'
      'data=!4m5!3m4!1s0x0:0xded8284159939dd5!8m2!3d7.161057!4d134.376672';

  @override
  void initState() {
    EasterEggCubit easterEggCubit = BlocProvider.of<EasterEggCubit>(context);
    Future.delayed(Duration.zero, () async {
      await easterEggCubit.getStatuses();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        height: 600,
        child: Stack(
          children: [
            Image.asset('assets/images/welcome_background.png'),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8),
              child: Text(
                'version',
                style: TextStyle(
                  fontFamily: 'GalanoGrotesque',
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 8),
              child: Text(
                '2.1.3',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 54),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/welcome_logo.svg'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 83,
                left: 202,
              ),
              child: GestureDetector(
                onTap: () {
                  launch(coordsLink);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Stack(
                    children: [
                      Text(
                        '7° 9\' 39.8052\'\' N',
                        style: TextStyle(
                          // fontFamily: 'GalanoGrotesque',
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          '134° 22\' 36.0192\'\' E',
                          style: TextStyle(
                            // fontFamily: 'GalanoGrotesque',
                            fontWeight: FontWeight.w700,
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BlocBuilder<EasterEggCubit, EasterEggState>(
                builder: (BuildContext easterEggContext, easterEggState) {
              if (easterEggState.eggsStatus != null &&
                  !easterEggState.eggsStatus!.isCollectFirstEgg!) {
                return Padding(
                  padding:
                      EdgeInsets.only(left: 87, top: 285, right: 0, bottom: 0),
                  child: Transform.rotate(
                    angle: 24.64 * 3.1415926535 / 180,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext eggContext) {
                              return EggDialog(
                                eggNumber: 1,
                                prase: 'Secure',
                                gifPath: 'assets/easter_eggs/easter_egg_1.gif',
                                firstMessageText:
                                    'Nice one! You just found an Easter egg!',
                              );
                            });
                      },
                      child: Image.asset(
                        'assets/easter_eggs/easter_egg_1.png',
                        width: 18,
                        height: 23,
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
            BlocBuilder<EasterEggCubit, EasterEggState>(
                builder: (BuildContext easterEggContext, easterEggState) {
                  if (easterEggState.eggsStatus != null &&
                      !easterEggState.eggsStatus!.isCollectSecondEgg!) {
                    return Padding(
                      padding:
                      EdgeInsets.only(left: 105, top: 285, right: 0, bottom: 0),
                      child: Transform.rotate(
                        angle: 24.64 * 3.1415926535 / 180,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext eggContext) {
                                  return EggDialog(
                                    eggNumber: 2,
                                    prase: 'Flexible',
                                    gifPath: 'assets/easter_eggs/easter_egg_2.gif',
                                    firstMessageText:
                                    'You did it! You found an Easter egg!',
                                  );
                                });
                          },
                          child: Image.asset(
                            'assets/easter_eggs/easter_egg_2.png',
                            width: 18,
                            height: 23,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
            BlocBuilder<EasterEggCubit, EasterEggState>(
                builder: (BuildContext easterEggContext, easterEggState) {
                  if (easterEggState.eggsStatus != null &&
                      !easterEggState.eggsStatus!.isCollectThirdEgg!) {
                    return Padding(
                      padding:
                      EdgeInsets.only(left: 125, top: 285, right: 0, bottom: 0),
                      child: Transform.rotate(
                        angle: 24.64 * 3.1415926535 / 180,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext eggContext) {
                                  return EggDialog(
                                    eggNumber: 3,
                                    prase: 'Easy-to-Use',
                                    gifPath: 'assets/easter_eggs/easter_egg_3.gif',
                                    firstMessageText:
                                    'You\'re a pro at this! Another Easter egg found!',
                                  );
                                });
                          },
                          child: Image.asset(
                            'assets/easter_eggs/easter_egg_3.png',
                            width: 18,
                            height: 23,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
            BlocBuilder<EasterEggCubit, EasterEggState>(
                builder: (BuildContext easterEggContext, easterEggState) {
                  if (easterEggState.eggsStatus != null &&
                      !easterEggState.eggsStatus!.isCollectFourthEgg!) {
                    return Padding(
                      padding:
                      EdgeInsets.only(left: 145, top: 285, right: 0, bottom: 0),
                      child: Transform.rotate(
                        angle: 24.64 * 3.1415926535 / 180,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext eggContext) {
                                  return EggDialog(
                                    eggNumber: 4,
                                    prase: 'Good-Looking',
                                    gifPath: 'assets/easter_eggs/easter_egg_4.gif',
                                    firstMessageText:
                                    'Congratulations, you found an Easter egg!',
                                  );
                                });
                          },
                          child: Image.asset(
                            'assets/easter_eggs/easter_egg_4.png',
                            width: 18,
                            height: 23,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
            BlocBuilder<EasterEggCubit, EasterEggState>(
                builder: (BuildContext easterEggContext, easterEggState) {
                  if (easterEggState.eggsStatus != null &&
                      !easterEggState.eggsStatus!.isCollectFifthEgg!) {
                    return Padding(
                      padding:
                      EdgeInsets.only(left: 165, top: 285, right: 0, bottom: 0),
                      child: Transform.rotate(
                        angle: 24.64 * 3.1415926535 / 180,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext eggContext) {
                                  return EggDialog(
                                    eggNumber: 5,
                                    prase: 'sounds like Jellywallet',
                                    gifPath: 'assets/easter_eggs/easter_egg_5.gif',
                                    firstMessageText:
                                    'Egg-cellent work! You found an Easter egg!',
                                  );
                                });
                          },
                          child: Image.asset(
                            'assets/easter_eggs/easter_egg_5.png',
                            width: 18,
                            height: 23,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
