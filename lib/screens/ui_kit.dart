import 'package:defi_wallet/bloc/theme/theme_cubit.dart';
import 'package:defi_wallet/bloc/transaction/transaction_state.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/mixins/dialog_mixin.dart';
import 'package:defi_wallet/mixins/snack_bar_mixin.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/models/settings_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/flat_button.dart';
import 'package:defi_wallet/widgets/buttons/new_primary_button.dart';
import 'package:defi_wallet/widgets/defi_checkbox.dart';
import 'package:defi_wallet/widgets/dialogs/choose_payout_strategy_dialog.dart';
import 'package:defi_wallet/widgets/dialogs/select_payout_asset_dialog.dart';
import 'package:defi_wallet/widgets/dialogs/staking_add_asset_dialog.dart';
import 'package:defi_wallet/widgets/dialogs/tx_status_dialog.dart';
import 'package:defi_wallet/widgets/fields/amount_field.dart';
import 'package:defi_wallet/widgets/fields/password_text_field.dart';
import 'package:defi_wallet/widgets/scaffold_wrapper.dart';
import 'package:defi_wallet/widgets/selectors/fees_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/selectors/app_selector.dart';

class UiKit extends StatefulWidget {
  const UiKit({Key? key}) : super(key: key);

  @override
  State<UiKit> createState() => _UiKitState();
}

class _UiKitState extends State<UiKit>
    with SnackBarMixin, SingleTickerProviderStateMixin, ThemeMixin, DialogMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  )
    ..repeat();
  TextEditingController controller = TextEditingController();
  bool isObscure1 = false;
  bool isObscure2 = true;
  bool value = false;
  List<String> tokensForSwap = [];
  TokensModel? currentAsset;

  @override
  void initState() {
    Future<Null>.delayed(Duration.zero, () {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(builder: (BuildContext context,
        bool isFullScreen,
        TransactionState transactionState,) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ui kit'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  SettingsHelper settingsHelper = SettingsHelper();
                  SettingsModel localSettings = SettingsHelper.settings.clone();
                  localSettings.theme =
                  (localSettings.theme == 'Dark') ? 'Light' : 'Dark';
                  SettingsHelper.settings = localSettings;
                  settingsHelper.saveSettings();
                  ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
                  themeCubit.changeTheme();
                },
                child: Icon(Icons.lightbulb))
          ],
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NewPrimaryButton(
                title: 'First dialog',
                callback: () {
                  showAppDialog(SelectPayoutAssetDialog(), context);
                },
              ),
              NewPrimaryButton(
                title: 'Second dialog',
                callback: (){
                  showAppDialog(ChoosePayoutStrategyDialog(assetName: 'DFI',), context);
                },
              ),
              NewPrimaryButton(
                title: 'Third dialog',
                callback: (){
                  // showAppDialog(StakingAddAssetDialog(), context);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  redirectToTest() {}
}
