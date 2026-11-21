import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/api_client.dart';

/// The app's single HTTP client. Override it in tests with a fake.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient.instance);
