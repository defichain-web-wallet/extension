class SettingsModel {
  String? currency;
  String? theme;
  String? network;

  SettingsModel({this.currency = 'USD', this.theme = 'Light', this.network = 'mainnet'});

  SettingsModel.fromJson(Map<String, dynamic> json) {
    this.currency = json["currency"];
    this.theme = json["theme"];
    this.network = json["network"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["currency"] = this.currency;
    data["theme"] = this.theme;
    data["network"] = this.network;
    return data;
  }

  SettingsModel clone() {
    return SettingsModel(currency: currency, theme: theme, network: network);
  }

  bool compare(SettingsModel sm) {
    return currency == sm.currency && theme == sm.theme && network == sm.network;
  }

  bool compareNetwork(SettingsModel sm) {
    return network == sm.network;
  }
}