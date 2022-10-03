import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class EncryptHelper {
   String getEncryptedData(plainText, password) {
     final key = Key.fromUtf8(getFormatKey(password));
     final iv = IV.fromLength(16);

     final encrypter = Encrypter(AES(key));

     final encrypted = encrypter.encrypt(plainText, iv: iv);
     return encrypted.base64;
  }

   String getDecryptedData(encryptedText, password) {
     final key = Key.fromUtf8(getFormatKey(password));
     final iv = IV.fromLength(16);

     final encrypter = Encrypter(AES(key));
     return encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
   }

  bool isValidKey(encryptedText, password) {
    final key = Key.fromUtf8(getFormatKey(password));
    final iv = IV.fromLength(16);

    try {
      final encrypter = Encrypter(AES(key));
      encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
      return true;
    } catch (err) {
      return false;
    }
  }

  String getFormatKey(key) {
     if (key.length < 32) {
       String result = '';
       for (int i in Iterable.generate(32)) {
         if (key.length > i) {
           result += key[i];
         } else {
           result += '.';
         }
       }
       return result;
     } else if (key.length > 32) {
       return key.substring(0, 32);
     } else {
       return key;
     }
  }

  String getEncryptedSha256(String target) {
    var appleInBytes = utf8.encode(target);
    Digest value = sha256.convert(appleInBytes);
    return value.toString();
  }
}