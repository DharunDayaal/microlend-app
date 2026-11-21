import 'package:micro_lending_app/features/reports/domain/entities/report.dart';

/// The three classic reports. Always "as of now"; the scope comes from the
/// signed-in user's token. Implementations throw `ApiException`.
abstract interface class ReportRepository {
  Future<CashOutstanding> cashOutstanding();
  Future<EarningsReport> earnings();
  Future<OverduePage> overdue({int page = 1, int limit = 20});
}
