import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_tracker.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'fakes.dart';

/// The tracker must lay out without overflow on small phones, in both
/// languages, with larger system text, overdue or not.
void main() {
  final recent = DateTime.now().subtract(const Duration(days: 20));
  final loans = <String, LoanModel>{
    'on time': loan('l1', tracks: [track(1), track(2)], issuedAt: recent),
    'overdue': loan('l1', tracks: [for (var w = 1; w <= 12; w++) track(w)]),
  };
  const sizes = [Size(320, 568), Size(360, 640), Size(390, 844)];

  for (final locale in AppLocalizations.supportedLocales) {
    for (final size in sizes) {
      for (final scale in [1.0, 1.3]) {
        for (final e in loans.entries) {
          testWidgets(
            '${e.key} loan at ${size.width.toInt()}x${size.height.toInt()} '
            '$locale x$scale',
            (tester) async {
              tester.view.physicalSize = size * 3;
              tester.view.devicePixelRatio = 3;
              addTearDown(tester.view.reset);

              final repo = FakeLoanRepository()..loans['l1'] = e.value;
              await tester.pumpWidget(
                ProviderScope(
                  overrides: [
                    loanRepositoryProvider.overrideWithValue(repo),
                    borrowerLookupProvider.overrideWithValue(
                      FakeBorrowerLookup(),
                    ),
                  ],
                  child: MaterialApp(
                    theme: AppTheme.darkTheme,
                    locale: locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: TextScaler.linear(scale)),
                      child: child!,
                    ),
                    home: const LoanTrackerScreen(loanId: 'l1'),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              // the tracks are reachable by scrolling
              await tester.drag(
                find.byType(CustomScrollView),
                const Offset(0, -2000),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
