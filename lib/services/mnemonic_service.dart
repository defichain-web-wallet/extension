import 'dart:typed_data';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/helpers/encrypt_helper.dart';
import 'package:defichaindart/defichaindart.dart';
import 'package:defi_wallet/helpers/mnemonic_words.dart';
import 'package:hive_flutter/hive_flutter.dart';


Uint8List convertMnemonicToSeed(List<String> mnemonic) {
  return mnemonicToSeed(mnemonic.join(' '));
}

Future<List<String>> getMnemonic(String password) async{
  var box = await Hive.openBox(HiveBoxes.client);
  var mnemonic = await box.get(HiveNames.savedMnemonic);
  return EncryptHelper.getDecryptedData(mnemonic, password).split(',');
}

bool isCorrectWord(String word) {
  return wordsList.contains(word);
}