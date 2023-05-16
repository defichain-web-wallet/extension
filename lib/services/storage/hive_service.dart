import 'package:defi_wallet/client/hive_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<dynamic> getData(String key) async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);
      var data = await box.get(key);
      return data;
    } catch (error) {
      throw error;
    }
  }

  static Future<void> update(
    String key,
    String data,
  ) async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);

      await box.put(key, data);
    } catch (error) {
      throw error;
    }
  }
}
