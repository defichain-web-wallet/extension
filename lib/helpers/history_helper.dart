import 'package:defi_wallet/helpers/settings_helper.dart';
import 'package:defi_wallet/models/history_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
      case 'UtxosToAccount':
        return 'UtxosToAccount';
      case 'AccountToUtxos':
        return 'AccountToUtxos';
      case 'AccountToAccount':
        return 'AccountToAccount';
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

  void openExplorerLink(String txId) {
    if (SettingsHelper.isBitcoin()) {
      if (SettingsHelper.settings.network! ==
          'mainnet') {
        launch(
            'https://live.blockcypher.com/btc/tx/$txId',
        );
      } else {
        launch(
          'https://live.blockcypher.com/btc-testnet/tx/$txId',
        );
      }
    } else {
      launch(
        'https://defiscan.live/transactions/$txId?network=${SettingsHelper.settings.network}',
      );
    }
  }
}
