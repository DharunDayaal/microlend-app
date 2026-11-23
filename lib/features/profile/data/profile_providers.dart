import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/profile/data/profile_repository_impl.dart';
import 'package:micro_lending_app/features/profile/data/sources/profile_remote_data_source.dart';
import 'package:micro_lending_app/features/profile/domain/profile_repository.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `profileRepositoryProvider.overrideWithValue(fake)`.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider)),
);

/// Called on app start: keeps the stored role and loan defaults current.
/// Offline or signed out, the stored profile stays.
Future<void> refreshSessionProfile(ProviderContainer container) async {
  try {
    final p = await container.read(profileRepositoryProvider).getProfile();
    await container.read(sessionProvider.notifier).setUser(p.toAdminUser());
  } catch (_) {
    // offline or signed out: the stored profile, and its role, stay
    container.read(sessionProvider.notifier).confirmSavedRole();
  }
}
