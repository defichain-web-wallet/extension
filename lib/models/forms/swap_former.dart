import 'dart:convert';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SwapFormer {
  String? assetFrom;
  String? assetTo;
  String? amountFrom;
  String? amountTo;

  SwapFormer({
    this.assetFrom,
    this.assetTo,
    this.amountFrom,
    this.amountTo,
  });

  SwapFormer.init() {
    this.assetFrom = '';
    this.assetTo = '';
    this.amountFrom = '0';
    this.amountTo = '0';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["assetFrom"] = this.assetFrom;
    data["assetTo"] = this.assetTo;
    data["amountFrom"] = this.amountFrom;
    data["amountTo"] = this.amountTo;
    return data;
  }

  SwapFormer.fromJson(Map<String, dynamic> jsonModel) {
    this.assetFrom = jsonModel["assetFrom"];
    this.assetTo = jsonModel["assetTo"];
    this.amountFrom = jsonModel["amountFrom"];
    this.amountTo = jsonModel["amountTo"];
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
