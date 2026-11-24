import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';

/// Where unsynced payments are kept on the device, oldest first. It must
/// survive the app being closed: this is money already collected.
abstract interface class PaymentOutboxStore {
  Future<List<PendingPayment>> read();
  Future<void> write(List<PendingPayment> payments);
}
