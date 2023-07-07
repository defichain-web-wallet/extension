import 'package:defi_wallet/mixins/dialog_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:defi_wallet/widgets/buttons/new_action_button.dart';
import 'package:defi_wallet/widgets/dialogs/select_payout_asset_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RewardIcon extends StatelessWidget with DialogMixin {
  final bool readonly;
  final Function(bool value) onTap;

  const RewardIcon({
    Key? key,
    required this.readonly,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      child: Center(
        child: readonly
            ? NewActionButton(
                isStaticColor: true,
                bgGradient: gradientActionButtonBg,
                iconPath: 'assets/icons/add.svg',
                onPressed: () {
                  showAppDialog(SelectPayoutAssetDialog(), context);
                },
              )
            : GestureDetector(
                onTap: () => onTap(!readonly),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SvgPicture.asset(
                    'assets/icons/edit_gradient.svg',
                    color: AppColors.grey,
                  ),
                ),
              ),
      ),
    );
  }
}
