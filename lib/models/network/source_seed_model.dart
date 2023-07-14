import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:uuid/uuid.dart';

enum SourceName {
  seed, ledger
}

class SourceSeedModel {
  late String id;
  String? mnemonic;
  final String publicKeyTestnet;
  final String publicKeyMainnet;
  final SourceName sourceName;

  SourceSeedModel({String? id, required this.sourceName, required this.publicKeyMainnet, required this.publicKeyTestnet, String? password, List<String>? mnemonic, String? mnemonicFromStore}){
    if(sourceName.name == SourceName.seed.name){
      if(mnemonicFromStore != null){
        this.mnemonic = mnemonicFromStore;
      } else {
        _validatePassword(password);
        _validateMnemonic(mnemonic);
        this.mnemonic = EncryptHelper.getEncryptedData(mnemonic!.join(','), password);
      }
    }

    this.id = id ?? Uuid().v1();
  }

  List<String> getMnemonic(String password){
    var mnemonic = EncryptHelper.getDecryptedData(this.mnemonic, password);
    return mnemonic.split(',');
  }


  void _validatePassword(String? password){
    if(password == null){
      throw 'Password is required';
    }
  }
  void _validateMnemonic(List<String>? mnemonic){
    if(mnemonic == null){
      throw 'Mnemonic is required';
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'mnemonic': mnemonic,
      'publicKeyTestnet': publicKeyTestnet,
      'publicKeyMainnet': publicKeyMainnet,
      'sourceName': sourceName.name,
    };
  }

  factory SourceSeedModel.fromJSON(Map<String, dynamic> json) {
    return SourceSeedModel(
      id: json['id'],
      mnemonicFromStore: json['mnemonic'],
      publicKeyTestnet: json['publicKeyTestnet'],
      publicKeyMainnet: json['publicKeyMainnet'],
      sourceName: SourceName.values.firstWhere((element) => element.name == json['sourceName']),
    );
  }

}
