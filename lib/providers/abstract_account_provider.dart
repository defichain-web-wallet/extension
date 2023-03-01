import 'package:defichaindart/defichaindart.dart';

abstract class AbstractAccount {
  ECPair get keyPair;
  String get networkString;
  int get index;

  Future<String> getAddress();
  Future<BigInt> getBalance();
  // Future<dynamic> sendTransaction();
}
