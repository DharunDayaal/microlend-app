import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/body_unwrap.dart';
import 'package:micro_lending_app/core/network/response_parser.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/manage/data/dtos/team_dto.dart';
import 'package:micro_lending_app/features/manage/data/dtos/managed_account_dto.dart';
import 'package:micro_lending_app/features/manage/data/sources/manage_remote_data_source.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/features/manage/domain/manage_repository.dart';

class ManageRepositoryImpl implements ManageRepository {
  final ManageRemoteDataSource _remote;
  const ManageRepositoryImpl(this._remote);

  static PagedResult<ManagedAccount> _page(dynamic res, String key, int page) {
    final b = unwrapBody(res);
    final list = b[key];
    final meta = b['metadata'];
    return PagedResult(
      items: list is List
          ? [
              for (final e in list)
                if (e is Map)
                  ManagedAccountDto.fromJson(Map<String, dynamic>.from(e)),
            ]
          : <ManagedAccount>[],
      page: page,
      hasNextPage: meta is Map && meta['has_next_page'] == true,
    );
  }

  static ManagedAccount _one(dynamic res, String key) {
    final v = unwrapBody(res)[key];
    if (v is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return ManagedAccountDto.fromJson(Map<String, dynamic>.from(v));
  }

  @override
  Future<PagedResult<ManagedAccount>> admins({
    required String status,
    String search = '',
    int page = 1,
    int limit = 20,
  }) async =>
      _page(await _remote.admins(status, search, page, limit), 'admins', page);

  @override
  Future<ManagedAccount> setAdminVerified(String id, bool value) async =>
      _one(await _remote.setAdminVerified(id, value), 'admin');

  @override
  Future<ManagedAccount> setAdminActive(String id, bool value) async =>
      _one(await _remote.setAdminActive(id, value), 'admin');

  @override
  Future<PagedResult<ManagedAccount>> employees({
    required String status,
    String search = '',
    String? adminId,
    int page = 1,
    int limit = 20,
  }) async => _page(
    await _remote.employees(status, search, adminId, page, limit),
    'employees',
    page,
  );

  @override
  Future<ManagedAccount> employee(String id) async =>
      _one(await _remote.employee(id), 'employee');

  @override
  Future<ManagedAccount> setEmployeeVerified(String id, bool value) async =>
      _one(await _remote.setEmployeeVerified(id, value), 'employee');

  @override
  Future<ManagedAccount> setEmployeeActive(String id, bool value) async =>
      _one(await _remote.setEmployeeActive(id, value), 'employee');

  @override
  Future<ManagedAccount?> createEmployee(Map<String, dynamic> body) async {
    final data = unwrapBody(await _remote.createEmployee(body));
    final v = data['employee'] ?? data['user'];
    return v is Map
        ? ManagedAccountDto.fromJson(Map<String, dynamic>.from(v))
        : null;
  }

  /// The endpoint is paged (by name), but callers need the whole team for
  /// pickers and counts, so every page is read. The counts
  /// (`pending_count`, `pending_admin_approvals`) already cover the whole
  /// team, so they come from the first page.
  @override
  Future<TeamSummary> team({String? adminId}) async {
    TeamSummary? first;
    final members = <TeamMember>[];
    final teams = <AdminTeam>[];
    await fetchAllPages<Object>((page) async {
      final body = unwrapBody(await _remote.team(adminId, page, kMaxPageLimit));
      final summary = TeamSummaryDto.fromJson(body);
      first ??= summary;
      members.addAll(summary.members);
      teams.addAll(summary.teams);
      // one page of whichever list this view returns
      return ResponseParser.pagedData<Object>(
        body,
        summary.isOverview ? 'teams' : 'members',
        (j) => j,
        page: page,
      );
    });
    final f = first!;
    return TeamSummary(
      isOverview: f.isOverview,
      members: members,
      pendingCount: f.pendingCount,
      teams: teams,
      pendingAdminApprovals: f.pendingAdminApprovals,
    );
  }
}
