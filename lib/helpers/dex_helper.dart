import 'package:defi_wallet/bloc/tokens/tokens_cubit.dart';
import 'package:defi_wallet/models/account_model.dart';
import 'package:defi_wallet/models/address_model.dart';
import 'package:defi_wallet/models/balance_model.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/test_pool_swap_model.dart';
import 'package:defi_wallet/models/token_model.dart';
import 'package:defi_wallet/requests/balance_requests.dart';
import 'package:defi_wallet/requests/dex_requests.dart';
import 'package:defi_wallet/requests/history_requests.dart';
import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'package:defichaindart/defichaindart.dart';

class DexHelper {
  //TODO: move to constants_file
  static const int AuthTxMin = 200000;
  DexRequests _dexRequests = DexRequests();
  TransactionRequests _txRequests = TransactionRequests();

  Future<TestPoolSwapModel> calculateDex(String tokenFrom, String tokenTo,
      double? amountFrom, double? amountTo, String address, List<AddressModel> addressList, TokensState tokensState) async {
    List<double> rates = [];
    if(tokenTo == tokenFrom){
      rates = [1, 1];
    } else {
      var responce = await _dexRequests.getDexRate(tokenTo, tokenFrom, tokensState);
      rates = responce!;
    }

    var dexModel = TestPoolSwapModel(
        tokenTo: tokenTo,
        tokenFrom: tokenFrom,
        priceFrom: rates[0],
        priceTo: rates[1]);
    if (amountFrom == null) {
      dexModel.amountFrom = double.parse((rates[1] * amountTo!).toStringAsFixed(8));
      dexModel.amountTo = double.parse((amountTo).toStringAsFixed(8));
    } else {
      dexModel.amountTo =  double.parse((rates[0] * amountFrom).toStringAsFixed(8));
      dexModel.amountFrom =  double.parse((amountFrom).toStringAsFixed(8));
    }
    dexModel.fee = await caclulateFee(addressList);

    return dexModel;
  }

  Future<int> caclulateFee(List<AddressModel> addressList) async {
    var utxos = await _txRequests.getUTXOs(addresses: addressList);
    return (utxos.length + 1) *  AuthTxMin;
  }
}
