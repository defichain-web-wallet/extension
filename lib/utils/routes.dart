enum Routes {
  home,
  send,
  receive,
  swap,
  buySell,
  buy,
  sell,
  earn,
}

extension ParseToString on Routes {
  String toShortString() {
    return this.toString().split('.').last;
  }
}