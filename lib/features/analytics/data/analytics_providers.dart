import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_gateway.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_repository_impl.dart';
import 'package:micro_lending_app/features/analytics/domain/analytics_repository.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

/// One cache for the whole app, so the Reports tab and Advanced analytics
/// share answers.
final analyticsGatewayProvider = Provider<AnalyticsGateway>((ref) {
  final g = AnalyticsGateway(ref.watch(apiClientProvider));
  ref.onDispose(g.connection.dispose);
  return g;
});

/// Override in tests: `analyticsRepositoryProvider.overrideWithValue(fake)`.
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final repo = AnalyticsRepositoryImpl(
    ref.watch(analyticsGatewayProvider),
    isAdmin: () => ref.read(sessionProvider).hasRole(UserRole.admin),
  );
  // Sign-out: the next user must not see these numbers.
  ref.listen(sessionProvider.select((s) => s.status), (_, next) {
    if (next == AuthStatus.signedOut) repo.clearCache();
  });
  return repo;
});
