import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/body_unwrap.dart';
import 'package:micro_lending_app/features/audit/data/dtos/audit_dto.dart';
import 'package:micro_lending_app/features/audit/data/sources/audit_remote_data_source.dart';
import 'package:micro_lending_app/features/audit/domain/audit_repository.dart';
import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource _remote;
  const AuditRepositoryImpl(this._remote);

  @override
  Future<AuditPage> list(Map<String, dynamic> query) async {
    final b = unwrapBody(await _remote.list(query));
    final list = b['logs'];
    final meta = b['metadata'];
    final m = meta is Map ? meta : const {};
    return AuditPage(
      list is List
          ? [
              for (final e in list)
                if (e is Map)
                  AuditLogDto.fromJson(Map<String, dynamic>.from(e)),
            ]
          : <AuditLog>[],
      m['has_next_page'] == true,
      (num.tryParse('${m['total']}') ?? 0).round(),
    );
  }

  @override
  Future<AuditLog> get(String id) async {
    final v = unwrapBody(await _remote.get(id))['log'];
    if (v is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return AuditLogDto.fromJson(Map<String, dynamic>.from(v));
  }

  @override
  Future<List<AuditActionOption>> actions({
    String? module,
    String? adminId,
  }) async {
    final list = unwrapBody(await _remote.actions(module, adminId))['actions'];
    return list is List
        ? [
            for (final e in list)
              if (e is Map)
                AuditActionOptionDto.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <AuditActionOption>[];
  }
}
