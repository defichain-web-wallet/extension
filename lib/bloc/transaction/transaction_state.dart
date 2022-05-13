abstract class TransactionState {
  final String? txId;

  TransactionState(this.txId);
}

class TransactionInitialState extends TransactionState {
  TransactionInitialState(String? txId) : super(txId);
}

class TransactionLoadingState extends TransactionState {
  final String? txId;

  TransactionLoadingState(this.txId) : super(txId);
}

class TransactionLoadedState extends TransactionState {
  final String? txId;

  TransactionLoadedState(this.txId) : super(txId!);
}
