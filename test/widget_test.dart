import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/main.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

import 'shared/session/session_fakes.dart';

void main() {
  testWidgets('app starts on login when signed out, and the router follows '
      'session changes', (tester) async {
    final container = ProviderContainer.test(
      overrides: [
        tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
      ],
    );
    await container.read(sessionProvider.notifier).restore();

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Select Login Method'), findsOneWidget);

    container.read(sessionProvider.notifier).pendingApproval();
    await tester.pumpAndSettle();
    expect(find.text('Approval Pending'), findsOneWidget);
  });
}
