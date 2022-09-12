import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class KycNameFormer {
  String? firstName;
  String? lastName;

  KycNameFormer({
    this.firstName = '',
    this.lastName = '',
  });

  KycNameFormer.init() {
    this.firstName = '';
    this.lastName = '';
  }

  KycNameFormer.fromJson(Map<String, dynamic> jsonModel) {
    this.firstName = jsonModel["firstName"];
    this.lastName = jsonModel["lastName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["firstName"] = this.firstName;
    data["lastName"] = this.lastName;
    return data;
  }

  void save() async {
    var box = await Hive.openBox(HiveBoxes.client);
    String data = jsonEncode(this.toJson());
    await box.put(HiveNames.sendState, data);
    await box.close();
  }

  void reset() async {
    var box = await Hive.openBox(HiveBoxes.client);
    await box.put(HiveNames.sendState, null);
    await box.close();
  }

  static Future<Map<String, dynamic>> loadExist() async {
    var box = await Hive.openBox(HiveBoxes.client);
    String? data = await box.get(HiveNames.sendState);
    await box.close();
    if (data != null) {
      return jsonDecode(data);
    } else {
      throw Error.safeToString('Saved send data is empty');
    }
  }
}
