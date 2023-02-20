import 'package:defi_wallet/models/abstract_transaction_receipt.dart';

class EvmTransactionReceipt extends AbstractTransactionReceipt {
  String hash;
  int blockHeight;

  EvmTransactionReceipt({
    required this.hash,
    required this.blockHeight
  });
}