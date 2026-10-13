import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/models/paged_modal.dart';
import 'package:micro_lending_app/data/services/response_parser.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';

class LoanService {
  LoanService._();

  static final _api = ApiClient.instance;

  static Future<LoanModel> getLoanDetails({required String loanid}) async {
    final response = await _api.get(ApiEndpoints.getLoanDetails(loanid));

    return LoanModel.fromJson(ResponseParser.object(response, "loan"));
  }

  static Future<PagedResult<LoanModel>> listLoans({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    final response = await _api.get(
      ApiEndpoints.getLoans,
      query: {
        "page": page,
        "limit": limit,
        if (status.isNotEmpty) 'status': status,
        if (search.isNotEmpty) 'search': search,
      },
    );

    return PagedResult(
      items: ResponseParser.list(
        response,
        "loans",
      ).map(LoanModel.fromListJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(response),
    );
  }
}
