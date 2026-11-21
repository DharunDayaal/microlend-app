import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/utils/validators.dart';
import 'package:micro_lending_app/features/audit/data/dtos/audit_dto.dart';
import 'package:micro_lending_app/features/audit/presentation/formatting/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/presentation/formatting/audit_diff.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ta = lookupAppLocalizations(const Locale('ta'));

  group('validators', () {
    test('English messages are unchanged', () {
      final v = AppValidators(en);
      expect(v.required(''), 'This field is required');
      expect(v.required(' ', 'City'), 'City is required');
      expect(v.email('x'), 'Enter a valid email');
      expect(
        v.password('abc'),
        'Missing: 8+ chars, uppercase, number, special char',
      );
      expect(v.otp('12'), 'Enter the 6-digit OTP');
      expect(v.percentage('120'), 'Enter a value between 0 and 100');
      expect(v.positiveNumber('', 'Months'), 'Months is required');
    });

    test('Tamil messages come from app_ta', () {
      final v = AppValidators(ta);
      expect(v.phone(''), ta.valPhoneRequired);
      expect(v.required('', 'நகரம்'), 'நகரம் தேவை');
      expect(v.password('Abc'), startsWith('இல்லாதவை: 8+ எழுத்துகள்'));
    });
  });

  group('audit text', () {
    final log = AuditLogDto.fromJson({
      'id': '1',
      'created_at': '2026-11-20T10:00:00Z',
      'action': 'LOAN_TERMS_EDITED',
      'module': 'LOAN',
      'entity_type': 'LOAN',
      'entity_id': 'l1',
      'actor': {'id': 'u1', 'name': '', 'role': 'USER'},
      'old_value': {'default_total_months': 3, 'is_active': true},
      'new_value': {'default_total_months': 4, 'is_active': false},
      'meta': {'source': 'app', 'reason': 'typo'},
    });

    test('English text is unchanged', () {
      expect(actionLabel(en, log.action), 'Loan terms edited');
      expect(actionLabel(en, 'SOMETHING_NEW'), 'Something New');
      expect(moduleStyle('loan').label(en), 'Loan');
      expect(actorText(en, log), 'Unknown (Employee)');
      expect(subjectText(en, log), 'Loan l1');
      expect(
        summaryLine(en, log),
        'Default term: 3 months → 4 months   Active: Active → Inactive',
      );
      expect(metaDetails(en, log).first, ('Reason', 'typo'));
    });

    test('Tamil text comes from app_ta', () {
      expect(actionLabel(ta, log.action), ta.audActLoanTermsEdited);
      expect(moduleStyle('PAYMENT').label(ta), ta.audModPayment);
      expect(actorText(ta, log), '${ta.commonUnknown} (${ta.audModEmployee})');
      final rows = buildDiff(ta, log);
      expect(rows.first.label, ta.audFieldDefaultTerm);
      expect(rows.first.after.text, ta.audValMonths('4'));
      expect(rows.last.after.text, ta.audValInactive);
    });
  });
}
