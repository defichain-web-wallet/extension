import 'dart:typed_data';
import 'abstract_tx_model.dart';

class EvmTxModel implements AbstractTransaction {
  int blockHeight;
  int index;
  String hash;
  String from;
  String to;
  BigInt? amount;
  Uint8List? data;

  EvmTxModel({
    required this.blockHeight,
    required this.index,
    required this.hash,
    required this.from,
    required this.to,
    this.amount,
    this.data
  });
}