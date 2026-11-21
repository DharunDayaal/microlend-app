import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/body_unwrap.dart';
import 'package:micro_lending_app/features/exports/data/dtos/export_dto.dart';
import 'package:micro_lending_app/features/exports/data/sources/export_remote_data_source.dart';
import 'package:micro_lending_app/features/exports/domain/entities/export.dart';
import 'package:micro_lending_app/features/exports/domain/export_repository.dart';

class ExportRepositoryImpl implements ExportRepository {
  final ExportRemoteDataSource _remote;
  const ExportRepositoryImpl(this._remote);

  static ExportJob _job(dynamic res) {
    final v = unwrapBody(res)['export'];
    if (v is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return ExportJobDto.fromJson(Map<String, dynamic>.from(v));
  }

  @override
  Future<ExportCreated> create({
    required ExportType type,
    required ExportFormat format,
    required Map<String, dynamic> filters,
  }) async {
    final res = await _remote.create({
      'type': type.spec.api,
      'format': format.name,
      'filters': filters,
    });
    return ExportCreated(_job(res), unwrapBody(res)['already_running'] == true);
  }

  @override
  Future<ExportJob> get(String id) async => _job(await _remote.get(id));

  @override
  Future<List<ExportJob>> list() async {
    final v = unwrapBody(await _remote.list())['exports'];
    return v is List
        ? [
            for (final e in v)
              if (e is Map) ExportJobDto.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <ExportJob>[];
  }
}
