import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/network/body_unwrap.dart';

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

class AuditService {
  AuditService._();
  static final ApiClient _api = ApiClient.instance;

  static Future<AuditPage> list(Map<String, dynamic> query) async {
    final b = unwrapBody(await _api.get(ApiEndpoints.auditLogs, query: query));
    final list = b['logs'];
    final meta = b['metadata'];
    final m = meta is Map ? meta : const {};

    return AuditPage(
      list is List
          ? [
              for (final e in list)
                if (e is Map) AuditLog.fromJson(Map<String, dynamic>.from(e)),
            ]
          : <AuditLog>[],
      m['has_next_page'] == true,
      (num.tryParse('${m['total']}') ?? 0).round(),
    );
  }

  static Future<AuditLog> get(String id) async {
    final v = unwrapBody(await _api.get(ApiEndpoints.auditLog(id)))['log'];
    if (v is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return AuditLog.fromJson(Map<String, dynamic>.from(v));
  }

  static Future<List<AuditActionOption>> actions({
    String? module,
    String? adminId,
  }) async {
    final list = unwrapBody(
      await _api.get(
        ApiEndpoints.auditActions,
        query: {
          'module': ?module,
          'admin_id': ?adminId,
        },
      ),
    )['actions'];
    return list is List
        ? [
            for (final e in list)
              if (e is Map)
                AuditActionOption.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <AuditActionOption>[];
  }
}
