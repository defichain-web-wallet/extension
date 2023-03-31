class EasterEggModel {
  bool? isCollectFirstEgg;
  bool? isCollectSecondEgg;
  bool? isCollectThirdEgg;
  bool? isCollectFourthEgg;
  bool? isCollectFifthEgg;

  EasterEggModel({
    this.isCollectFirstEgg = false,
    this.isCollectSecondEgg = false,
    this.isCollectThirdEgg = false,
    this.isCollectFourthEgg = false,
    this.isCollectFifthEgg = false,
});

  EasterEggModel.fromJson(Map<String, dynamic> json){
    final Map<String, dynamic> data = new Map<String, dynamic>();
    this.isCollectFirstEgg = data["isCollectFirstEgg"];
    this.isCollectSecondEgg = data["isCollectSecondEgg"];
    this.isCollectThirdEgg = data["isCollectThirdEgg"];
    this.isCollectFourthEgg = data["isCollectFourthEgg"];
    this.isCollectFifthEgg = data["isCollectFifthEgg"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["isCollectFirstEgg"] = this.isCollectFirstEgg;
    data["isCollectSecondEgg"] = this.isCollectSecondEgg;
    data["isCollectThirdEgg"] = this.isCollectThirdEgg;
    data["isCollectFourthEgg"] = this.isCollectFourthEgg;
    data["isCollectFifthEgg"] = this.isCollectFifthEgg;
    return data;
  }
}