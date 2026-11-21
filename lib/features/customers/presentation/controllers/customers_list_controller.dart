import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/shared/pagination/paged_notifier.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';

/// The Field tab list: customers due on the chosen weekday.
final customersListProvider =
    NotifierProvider.autoDispose<CustomersListController, PagedState<Customer>>(
      CustomersListController.new,
    );

class CustomersListController extends PagedNotifier<Customer> {
  String _weekday = '';
  String _search = '';

  /// The screen picks the weekday, then loads.
  @override
  bool get autoLoad => false;

  Future<void> load({
    required String weekday,
    required String search,
    bool showSkeleton = true,
  }) {
    _weekday = weekday;
    _search = search;
    return refresh(showSkeleton: showSkeleton);
  }

  @override
  Future<PagedResult<Customer>> fetchPage(int page, int limit) => ref
      .read(customerRepositoryProvider)
      .customersByWeekday(
        weekday: _weekday,
        page: page,
        limit: limit,
        search: _search,
      );

  @override
  Object idOf(Customer item) => item.id;
}
