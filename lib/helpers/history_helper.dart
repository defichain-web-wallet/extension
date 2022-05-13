import 'package:defi_wallet/models/history_model.dart';

class HistoryHelper {
  sortHistoryList(List<HistoryModel> list) {
   list.sort((a, b) {
      int aDate = DateTime.parse(a.blockTime ?? '').microsecondsSinceEpoch;
      int bDate = DateTime.parse(b.blockTime ?? '').microsecondsSinceEpoch;
      return bDate.compareTo(aDate);
    });
  }

  String getTransactionType(String type) {
    switch (type) {
      case 'AddPoolLiquidity':
        return 'Add Liquidity';
      case 'RemovePoolLiquidity':
        return 'Remove Liquidity';
      case 'PoolSwap':
        return 'Swap';
      case 'vin':
        return 'Send';
      case 'vout':
        return 'Receive';
      default:
        return 'Other';
    }
  }

  bool isAvailableTypes(String type) {
    return !'AddPoolLiquidity|RemovePoolLiquidity|PoolSwap|vin|vout'
        .contains(type);
  }
}
