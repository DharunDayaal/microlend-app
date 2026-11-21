/// Whether analytics answers are live, and when the last one arrived.
class AnalyticsStatus {
  final bool offline;
  final DateTime? updatedAt; // the last successful fetch
  const AnalyticsStatus({this.offline = false, this.updatedAt});
}
