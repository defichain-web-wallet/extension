class RampLimitModel {
  double? value;
  String? period;

  RampLimitModel({
    this.value,
    this.period,
  });

  RampLimitModel.fromJson(Map<String, dynamic> json) {
    try {
      this.value = json["limit"] + .0;
      this.period = json["period"];
    } catch (_) {
      this.value = 0.0;
      this.period = 'Day';
    }
  }
}
