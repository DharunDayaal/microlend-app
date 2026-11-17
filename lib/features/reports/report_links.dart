import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/routes/app_routes.dart';

class ReportLinks {
  ReportLinks._();

  static void loan(BuildContext c, String loanId) =>
      c.push(AppRoutes.loanDetail(loanId));

  static void customer(BuildContext c, String customerId) =>
      c.push(AppRoutes.customerDetail(customerId));
}
