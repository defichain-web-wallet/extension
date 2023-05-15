import 'package:defi_wallet/models/address_book_model.dart';
import 'package:defi_wallet/models/balance/balance_model.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_network_model.dart';
import 'package:defi_wallet/models/network/network_name.dart';
import 'package:defi_wallet/models/network/abstract_classes/abstract_account_model.dart';
import 'package:defi_wallet/models/network/source_seed_model.dart';

class ApplicationModel {
  final Map<String, SourceSeedModel> sourceList;
  final String password;

  ApplicationModel(this.sourceList, this.password);

  SourceSeedModel createSource(List<String> mnemonic, String publicKeyTestnet, String publicKeyMainnet) {
    var source = new SourceSeedModel(
        sourceName: SourceName.seed,
        publicKeyMainnet: publicKeyMainnet,
        publicKeyTestnet: publicKeyTestnet,
        password: this.password,
        mnemonic: mnemonic);
    sourceList[source.id] = source;
    return source;
  }
}
