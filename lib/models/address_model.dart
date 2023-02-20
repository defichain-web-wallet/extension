import 'package:defi_wallet/helpers/network_helper.dart';
import 'package:defi_wallet/services/hd_wallet_service.dart';
import 'dart:typed_data';
import 'package:defi_wallet/models/network_type_model.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:defichain_bech32/defichain_bech32.dart';
import 'package:defichaindart/src/payments/index.dart' show PaymentData;
import 'package:defichaindart/src/payments/p2pkh.dart';
import 'package:defichaindart/src/payments/p2sh.dart';
import 'package:defichaindart/src/payments/p2wpkh.dart';

class Address {
  static bool validateAddress(String address, [AbstractNetworkType? nw]) {
    var net = nw ?? defichain;
    if (net.dialect != NetworkDialect.BTC) {
      throw Exception("Only type BTC networks are supported");
    }
    final network = net as BtcNetworkType;
    try {
      addressToOutputScript(address, network);
      return true;
    } catch (err) {
      return false;
    }
  }

  static Uint8List? addressToOutputScript(String address, BtcNetworkType network) {
    var decodeBase58;
    var decodeBech32;
    try {
      decodeBase58 = bs58check.decode(address);
    } catch (err) {
      // Base58check decode fail
    }
    if (decodeBase58 != null) {
      if (decodeBase58[0] == network.pubKeyHash) {
        return P2PKH(data: PaymentData(address: address), network: network).data!.output;
      }
      if (decodeBase58[0] == network.scriptHash) {
        return P2SH(data: PaymentData(address: address), network: network).data!.output;
      }
      throw ArgumentError('Invalid version or Network mismatch');
    } else {
      try {
        decodeBech32 = segwit.decode(SegwitInput(network.bech32!, address));
      } catch (err) {
        // Bech32 decode fail
      }
      if (decodeBech32 != null) {
        if (network.bech32 != decodeBech32.hrp) {
          throw ArgumentError('Invalid prefix or Network mismatch');
        }
        if (decodeBech32.version != 0) {
          throw ArgumentError('Invalid address version');
        }
        var p2wpkh = P2WPKH(data: PaymentData(address: address), network: network);
        return p2wpkh.data!.output;
      }
    }
    throw ArgumentError(address + ' has no matching Script');
  }
}

class AddressModel {
  var hdWalletService = HDWalletService();
  String? address;
  int? account;
  bool? isChange;
  int? index;
  String? blockchain;

  AddressModel(
      {this.address,
      this.account,
      this.isChange,
      this.index,
      this.blockchain});

  AddressModel.fromJson(Map<String, dynamic> json)  {
    this.address = json["address"];
    this.account = json["account"];
    this.isChange = json["isChange"];
    this.blockchain = json["blockchain"] == null ? 'DFI' : json["blockchain"];
    this.index = json["index"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = this.address;
    data["account"] = this.account;
    data["isChange"] = this.isChange;
    data["index"] = this.index;
    data["blockchain"] = this.blockchain;
    return data;
  }
}
