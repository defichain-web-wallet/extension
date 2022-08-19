import 'dart:convert';

import 'package:defi_wallet/client/hive_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SendFormer {
  String? address;
  String? amount;

  SendFormer({
    this.address,
    this.amount,
  });

  SendFormer.fromJson(Map<String, dynamic> jsonModel) {
    this.address = jsonModel["address"];
    this.amount = jsonModel["amount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = this.address;
    data["amount"] = this.amount;
    return data;
  }

  void save() async {
    var box = await Hive.openBox(HiveBoxes.state);
    String data = jsonEncode(this.toJson());
    await box.put(HiveNames.sendState, data);
    await box.close();
  }

  void reset() async {
    var box = await Hive.openBox(HiveBoxes.state);
    await box.put(HiveNames.sendState, null);
    await box.close();
  }

  static Future<Map<String, dynamic>> loadExist() async {
    var box = await Hive.openBox(HiveBoxes.state);
    String? data = await box.get(HiveNames.sendState);
    await box.close();
    if (data != null) {
      return jsonDecode(data);
    } else {
      throw Error.safeToString('Saved send data is empty');
    }
  }
}
