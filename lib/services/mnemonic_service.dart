import 'dart:typed_data';
import 'package:defichaindart/defichaindart.dart';
import 'package:defi_wallet/helpers/mnemonic_words.dart';


Uint8List convertMnemonicToSeed(List<String> mnemonic) {
  return mnemonicToSeed(mnemonic.join(' '));
}

bool isCorrectWord(String word) {
  return wordsList.contains(word);
}