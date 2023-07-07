import 'package:defi_wallet/helpers/balances_helper.dart';
import 'package:defi_wallet/mixins/theme_mixin.dart';
import 'package:defi_wallet/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StakingHeader extends StatefulWidget {
  final double apr;
  final double apy;

  const StakingHeader({
    super.key,
    required this.apr,
    required this.apy,
  });

  @override
  State<StakingHeader> createState() => _StakingHeaderState();
}

class _StakingHeaderState extends State<StakingHeader> with ThemeMixin {
  String getAprOrApyFormat(double amount, String amountType) {
    return '${BalancesHelper().numberStyling(
      (amount * 100),
      fixed: true,
      fixedCount: 2,
    )}% $amountType';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: isFullScreen(context) ? 0 : 8,
        left: isFullScreen(context) ? 0 : 16,
        right: isFullScreen(context) ? 0 : 16,
        bottom: 16,
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: isFullScreen(context) ? 0 : 20,
                ),
                padding: EdgeInsets.only(top: isFullScreen(context) ? 80 : 38),
                width: isFullScreen(context) ? 488 : 328,
                height: isFullScreen(context) ? 167 : 123,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDarkTheme()
                      ? AppColors.white.withOpacity(0.04)
                      : LightColors.scaffoldContainerBgColor,
                  border: isDarkTheme()
                      ? Border.all(
                          width: 1.0,
                          color: Colors.white.withOpacity(0.05),
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'DFI Staking by LOCK',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '${getAprOrApyFormat(widget.apy, 'APY')} / '
                      '${getAprOrApyFormat(widget.apr, 'APR')}',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.6),
                          ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      '5.55% Fee',
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                            fontSize: 12,
                            color: Theme.of(context)
                                .textTheme
                                .headline5!
                                .color!
                                .withOpacity(0.3),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: isFullScreen(context) ? 18 : 0),
                padding: EdgeInsets.only(
                  top: 7.17,
                  bottom: 11.77,
                  left: 3,
                  right: 12.77,
                ),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF167156),
                ),
                child: SvgPicture.asset(
                  'assets/icons/staking_lock.svg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
