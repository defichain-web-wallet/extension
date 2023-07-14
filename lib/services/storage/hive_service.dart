import 'package:defi_wallet/client/hive_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<dynamic> getData(String key) async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);
      var data = await box.get(key);
      await box.close();
      return data;
    } catch (error) {
      throw error;
    }
  }

  // TODO: make 'data' to array
  static Future<void> update(
    String key,
    dynamic data,
  ) async {
    try {
      var box = await Hive.openBox(HiveBoxes.client);
      await box.put(key, data);
      await box.close();
    } catch (error) {
      throw error;
    }
  }

  static Future<void> clearBox(String boxName) async {
    try {
      var box = await Hive.openBox(boxName);
      await box.clear();
      await box.close();
    } catch (error) {
      throw error;
    }
  }
}
