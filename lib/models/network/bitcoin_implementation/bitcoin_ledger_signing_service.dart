import 'package:defi_wallet/requests/transaction_requests.dart';
import 'package:defi_wallet/services/ledger_signing_service.dart';

class BitcoinLedgerSigningService extends LedgerSigningService {
  BitcoinLedgerSigningService() : super(TransactionRequests());
}
