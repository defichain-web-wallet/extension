import 'package:defi_wallet/models/tx_error_model.dart';

abstract class TransactionState {
  final TxErrorModel? txErrorModel;

  TransactionState(this.txErrorModel);
}

class TransactionInitialState extends TransactionState {
  TransactionInitialState(TxErrorModel? txErrorModel) : super(txErrorModel);
}

class TransactionLoadingState extends TransactionState {
  final TxErrorModel? txErrorModel;

  TransactionLoadingState(this.txErrorModel) : super(txErrorModel);
}

class TransactionLoadedState extends TransactionState {
  final TxErrorModel? txErrorModel;

  TransactionLoadedState(this.txErrorModel) : super(txErrorModel!);
}

class TransactionErrorState extends TransactionState {
  final TxErrorModel? txErrorModel;

  TransactionErrorState(this.txErrorModel) : super(txErrorModel!);
}
