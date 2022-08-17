class KycModel {
  String? accountType;
  String? firstname;
  String? surname;
  String? street;
  String? location;
  String? houseNumber;
  String? zip;
  Map? country;


  KycModel({
    this.accountType = 'Personal',
    this.firstname,
    this.surname,
    this.street,
    this.location,
    this.houseNumber = '1',
    this.zip,
    this.country,
  });

  KycModel.fromJson(Map<String, dynamic> json) {
    this.accountType = 'Personal';
    this.firstname = json["firstname"];
    this.surname = json["surname"];
    this.street = json["street"];
    this.location = json["location"];
    this.houseNumber = '1';
    this.zip = json["zip"];
    this.country = json["country"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["accountType"] = this.accountType;
    data["firstname"] = this.firstname;
    data["surname"] = this.surname;
    data["street"] = this.street;
    data["location"] = this.location;
    data["houseNumber"] = this.houseNumber;
    data["zip"] = this.zip;
    data["country"] = this.country;
    return data;
  }
}
