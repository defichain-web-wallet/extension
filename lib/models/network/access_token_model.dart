class AccessTokenModel {
  String accessToken;
  late int accessTokenExpireTime;

  static const int hour = 60 * 60 * 1000;

  AccessTokenModel({
    required this.accessToken,
    required expireHours,
  }){
    this.accessTokenExpireTime = expireHours * hour;
  }

  bool isValid() => this.accessTokenExpireTime - hour < DateTime.now().millisecondsSinceEpoch;

  factory AccessTokenModel.fromJson(Map<String, dynamic> jsonModel) {
    return AccessTokenModel(
      accessToken: jsonModel['accessToken'],
      expireHours: jsonModel['expireHours'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["accessToken"] = this.accessToken.toString();
    data["expireHours"] = this.accessTokenExpireTime;
    return data;
  }
}

