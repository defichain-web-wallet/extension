class AccessTokenModel {
  String accessToken;
  late int accessTokenExpireTime;

  static const int hour = 60 * 60 * 1000;

  AccessTokenModel({
    required this.accessToken,
    required expireHours,
    int existingTime = 0,
  }){
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
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["accessToken"] = this.accessToken.toString();
    data["expireHours"] = this.accessTokenExpireTime;
    return data;
  }
}

