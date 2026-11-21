import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/shared/pagination/paged_notifier.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';

/// Which accounts a list shows.
enum AccountKind { admins, employees }

/// The Manage admins / Manage users lists, with status tabs and search.
final accountsListProvider = NotifierProvider.autoDispose
    .family<AccountsListController, PagedState<ManagedAccount>, AccountKind>(
      AccountsListController.new,
    );

class AccountsListController extends PagedNotifier<ManagedAccount> {
  final AccountKind kind;
  AccountsListController(this.kind);

  String _status = 'pending';
  String _search = '';
  String? _adminId;

  /// The open tab: 'pending', 'active' or 'inactive'.
  String get status => _status;
  String get search => _search;

  @override
  Future<PagedResult<ManagedAccount>> fetchPage(int page, int limit) {
    final repo = ref.read(manageRepositoryProvider);
    return switch (kind) {
      AccountKind.admins => repo.admins(
        status: _status,
        search: _search,
        page: page,
        limit: limit,
      ),
      AccountKind.employees => repo.employees(
        status: _status,
        search: _search,
        adminId: _adminId,
        page: page,
        limit: limit,
      ),
    };
  }

  @override
  Object idOf(ManagedAccount item) => item.id;

  void setStatus(String s) {
    if (s == _status) return;
    _status = s;
    editItems((_) => const []);
    refresh();
  }

  void setSearch(String q) {
    if (q == _search) return;
    _search = q;
    refresh();
  }

  /// SUPER_ADMIN only: show one team's employees (null = everyone).
  void setAdminFilter(String? adminId) {
    _adminId = adminId;
    refresh();
  }

  /// Puts the server's version of a row in place, or drops it when its new
  /// status no longer belongs to the open tab.
  void replace(ManagedAccount updated) {
    editItems((items) {
      final i = items.indexWhere((a) => a.id == updated.id);
      if (i < 0) return items;
      final merged = updated.withFallback(items[i]);
      return [
        ...items.take(i),
        if (merged.status.name == _status) merged,
        ...items.skip(i + 1),
      ];
    });
  }
}
