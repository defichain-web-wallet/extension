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
      expireHours: int.parse(jsonModel['expireHours']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': this.accessToken.toString(),
      'expireHours': this.accessTokenExpireTime.toString(),
    };
  }
}

