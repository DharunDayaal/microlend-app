import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';

/// Managing admin and employee accounts. Implementations throw
/// `ApiException` on failure.
abstract interface class ManageRepository {
  // ---------- admins (SUPER_ADMIN) ----------

  Future<PagedResult<ManagedAccount>> admins({
    required String status,
    String search = '',
    int page = 1,
    int limit = 20,
  });

  Future<ManagedAccount> setAdminVerified(String id, bool value);
  Future<ManagedAccount> setAdminActive(String id, bool value);

  // ---------- employees ----------

  /// [adminId] narrows a SUPER_ADMIN's list to one team; an ADMIN's is
  /// always their own team.
  Future<PagedResult<ManagedAccount>> employees({
    required String status,
    String search = '',
    String? adminId,
    int page = 1,
    int limit = 20,
  });

  Future<ManagedAccount> employee(String id);
  Future<ManagedAccount> setEmployeeVerified(String id, bool value);
  Future<ManagedAccount> setEmployeeActive(String id, bool value);

  /// Creates an employee as the signed-in admin. Null when the server does
  /// not echo the new account back.
  Future<ManagedAccount?> createEmployee(Map<String, dynamic> body);

  /// An ADMIN gets their members. A SUPER_ADMIN gets the overview, or one
  /// team with [adminId].
  Future<TeamSummary> team({String? adminId});
}
