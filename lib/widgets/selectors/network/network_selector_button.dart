import 'package:defi_wallet/bloc/network/network_cubit.dart';
import 'package:defi_wallet/bloc/refactoring/wallet/wallet_cubit.dart';
import 'package:defi_wallet/widgets/ticker_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkSelectorButton extends StatelessWidget {
  const NetworkSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: 24,
        width: 119,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(36),
        ),
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            return BlocBuilder<NetworkCubit, NetworkState>(
              builder: (context, networkState) {
                return Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Color(0xFF00CF21),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Flexible(
                            child: TickerText(
                              child: Text(
                                walletState.activeNetwork.networkNameFormat,
                                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: SvgPicture.asset(
                        'assets/icons/network_arrow_down.svg',
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
