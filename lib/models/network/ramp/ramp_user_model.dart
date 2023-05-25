import 'package:defi_wallet/models/network/ramp/ramp_limit_model.dart';

class RampUserModel {
  String? phone;
  String? email;
  String? kycHash;
  String? kycStatus;
  bool? isKycCompleted;
  RampLimitModel? limit;

  RampUserModel({
    this.phone,
    this.email,
    this.kycHash,
    this.kycStatus,
    this.isKycCompleted,
    this.limit,
  });

  RampUserModel.fromJson(Map<String, dynamic> json) {
    try {
      this.phone = json['phone'];
      this.email = json['mail'];
      this.kycHash = json['kycHash'];
      this.kycStatus = json['kycStatus'];
      this.isKycCompleted = json['kycDataComplete'];
      this.limit = RampLimitModel.fromJson(json['tradingLimit']);
    } catch (error) {
      this.phone = '';
      this.email = '';
      this.kycHash = '';
      this.kycStatus = '';
      this.isKycCompleted = false;
      this.limit = RampLimitModel(value: 0, period: 'day');
    }
  }
}
