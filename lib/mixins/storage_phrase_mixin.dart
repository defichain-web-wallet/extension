import 'package:defi_wallet/client/hive_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin StoragePhraseMixin {
  Future<void> savePhraseToStorage(String phrase) async =>
      await _updateSavedData(phrase);

  Future<void> clearPhraseInStorage() async => await _updateSavedData(null);

  Future<void> _updateSavedData(String? data) async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.openedMnemonic, data);
    await box.close();
  }
}
