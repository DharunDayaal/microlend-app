import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/manage/data/dtos/managed_account_dto.dart';
import 'package:micro_lending_app/features/manage/data/dtos/team_dto.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/manage/domain/manage_repository.dart';

ManagedAccount account(
  String id, {
  bool verified = false,
  bool active = true,
}) => ManagedAccountDto.fromJson({
  'id': id,
  'user_name': 'User $id',
  'phone_number': '+9198765$id',
  'is_verified': verified,
  'is_active': active,
});

class FakeManageRepository implements ManageRepository {
  /// Pages keyed by "kind|status|search|adminId".
  final Map<String, List<ManagedAccount>> lists = {};
  final List<String> calls = [];

  List<ManagedAccount> _get(String key) {
    calls.add(key);
    return lists[key] ?? const [];
  }

  @override
  Future<PagedResult<ManagedAccount>> admins({
    required String status,
    String search = '',
    int page = 1,
    int limit = 20,
  }) async => PagedResult(
    items: _get('admins|$status|$search|null'),
    page: page,
    hasNextPage: false,
  );

  @override
  Future<PagedResult<ManagedAccount>> employees({
    required String status,
    String search = '',
    String? adminId,
    int page = 1,
    int limit = 20,
  }) async => PagedResult(
    items: _get('employees|$status|$search|$adminId'),
    page: page,
    hasNextPage: false,
  );

  /// Teams in the SUPER_ADMIN overview.
  List<Map<String, dynamic>> teams = [];

  @override
  Future<TeamSummary> team({String? adminId}) async => TeamSummaryDto.fromJson({
    'members': [],
    'pending_count': 2,
    'pending_admin_approvals': 1,
    if (adminId == null) 'teams': teams,
  });

  /// Admin decisions made, as "verified|id|value" / "active|id|value".
  final List<String> decisions = [];

  @override
  Future<ManagedAccount> setAdminVerified(String id, bool value) async {
    decisions.add('verified|$id|$value');
    return account(id, verified: value);
  }

  @override
  Future<ManagedAccount> setAdminActive(String id, bool value) async {
    decisions.add('active|$id|$value');
    return account(id, active: value);
  }

  @override
  Future<ManagedAccount> employee(String id) => throw UnimplementedError();
  @override
  Future<ManagedAccount> setEmployeeVerified(String id, bool value) =>
      throw UnimplementedError();
  @override
  Future<ManagedAccount> setEmployeeActive(String id, bool value) =>
      throw UnimplementedError();
  @override
  Future<ManagedAccount?> createEmployee(Map<String, dynamic> body) =>
      throw UnimplementedError();
}
