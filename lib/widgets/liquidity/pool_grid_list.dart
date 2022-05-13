import 'package:defi_wallet/bloc/tokens/tokens_state.dart';
import 'package:defi_wallet/screens/liquidity/select_pool.dart';
import 'package:defi_wallet/widgets/liquidity/pool_asset_pair.dart';
import 'package:flutter/material.dart';

class PoolGridList extends StatelessWidget {
  final TokensLoadedState? tokensState;
  final bool? isFullSize;

  const PoolGridList({Key? key, this.tokensState, this.isFullSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate:
            const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                childAspectRatio: 1.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemCount: tokensState!.tokensPairs.length,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            itemBuilder: (BuildContext ctx, index) {
              return InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectPool(
                          assetPair: tokensState!.tokensPairs[index],
                        )),
                  );
                },
                child: PoolAssetPair(
                  assetPair: tokensState!.tokensPairs[index],
                  isFullSize: isFullSize!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
