import 'package:defi_wallet/helpers/lock_helper.dart';
import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/helpers/tokens_helper.dart';
import 'package:defi_wallet/models/asset_pair_model.dart';
import 'package:defi_wallet/screens/liquidity/remove_liquidity.dart';
import 'package:defi_wallet/screens/liquidity/select_pool.dart';
import 'package:defi_wallet/utils/app_theme/app_theme.dart';
import 'package:defi_wallet/widgets/liquidity/asset_pair.dart';
import 'package:defi_wallet/widgets/liquidity/liquidity_asset_pair.dart';
import 'package:flutter/material.dart';

class MainLiquidityPair extends StatelessWidget {
  final AssetPairModel? assetPair;
  final int? balance;

  const MainLiquidityPair(
      {Key? key,
      this.assetPair,
      this.balance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LockHelper lockHelper = LockHelper();

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      leading: AssetPair(pair: assetPair!.symbol!, size: 25),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              child: Text(
                TokensHelper().getTokenFormat(assetPair!.symbol),
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .apply(fontWeightDelta: 3, fontSizeDelta: 2),
              ),
            ),
          ),
          LiquidityAssetPair(assetPair: assetPair, balance: balance),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => lockHelper.provideWithLockChecker(
                    context,
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectPool(
                                    assetPair: assetPair!,
                                  )),
                        )),
                child: Icon(
                  Icons.add,
                  size: 16,
                  color: AppTheme.pinkColor,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
                  minimumSize: MaterialStateProperty.all(Size(24, 30)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10)),
                  )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
              ),
              ElevatedButton(
                onPressed: () => lockHelper.provideWithLockChecker(
                    context,
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RemoveLiquidity(
                                    assetPair: assetPair!,
                                    balance: balance!,
                                  )),
                        )),
                child: Icon(
                  Icons.remove,
                  size: 16,
                  color: Colors.black,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
                  minimumSize: MaterialStateProperty.all(Size(24, 30)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
