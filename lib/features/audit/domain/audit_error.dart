import 'package:micro_lending_app/core/network/api_exception.dart';

/// How the audit screens react to a failed request.
enum AuditErrorKind { forbidden, badRequest, notFound, network, other }

/// Uses the status code when the exception carries one, else its code and message.
AuditErrorKind classifyAudit(ApiException e) {
  if (e.isNetworkError) return AuditErrorKind.network;

  int? status;
  try {
    status = (e as dynamic).statusCode as int?;
  } catch (_) {
    // this ApiException has no statusCode
  }
  final code = '${e.code}'.toUpperCase();
  final msg = e.message.toLowerCase();

  if (status == 403 ||
      code.contains('FORBIDDEN') ||
      msg.contains('not allowed')) {
    return AuditErrorKind.forbidden;
  }
  if (status == 404 ||
      code.contains('NOT_FOUND') ||
      msg.contains('not found')) {
    return AuditErrorKind.notFound;
  }
  if (status == 400 ||
      code.contains('BAD_REQUEST') ||
      code.contains('VALIDATION')) {
    return AuditErrorKind.badRequest;
  }
  return AuditErrorKind.other;
}
