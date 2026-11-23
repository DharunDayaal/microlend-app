import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/body_unwrap.dart';
import 'package:micro_lending_app/core/network/response_parser.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/profile/data/dtos/profile_dto.dart';
import 'package:micro_lending_app/features/profile/data/sources/profile_remote_data_source.dart';
import 'package:micro_lending_app/features/profile/domain/entities/profile.dart';
import 'package:micro_lending_app/features/profile/domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  const ProfileRepositoryImpl(this._remote);

  static UserProfile _profile(dynamic res) {
    final p = unwrapBody(res)['profile'];
    if (p is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return UserProfileDto.fromJson(Map<String, dynamic>.from(p));
  }

  static List<T> _list<T>(
    dynamic res,
    String key,
    T Function(Map<String, dynamic>) parse,
  ) {
    final list = unwrapBody(res)[key];
    return list is List
        ? [
            for (final e in list)
              if (e is Map) parse(Map<String, dynamic>.from(e)),
          ]
        : <T>[];
  }

  @override
  Future<UserProfile> getProfile() async =>
      _profile(await _remote.getProfile());

  @override
  Future<UserProfile> updateProfile({String? userName, String? email}) async =>
      _profile(await _remote.updateProfile(userName, email));

  @override
  Future<UserProfile> changePhone(String phone) async =>
      _profile(await _remote.changePhone(phone));

  @override
  Future<UserProfile> updateDefaults({
    double? fee,
    double? interest,
    double? months,
  }) async => _profile(await _remote.updateDefaults(fee, interest, months));

  @override
  Future<void> changePassword({
    required String current,
    required String next,
    String? refreshToken,
  }) async {
    await _remote.changePassword(current, next, refreshToken);
  }

  @override
  Future<PagedResult<SessionInfo>> sessionsPage({
    int page = 1,
    int limit = kMaxPageLimit,
  }) async => ResponseParser.pagedData(
    unwrapBody(await _remote.getSessions(page, limit)),
    'sessions',
    SessionInfoDto.fromJson,
    page: page,
  );

  @override
  Future<List<SessionInfo>> getSessions() =>
      fetchAllPages((page) => sessionsPage(page: page));

  @override
  Future<void> deleteSession(String id) async {
    await _remote.deleteSession(id);
  }

  @override
  Future<void> deleteAllSessions() async {
    await _remote.deleteAllSessions();
  }

  @override
  Future<ProfileStats> getStats({
    required String range,
    required String scope,
    String? adminId,
  }) async {
    final s = unwrapBody(
      await _remote.getStats(range, scope, adminId),
    )['stats'];
    return ProfileStatsDto.fromJson(
      s is Map ? Map<String, dynamic>.from(s) : {},
    );
  }

  @override
  Future<List<AdminAccount>> getAdmins({
    String status = 'pending',
    int page = 1,
    int limit = 5,
  }) async => _list(
    await _remote.getAdmins(status, page, limit),
    'admins',
    AdminAccountDto.fromJson,
  );

  @override
  Future<void> updateLimits(Map<String, double> changes) async {
    await _remote.updateLimits(changes);
  }
}
