import 'package:defi_wallet/models/tx_error_model.dart';

abstract class TransactionState {
  final TxErrorModel? txErrorModel;
  final int? txIndex;

  TransactionState(this.txErrorModel, {this.txIndex = 0});
}

class TransactionInitialState extends TransactionState {
  TransactionInitialState(TxErrorModel? txErrorModel)
      : super(txErrorModel, txIndex: 0);
}

class TransactionLoadingState extends TransactionState {
  final TxErrorModel? txErrorModel;
  final int txIndex;

  TransactionLoadingState(this.txErrorModel, {this.txIndex = 0})
      : super(txErrorModel, txIndex: txIndex);
}

class TransactionLoadedState extends TransactionState {
  final TxErrorModel? txErrorModel;
  final int txIndex;

  TransactionLoadedState(this.txErrorModel, {this.txIndex = 0})
      : super(txErrorModel, txIndex: txIndex);
}

class TransactionErrorState extends TransactionState {
  final TxErrorModel? txErrorModel;
  final int txIndex;

  TransactionErrorState(this.txErrorModel, {this.txIndex = 0})
      : super(txErrorModel, txIndex: txIndex);
}
