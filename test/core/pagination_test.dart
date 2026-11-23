import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/response_parser.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/data/customer_repository_impl.dart';
import 'package:micro_lending_app/features/customers/data/sources/customer_remote_data_source.dart';
import 'package:micro_lending_app/features/exports/data/export_repository_impl.dart';
import 'package:micro_lending_app/features/exports/data/sources/export_remote_data_source.dart';
import 'package:micro_lending_app/features/manage/data/manage_repository_impl.dart';
import 'package:micro_lending_app/features/manage/data/sources/manage_remote_data_source.dart';
import 'package:micro_lending_app/features/profile/data/profile_repository_impl.dart';
import 'package:micro_lending_app/features/profile/data/sources/profile_remote_data_source.dart';

/// Answers GETs from [pages]: path -> one body per page (page 1 first).
class FakeApi extends Fake implements ApiClient {
  final Map<String, List<Map<String, dynamic>>> pages;
  final List<String> calls = [];
  FakeApi(this.pages);

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) async {
    final page = query?['page'] as int? ?? 1;
    calls.add(
      '$path?${query?.entries.map((e) => '${e.key}=${e.value}').join('&')}',
    );
    return pages[path]![page - 1];
  }
}

/// `{ success, data: { [key]: rows, ...extra, metadata } }`
Map<String, dynamic> body(
  String key,
  List<Map<String, dynamic>> rows, {
  required int page,
  required bool more,
  Map<String, dynamic> extra = const {},
}) => {
  'success': true,
  'data': {
    key: rows,
    ...extra,
    'metadata': {'current_page': page, 'limit': 100, 'has_next_page': more},
  },
};

void main() {
  group('ResponseParser.paged', () {
    test('reads rows and metadata', () {
      final r = ResponseParser.paged(
        body(
          'loans',
          [
            {'id': 'a'},
            {'id': 'b'},
          ],
          page: 2,
          more: true,
        ),
        'loans',
        (j) => j['id'],
        page: 1,
      );
      expect(r.items, ['a', 'b']);
      expect(r.page, 2); // current_page wins
      expect(r.hasNextPage, true);
    });

    test('a missing list or metadata is an empty last page', () {
      final r = ResponseParser.paged(
        {'success': true, 'data': {}},
        'loans',
        (j) => j,
        page: 3,
      );
      expect(r.items, isEmpty);
      expect(r.page, 3);
      expect(r.hasNextPage, false);
    });
  });

  test(
    'fetchAllPages follows has_next_page and stops on an empty page',
    () async {
      final asked = <int>[];
      final all = await fetchAllPages((page) async {
        asked.add(page);
        return PagedResult(
          items: page < 3 ? [page] : <int>[],
          page: page,
          hasNextPage: true, // a server that never says "done"
        );
      });
      expect(all, [1, 2]);
      expect(asked, [1, 2, 3]);
    },
  );

  test('customer loans and referrals read every page', () async {
    Map<String, dynamic> loan(String id) => {'id': id, 'status': 'CLOSED'};
    final api = FakeApi({
      '/users/loans/c1': [
        body('loans', [loan('l1'), loan('l2')], page: 1, more: true),
        body('loans', [loan('l3')], page: 2, more: false),
      ],
      '/users/referrals/c1': [
        body(
          'referrals',
          [
            {'id': 'r1'},
          ],
          page: 1,
          more: false,
        ),
      ],
    });
    final repo = CustomerRepositoryImpl(CustomerRemoteDataSource(api));

    expect((await repo.loans('c1')).map((l) => l.id), ['l1', 'l2', 'l3']);
    expect((await repo.referrals('c1')).map((r) => r.id), ['r1']);
    expect(api.calls, [
      '/users/loans/c1?page=1&limit=100',
      '/users/loans/c1?page=2&limit=100',
      '/users/referrals/c1?page=1&limit=100',
    ]);
  });

  test('the team merges pages; counts come from the first page', () async {
    Map<String, dynamic> m(String id) => {'id': id, 'user_name': 'U$id'};
    final api = FakeApi({
      '/me/team': [
        body(
          'members',
          [m('1'), m('2')],
          page: 1,
          more: true,
          extra: {'pending_count': 7},
        ),
        body(
          'members',
          [m('3')],
          page: 2,
          more: false,
          extra: {'pending_count': 7},
        ),
      ],
    });
    final t = await ManageRepositoryImpl(ManageRemoteDataSource(api)).team();
    expect(t.isOverview, false);
    expect(t.members.map((e) => e.id), ['1', '2', '3']);
    expect(t.pendingCount, 7);
    expect(api.calls.last, '/me/team?page=2&limit=100');
  });

  test('a super admin overview merges team pages', () async {
    Map<String, dynamic> a(String id) => {'admin_id': id, 'user_name': 'A$id'};
    final api = FakeApi({
      '/me/team': [
        body(
          'teams',
          [a('1')],
          page: 1,
          more: true,
          extra: {'pending_admin_approvals': 2},
        ),
        body(
          'teams',
          [a('2')],
          page: 2,
          more: false,
          extra: {'pending_admin_approvals': 2},
        ),
      ],
    });
    final t = await ManageRepositoryImpl(ManageRemoteDataSource(api)).team();
    expect(t.isOverview, true);
    expect(t.teams.map((e) => e.adminId), ['1', '2']);
    expect(t.pendingAdminApprovals, 2);
  });

  test('sessions read every page', () async {
    final api = FakeApi({
      '/me/sessions': [
        body(
          'sessions',
          [
            {'id': 's1'},
          ],
          page: 1,
          more: true,
        ),
        body(
          'sessions',
          [
            {'id': 's2'},
          ],
          page: 2,
          more: false,
        ),
      ],
    });
    final s = await ProfileRepositoryImpl(ProfileRemoteDataSource(api))
        .getSessions();
    expect(s.map((e) => e.id), ['s1', 's2']);
  });

  test('exports ask for one page and report whether there is more', () async {
    Map<String, dynamic> job(String id) => {
      'id': id,
      'type': 'loans_register',
      'format': 'xlsx',
      'status': 'done',
    };
    final api = FakeApi({
      '/exports': [
        body('exports', [job('e1')], page: 1, more: true),
      ],
    });
    final r = await ExportRepositoryImpl(ExportRemoteDataSource(api)).list();
    expect(r.items.single.id, 'e1');
    expect(r.hasNextPage, true);
    expect(api.calls, ['/exports?page=1&limit=20']);
  });
}
