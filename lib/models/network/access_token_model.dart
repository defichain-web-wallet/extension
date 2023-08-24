class AccessTokenModel {
  String accessToken;
  int expireTime;
  bool isNewExpireTime;
  late int accessTokenExpireTime;

  static const int hourInMilliseconds = 60 * 60 * 1000;
  static const int dayInHours = 24;

  AccessTokenModel({
    required this.accessToken,
    required this.expireTime,
    required expireHours,
    this.isNewExpireTime = true,
    int existingTime = 0,
  }) {
    if (isNewExpireTime) {
      this.expireTime = this.expireTime + (dayInHours * hourInMilliseconds);
    }
    if (existingTime == 0) {
      this.accessTokenExpireTime = expireHours * hourInMilliseconds;
    } else {
      this.accessTokenExpireTime = existingTime;
    }
  }

  bool isValid() =>
      this.accessTokenExpireTime - hourInMilliseconds <
      DateTime.now().millisecondsSinceEpoch;

  bool isExpire() {
    DateTime expireDateTime = DateTime.fromMillisecondsSinceEpoch(
      this.expireTime - hourInMilliseconds,
    );

    DateTime currentDateTime = DateTime.now();
    int expireTime = expireDateTime.millisecondsSinceEpoch;
    int currentTime = currentDateTime.millisecondsSinceEpoch;

    int hoursDifference = getHoursDifference(expireDateTime, currentDateTime);

    return expireTime < currentTime || hoursDifference >= dayInHours - 1;
  }

  int getHoursDifference(DateTime startDate, DateTime endDate) {
    Duration timeDifference = endDate.difference(startDate);
    return timeDifference.inHours.abs();
  }

  factory AccessTokenModel.fromJson(Map<String, dynamic> jsonModel) {
    return AccessTokenModel(
      accessToken: jsonModel['accessToken'],
      expireHours: jsonModel['expireHours'],
      existingTime: jsonModel['expireHours'],
      expireTime: jsonModel['expireTime'] ?? 0,
      isNewExpireTime: false,
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
