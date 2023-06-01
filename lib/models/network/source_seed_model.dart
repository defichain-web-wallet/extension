import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:uuid/uuid.dart';

enum SourceName { seed, ledger }

abstract class AbstractSourceModel {
  late String id;
  final SourceName sourceName;

  AbstractSourceModel({required this.sourceName});

  Map<String, dynamic> toJSON();

  getMnemonic(String password);
}

class LedgerSourceModel implements AbstractSourceModel {
  @override
  late String id;

  @override
  SourceName get sourceName => SourceName.ledger;

  LedgerSourceModel() {
    this.id = Uuid().v1();
  }

  @override
  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'sourceName': sourceName.name,
    };
  }

  @override
  getMnemonic(String password) {
    throw UnimplementedError();
  }
}

class SourceSeedModel implements AbstractSourceModel {
  @override
  late String id;

  @override
  final SourceName sourceName;

  String? mnemonic;
  final String publicKeyTestnet;
  final String publicKeyMainnet;

  SourceSeedModel(
      {String? id,
      required this.sourceName,
      required this.publicKeyMainnet,
      required this.publicKeyTestnet,
      String? password,
      List<String>? mnemonic,
      String? mnemonicFromStore}) {
    if (sourceName.name == SourceName.seed.name) {
      if (mnemonicFromStore != null) {
        this.mnemonic = mnemonicFromStore;
      } else {
        _validatePassword(password);
        _validateMnemonic(mnemonic);
        this.mnemonic =
            EncryptHelper.getEncryptedData(mnemonic!.join(','), password);
      }
    }

    this.id = id ?? Uuid().v1();
  }

  @override
  List<String> getMnemonic(String password) {
    var mnemonic = EncryptHelper.getDecryptedData(this.mnemonic, password);
    return mnemonic.split(',');
  }

  void _validatePassword(String? password) {
    if (password == null) {
      throw 'Password is required';
    }
  }

  void _validateMnemonic(List<String>? mnemonic) {
    if (mnemonic == null) {
      throw 'Mnemonic is required';
    }
  }

  @override
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
      sourceName: SourceName.values
          .firstWhere((element) => element.name == json['sourceName']),
    );
  }
}
