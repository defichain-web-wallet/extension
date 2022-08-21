import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryHelper {
  Future<void> openTxOnExplorer(String txid) async {
    String link =
        'https://defiscan.live/transactions/$txid?network=${SettingsHelper.settings.network!}';
    launch(link);
  }

  String getTransactionType(String type) {
    switch (type) {
      case 'AddPoolLiquidity':
        return 'Add Liquidity';
      case 'RemovePoolLiquidity':
        return 'Remove Liquidity';
      case 'UtxosToAccount':
        return 'UtxosToAccount';
      case 'AccountToUtxos':
        return 'AccountToUtxos';
      case 'PoolSwap':
        return 'Swap';
      case 'SEND':
      case 'vin':
        return 'Send';
      case 'RECEIVE':
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
