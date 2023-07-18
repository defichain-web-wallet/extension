class AccessTokenModel {
  String accessToken;
  int expireTime;
  late int accessTokenExpireTime;

  static const int hour = 60 * 60 * 1000;

  AccessTokenModel({
    required this.accessToken,
    this.expireTime = 0,
    required expireHours,
    int existingTime = 0,
  }){
    this.expireTime = this.expireTime + (24 * hour);
    if (existingTime == 0) {
      this.accessTokenExpireTime = expireHours * hour;
    } else {
      this.accessTokenExpireTime = existingTime;
    }
  }

  bool isValid() => this.accessTokenExpireTime - hour < DateTime.now().millisecondsSinceEpoch;

  factory AccessTokenModel.fromJson(Map<String, dynamic> jsonModel) {
    return AccessTokenModel(
      accessToken: jsonModel['accessToken'],
      expireHours: jsonModel['expireHours'],
      existingTime: jsonModel['expireHours'],
      expireTime: jsonModel['expireTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["accessToken"] = this.accessToken.toString();
    data["expireHours"] = this.accessTokenExpireTime;
    data["expireTime"] = this.expireTime;
    return data;
  }
}

