enum StakingEnum {
  staking,
  yieldMachine;

  @override
  String toString() => this.name;

  bool isCompare(String value) {
    StakingEnum sourceEntry =
        StakingEnum.values.firstWhere((e) => e.toString() == value);
    return sourceEntry == this;
  }
}
