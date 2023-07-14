import 'package:defi_wallet/models/history_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_bridge_model.dart';
import 'package:defi_wallet/models/network/bitcoin_implementation/bitcoin_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network_fee_model.dart';
import 'package:defi_wallet/models/tx_error_model.dart';
import 'package:defi_wallet/models/utxo_model.dart';
import 'package:defi_wallet/requests/bitcoin/blockcypher_requests.dart';

//TODO: rewrite this
class BridgeModel extends AbstractBridge {
  BridgeModel(
    NetworkTypeModel networkType, {
    int activeFee = 0,
    int totalBalance = 0,
    int unconfirmedBalance = 0,
    int availableBalance = 0,
    NetworkFeeModel? networkFeeModel,
    List<HistoryModel> history = const [],
  }) : super(
          _validationNetworkName(networkType),
          activeFee,
          totalBalance,
          unconfirmedBalance,
          availableBalance,
          networkFeeModel,
          history,
        );

  static NetworkTypeModel _validationNetworkName(
      NetworkTypeModel networkType,
  ) {
    if (networkType.networkName != NetworkName.defichainMainnet &&
        networkType.networkName != NetworkName.defichainTestnet) {
      throw 'Invalid network';
    }
    return networkType;
  }

  @override
  Future<int> getBalance(
    BitcoinNetworkModel network,
    String addressString,
  ) async {
    try {
      final balance = await BlockcypherRequests.getBalance(
        network: network,
        addressString: addressString,
      );
      return balance.balance;
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<HistoryModel>> getHistory(
    BitcoinNetworkModel network,
    String addressString,
  ) async {
    try {
      List<dynamic> data = await BlockcypherRequests.getTransactionHistory(
        network: network,
        addressString: addressString,
      );
      return data[0];
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<NetworkFeeModel> getNetworkFee(BitcoinNetworkModel network) async {
    try {
      return await BlockcypherRequests.getNetworkFee(network);
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<List<UtxoModel>> getUTXOs(
    BitcoinNetworkModel network,
    String addressString,
  ) async {
    try {
      return await BlockcypherRequests.getUTXOs(
        network: network,
        addressString: addressString,
      );
    } catch (error) {
      throw error;
    }
  }

  @override
  Future<void> getAvailableBalance(
    BitcoinNetworkModel network,
    String addressString,
    int feePerByte,
  ) async {
    try {
      int balance = await this.getBalance(network, addressString);
      List<UtxoModel> utxos = await getUTXOs(network, addressString);
      int fee = this.getActiveFee(utxos.length, 1, feePerByte);
      this.availableBalance = balance - fee;
    } catch (error) {
      throw error;
    }
  }

  @override
  int getActiveFee(int inputCount, int outputCount, int satPerByte) {
    final int txBodySize = 10;
    final int txInputSize = 148;
    final int txOutputSize = 34;

    return (txBodySize +
            inputCount * txInputSize +
            txOutputSize * outputCount) *
        satPerByte;
  }

  @override
  Future<TxErrorModel> send(BitcoinNetworkModel network, String txHex) async {
    try {
      return await BlockcypherRequests.sendTxHex(network, txHex);
    } catch (error) {
      throw error;
    }
  }
}
