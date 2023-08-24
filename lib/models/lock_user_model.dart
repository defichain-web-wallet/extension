class LockUserModel {
  String? address;
  String? kycStatus;
  String? kycLink;

  LockUserModel({this.address, this.kycStatus});

  LockUserModel.fromJson(Map<String, dynamic> json) {
    this.address = json["address"];
    this.kycStatus = json["kycStatus"];
    this.kycLink = json["kycLink"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["address"] = this.address;
    data["kycStatus"] = this.kycStatus;
    data["kycLink"] = this.kycLink;
    return data;
  }
}
