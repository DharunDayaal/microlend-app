import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/storage/session_storage.dart';
import 'package:micro_lending_app/core/storage/token_storage.dart';

/// Secure storage for the access and refresh tokens.
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage.instance,
);

/// The saved profile of the signed-in user.
final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => const SessionStorage(),
);
