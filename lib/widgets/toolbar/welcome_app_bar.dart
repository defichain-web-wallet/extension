import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  static const double toolbarHeight = 50;
  static const double iconHeight = 30;

  const WelcomeAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      toolbarHeight: toolbarHeight,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.asset('assets/icons/arrow_back.svg'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'JellyWallet',
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}

// TODO: remove this
// Container(
// height: 4,
// width: 200,
// decoration: BoxDecoration(
// gradient: LinearGradient(
// colors: [
// Colors.orange,
// Colors.orangeAccent,
// Colors.red,
// Colors.redAccent
// //add more colors for gradient
// ],
// begin: Alignment.topLeft, //begin of the gradient color
// end: Alignment.bottomRight, //end of the gradient color
// stops: [0, 0.2, 0.5, 0.8] //stops for individual color
// //set the stops number equal to numbers of color
// ),
// ),
// ),