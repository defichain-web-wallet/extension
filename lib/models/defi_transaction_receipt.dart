import 'package:defi_wallet/models/abstract_transaction_receipt.dart';

class DefiTransactionReceipt extends AbstractTransactionReceipt {
  String hash;
  int blockHeight;

  DefiTransactionReceipt({
    required this.hash,
    required this.blockHeight
  });
}