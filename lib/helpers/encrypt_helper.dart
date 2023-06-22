import 'package:encrypt/encrypt.dart';

class EncryptHelper {
   static String getEncryptedData(plainText, password) {
     final key = Key.fromUtf8(getFormatKey(password));
     final iv = IV.fromLength(16);

     final encrypter = Encrypter(AES(key));

     final encrypted = encrypter.encrypt(plainText, iv: iv);
     return encrypted.base64;
  }

   static String getDecryptedData(encryptedText, password) {
     final key = Key.fromUtf8(getFormatKey(password));
     final iv = IV.fromLength(16);

     final encrypter = Encrypter(AES(key));
     return encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
   }

  static bool isValidKey(encryptedText, password) {
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

  static String getFormatKey(key) {
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
}