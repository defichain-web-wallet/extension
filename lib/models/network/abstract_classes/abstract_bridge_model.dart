import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';

abstract class AbstractBridge {
  final BitcoinNetworkModel networkType;
  final int activeFee;
  final int totalBalance;
  final int unconfirmedBalance;
  late final int availableBalance;
  final NetworkFeeModel? networkFee;
  final List<HistoryModel> history;

  AbstractBridge(
    this.networkType,
    this.activeFee,
    this.totalBalance,
    this.unconfirmedBalance,
    this.availableBalance,
    this.networkFee,
    this.history,
  );

  Future<int> getBalance(
    BitcoinNetworkModel network,
    String addressString,
  );

  Future<void> getAvailableBalance(
    BitcoinNetworkModel network,
    String addressString,
    int feePerByte,
  );

  Future<List> getHistory(
    BitcoinNetworkModel network,
    String addressString,
  );

  Future<NetworkFeeModel> getNetworkFee(
    BitcoinNetworkModel network,
  );

  int getActiveFee(int inputCount, int outputCount, int satPerByte);

  Future<List<UtxoModel>> getUTXOs(
    BitcoinNetworkModel network,
    String addressString,
  );

  Future<TxErrorModel> send(
    BitcoinNetworkModel network,
    String txHex,
  );
}
