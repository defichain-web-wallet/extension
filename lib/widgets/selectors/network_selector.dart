import 'package:defi_wallet/bloc/account/account_cubit.dart';
import 'package:defi_wallet/bloc/bitcoin/bitcoin_cubit.dart';
import 'package:defi_wallet/bloc/home/home_cubit.dart';
import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/config/config.dart';
import 'package:defi_wallet/helpers/menu_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/settings_model.dart';
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


  bool isShowAllNetworks = true;
  NetworkTabs activeTab = NetworkTabs.all;
  String currentNetworkItem = 'DefiChain Mainnet';

  static const List<dynamic> mainnetNetworksList = [
    {
      'isTestnet': false,
      'value': NetworkList.defiMainnet,
      'name': 'DefiChain Mainnet',
    },
    {
      'isTestnet': false,
      'value': NetworkList.btcMainnet,
      'name': 'Bitcoin Mainnet',
    },
  ];

  static const List<dynamic> testnetNetworksList = [
    {
      'isTestnet': true,
      'value': NetworkList.defiTestnet,
      'name': 'DefiChain Testnet',
    },
    {
      'isTestnet': true,
      'value': NetworkList.btcTestnet,
      'name': 'Bitcoin Testnet',
    },
  ];

  final List<dynamic> tabs = [
    {'value': NetworkTabs.all, 'name': 'Mainnet'},
    {'value': NetworkTabs.test, 'name': 'Testnet'},
  ];

  Color getMarkColor(bool isActive) {
    if (isActive) {
      return AppColors.networkMarkColor;
    } else {
      return isDarkTheme()
          ? DarkColors.networkMarkColor
          : LightColors.networkMarkColor;
    }
  }

  void onChangeLocalSettings(NetworkList networkModel) async {
    AccountCubit accountCubit = BlocProvider.of<AccountCubit>(context);
    BitcoinCubit bitcoinCubit = BlocProvider.of<BitcoinCubit>(context);

    bool isBitcoin = networkModel == NetworkList.btcMainnet ||
        networkModel == NetworkList.btcTestnet;
    late String network;
    if (networkModel == NetworkList.btcMainnet ||
        networkModel == NetworkList.defiMainnet) {
      network = 'mainnet';
    } else {
      network = 'testnet';
    }

    SettingsHelper.settings.network = network;
    SettingsHelper.settings.isBitcoin = isBitcoin;
    await settingsHelper.saveSettings();
    if (isBitcoin) {
      await bitcoinCubit.loadDetails(accountCubit.state.activeAccount!.bitcoinAddress!);
    }
    await accountCubit.changeNetwork(
        SettingsHelper.settings.network!,
    );
  }

  getNetworkName() {
    SettingsModel settings = SettingsHelper.settings;
    String network = settings.network!;
    if (network == 'mainnet') {
      return (settings.isBitcoin!) ? 'Bitcoin Mainnet' : 'DefiChain Mainnet';
    } else {
      return (settings.isBitcoin!) ? 'Bitcoin Testnet' : 'DefiChain Testnet';
    }
  }

  onChangeNetwork(dynamic item) {
    NetworkCubit networkCubit = BlocProvider.of<NetworkCubit>(context);
    controller.hideMenu();
    if (item['value'] != NetworkList.defiMetaChainTestnet) {
      networkCubit.updateCurrentNetwork(item['value']);

      setState(() {
        currentNetworkItem = item['name'];
        onChangeLocalSettings(item['value']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double horizontalMargin = menuHelper.getHorizontalMargin(context);
    bool isFullScreen = MediaQuery.of(context).size.width > ScreenSizes.medium;
    HomeCubit homeCubit = BlocProvider.of<HomeCubit>(context);

    if (!widget.isAppBar) {
      return NetworkSelectorContent(
        networkName: getNetworkName(),
        mainnetNetworks: mainnetNetworksList,
        testnetNetworks: testnetNetworksList,
        tabs: tabs,
        onChange: (item) => onChangeNetwork(item),
      );
    } else if (isFullScreen) {
      return Container(
        child: GestureDetector(
          onTap: () {
            homeCubit.updateExtendedSelector(
                !homeCubit.state.isShowExtendedNetworkSelector);
          },
          child: NetworkSelectorButton(
            networkName: getNetworkName(),
          ),
        ),
      );
    } else {
      return CustomPopupMenu(
        child: NetworkSelectorButton(
          networkName: getNetworkName(),
        ),
        menuBuilder: () => NetworkSelectorContent(
          networkName: getNetworkName(),
          mainnetNetworks: mainnetNetworksList,
          testnetNetworks: testnetNetworksList,
          tabs: tabs,
          onChange: (item) => onChangeNetwork(item),
        ),
        showArrow: false,
        barrierColor: Colors.transparent,
        pressType: PressType.singleClick,
        verticalMargin: isFullScreen ? 2 : -5,
        horizontalMargin: isFullScreen ? -34 : horizontalMargin,
        controller: controller,
        enablePassEvent: false,
      );
    }

  }
}
