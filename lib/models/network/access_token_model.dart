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
}

