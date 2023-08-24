import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/services/navigation/navigator_service.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/selectors/network/network_selector_button.dart';
import 'package:defi_wallet/widgets/selectors/network/network_selector_content.dart';
import 'package:flutter/material.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkSelector extends StatefulWidget {
  final bool isAppBar;
  final void Function() onSelect;

  NetworkSelector({
    Key? key,
    required this.onSelect,
    this.isAppBar = true,
  }) : super(key: key);

  @override
  _NetworkSelectorState createState() => _NetworkSelectorState();
}

class _NetworkSelectorState extends State<NetworkSelector> with ThemeMixin {
  CustomPopupMenuController controller = CustomPopupMenuController();
  MenuHelper menuHelper = MenuHelper();

  late AbstractAccountModel activeAccount;

  final List<dynamic> tabs = [
    {'value': NetworkTabs.all, 'name': 'Mainnet'},
    {'value': NetworkTabs.test, 'name': 'Testnet'},
  ];

  void initState() {
    super.initState();

    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    activeAccount = walletCubit.state.activeAccount;
  }

  onChangeNetwork(AbstractNetworkModel item) {
    WalletCubit walletCubit = BlocProvider.of<WalletCubit>(context);
    controller.hideMenu();
    walletCubit.changeActiveNetwork(item);

    NavigatorService.pushReplacement(context, null);
  }

  double _getVerticalMargin(BuildContext context) {
    if (isLargeScreen(context)) {
      return 2;
    } else if (isSmallScreen(context)) {
      return 10;
    } else {
      return -5;
    }
  }

  double _getHorizontalMargin(BuildContext context) {
    if (isLargeScreen(context)) {
      return -34;
    } else {
      return 16;
    }
  }

  onWalletStateChanged(WalletState state) {
    if (state.activeAccount.id != activeAccount.id) {
      setState(() {
        activeAccount = state.activeAccount;
        var firstNetworkModel =
            activeAccount.getNetworkModelList(state.applicationModel!).first;
        onChangeNetwork(firstNetworkModel);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);

    if (!widget.isAppBar) {
      return NetworkSelectorContent(
        tabs: tabs,
        onChange: (item) => onChangeNetwork(item),
      );
    } else if (isLargeScreen(context)) {
      return Container(
        child: GestureDetector(
          onTap: () {
            homeCubit.updateExtendedSelector(
              !homeCubit.state.isShowExtendedNetworkSelector,
            );
          },
          child: NetworkSelectorButton(),
        ),
      );
    } else {
      return CustomPopupMenu(
        child: NetworkSelectorButton(),
        menuBuilder: () => NetworkSelectorContent(
          tabs: tabs,
          onChange: (item) => onChangeNetwork(item),
        ),
        showArrow: false,
        barrierColor: Colors.transparent,
        pressType: PressType.singleClick,
        verticalMargin: _getVerticalMargin(context),
        horizontalMargin: _getHorizontalMargin(context),
        controller: controller,
        enablePassEvent: false,
      );
    }
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double startMargin = 0;

    final double s1 = height * 0.3;
    final double s2 = height * 0.7;

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startMargin, 0, width - startMargin, height),
          const Radius.circular(16),
        ),
      )
      ..lineTo(startMargin, s1)
      ..lineTo(startMargin, s2)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ArrowPainter extends CustomPainter {
  final CustomClipper<Path> clipper = ArrowClipper();

  @override
  void paint(Canvas canvas, Size size) {
    var path = clipper.getClip(size);
    Paint paint = new Paint()
      ..color = AppColors.white.withOpacity(0.04)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
