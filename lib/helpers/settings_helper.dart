import 'dart:convert';
import 'package:defi_wallet/config/config.dart';
import 'package:hive/hive.dart';
import 'package:defi_wallet/client/hive_names.dart';
import 'package:defi_wallet/models/settings_model.dart';

class SettingsHelper {
  static SettingsModel settings = SettingsModel();

  static String getHostApiUrl() {
    if (SettingsHelper.settings.apiName == ApiName.ocean) {
      return Hosts.ocean;
    } else if (SettingsHelper.settings.apiName == ApiName.myDefi) {
      return Hosts.myDefichain;
    } else {
      return Hosts.oceanDefichain;
    }
  }

  Future<void> saveSettings() async {
    final jsonString = json.encode(settings.toJson());
    var box = await Hive.openBox(HiveBoxes.settings);
    await box.put(HiveNames.settings, jsonString);
    await box.close();
  }

  Future<void> loadSettings() async {
    var box = await Hive.openBox(HiveBoxes.settings);
    var _settings = await box.get(HiveNames.settings);
    if (_settings != null) {
      final jsonString = json.decode(_settings);
      settings = SettingsModel.fromJson(jsonString);
      settings.network ??= SettingsModel().network;
    } else {
      settings = SettingsModel();
    }
    await box.close();
  }

  Future<void> initSetting() async {
    settings = SettingsModel();
  }
}