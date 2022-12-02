class LimitModel {
  double? value;
  String? period;

  LimitModel({
    this.value,
    this.period,
  });

  LimitModel.fromJson(Map<String, dynamic> json) {
    try {
      this.value = json["limit"] + .0;
      this.period = json["period"];
    } catch (_) {
      this.value = 0.0;
      this.period = 'Day';
    }
  }
}
