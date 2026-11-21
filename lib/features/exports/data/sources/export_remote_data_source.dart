import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for exports.
class ExportRemoteDataSource {
  final ApiClient _api;
  const ExportRemoteDataSource(this._api);

  Future<dynamic> create(Map<String, dynamic> body) =>
      _api.post(ApiEndpoints.exports, data: body);

  Future<dynamic> get(String id) => _api.get(ApiEndpoints.exportById(id));

  Future<dynamic> list() => _api.get(ApiEndpoints.exports);
}
