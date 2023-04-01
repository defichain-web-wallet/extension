import 'package:defi_wallet/bloc/easter_egg/easter_egg_cubit.dart';
import 'package:defi_wallet/widgets/easter_eggs/egg_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleEasterEgg extends StatefulWidget {
  final index;
  final double width;
  final double height;

  const SingleEasterEgg({
    Key? key,
    required this.index,
    this.width = 18,
    this.height = 23,
  }) : super(key: key);

  @override
  State<SingleEasterEgg> createState() => _SingleEasterEggState();
}

class _SingleEasterEggState extends State<SingleEasterEgg> {
  static const eggCounts = 5;
  static const List<dynamic> phrases = [
    {
      'name': 'Secure',
    },
    {
      'name': 'Flexible',
    },
    {
      'name': 'Easy-to-Use',
    },
    {
      'name': 'Good-Looking',
    },
    {
      'name': 'sounds like Jellywallet',
    },
  ];

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
    bool isAvailableEgg = false;
    return BlocBuilder<EasterEggCubit, EasterEggState>(
        builder: (BuildContext easterEggContext, easterEggState) {
      if (easterEggState.eggsStatus != null) {
        switch (widget.index) {
          case 1:
            isAvailableEgg = easterEggState.eggsStatus!.isCollectFirstEgg!;
            break;
          case 2:
            isAvailableEgg = easterEggState.eggsStatus!.isCollectSecondEgg!;
            break;
          case 3:
            isAvailableEgg = easterEggState.eggsStatus!.isCollectThirdEgg!;
            break;
          case 4:
            isAvailableEgg = easterEggState.eggsStatus!.isCollectFourthEgg!;
            break;
          case 5:
            isAvailableEgg = easterEggState.eggsStatus!.isCollectFifthEgg!;
            break;
          default:
            isAvailableEgg = false;
        }
      }
      if (easterEggState.eggsStatus != null && !isAvailableEgg) {
        return Transform.rotate(
          angle: 24.64 * 3.1415926535 / 180,
          child: GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext eggContext) {
                    return EggDialog(
                      eggNumber: widget.index,
                      prase: phrases[widget.index - 1]['name'],
                      gifPath:
                          'assets/easter_eggs/easter_egg_${widget.index}.gif',
                      firstMessageText:
                          'Nice one! You just found an Easter egg!',
                    );
                  });
            },
            child: Image.asset(
              'assets/easter_eggs/easter_egg_${widget.index}.png',
              width: widget.width,
              height: widget.height,
            ),
          ),
        );
      } else {
        return Container();
      }
    });
  }
}
