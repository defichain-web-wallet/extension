enum ApiName { auto, ocean, myDefi }

class SettingsModel {
  String? currency;
  String? theme;
  String? network;
  ApiName? apiName;

  SettingsModel({
    this.currency = 'USD',
    this.theme = 'Light',
    this.network = 'mainnet',
    this.apiName = ApiName.auto,
  });

  SettingsModel.fromJson(Map<String, dynamic> json) {
    this.currency = json["currency"];
    this.theme = json["theme"];
    this.network = json["network"];
    try {
      this.apiName =
          ApiName.values.firstWhere((e) => e.toString() == json["apiName"]);
    } catch(err) {
      this.apiName = ApiName.auto;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["currency"] = this.currency;
    data["theme"] = this.theme;
    data["network"] = this.network;
    data["apiName"] = this.apiName.toString();
    return data;
  }

  SettingsModel clone() {
    return SettingsModel(
      currency: currency,
      theme: theme,
      network: network,
      apiName: apiName,
    );
  }

  bool compare(SettingsModel sm) =>
      currency == sm.currency &&
      theme == sm.theme &&
      network == sm.network &&
      apiName == sm.apiName;

  bool compareNetwork(SettingsModel sm) => network == sm.network;
  bool isCompareApiName(SettingsModel sm) => apiName == sm.apiName;
}
