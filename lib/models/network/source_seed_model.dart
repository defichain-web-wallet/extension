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

  SourceSeedModel({required this.sourceName, required this.publicKeyMainnet, required this.publicKeyTestnet, String? password, List<String>? mnemonic}){
    if(sourceName.name == SourceName.seed.name){
      _validatePassword(password);
      _validateMnemonic(mnemonic);
      this.mnemonic = EncryptHelper.getEncryptedData(mnemonic!.join(','), password);

    }
    this.id = Uuid().v1();
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

}
