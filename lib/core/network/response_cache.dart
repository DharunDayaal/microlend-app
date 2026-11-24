import 'dart:convert';
import 'dart:io';

import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:path_provider/path_provider.dart';

/// The last good answer to each GET, so screens still open offline.
abstract interface class ResponseCache {
  Future<dynamic> read(String key);
  Future<void> write(String key, dynamic data);

  /// Called on sign-out: nothing from this account may stay behind.
  Future<void> clear();
}

/// One JSON file per request in the app's private support folder (never
/// shared storage). Keeps at most [maxEntries], dropping the oldest.
class FileResponseCache implements ResponseCache {
  FileResponseCache({
    Future<Directory> Function()? directory,
    this.maxEntries = 400,
  }) : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;
  final int maxEntries;
  int _writes = 0;

  /// Answers still being written, so a read right after a write (before it
  /// reaches the disk) still finds them.
  final Map<String, dynamic> _writing = {};

  Future<Directory> _dir() async =>
      Directory('${(await _directory()).path}/http_cache');

  /// FNV-1a: a stable file name for any URL (String.hashCode can change
  /// between runs).
  static String fileNameFor(String key) {
    var h = 0xcbf29ce484222325;
    for (final b in utf8.encode(key)) {
      h ^= b;
      h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return '${h.toUnsigned(64).toRadixString(16)}.json';
  }

  @override
  Future<dynamic> read(String key) async {
    if (_writing.containsKey(key)) return _writing[key];
    try {
      final f = File('${(await _dir()).path}/${fileNameFor(key)}');
      if (!await f.exists()) return null;
      final entry = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return entry['key'] == key ? entry['data'] : null; // hash collision
    } catch (e) {
      AppLogger.warning('Offline cache read failed', error: e);
      return null;
    }
  }

  @override
  Future<void> write(String key, dynamic data) async {
    _writing[key] = data;
    try {
      final dir = await _dir();
      await dir.create(recursive: true);
      final f = File('${dir.path}/${fileNameFor(key)}');
      final tmp = File('${f.path}.tmp');
      await tmp.writeAsString(jsonEncode({'key': key, 'data': data}));
      await tmp.rename(f.path);
      if (++_writes % 50 == 0) await _trim(dir);
    } catch (e) {
      // only offline viewing is affected
      AppLogger.warning('Offline cache write failed', error: e);
    } finally {
      // a newer write of the same key may still be going
      if (identical(_writing[key], data)) _writing.remove(key);
    }
  }

  Future<void> _trim(Directory dir) async {
    final files = dir.listSync().whereType<File>().toList();
    if (files.length <= maxEntries) return;
    files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
    for (final f in files.take(files.length - maxEntries)) {
      await f.delete();
    }
  }

  @override
  Future<void> clear() async {
    _writing.clear();
    try {
      final dir = await _dir();
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      AppLogger.warning('Offline cache clear failed', error: e);
    }
  }
}
// Waiting before the fallback: a GET always tries the network first. With no signal that usually fails at once, but on a weak or captive network (e.g. hotel Wi-Fi that needs a login) the screen can wait up to the 20–30 s timeout before the saved copy appears. The fix is to skip straight to the cache when the connection monitor already says offline.
// No age shown: screens don't say how old the saved data is, only the "offline" notice. A balance could be from yesterday.
// Pull-to-refresh while offline "succeeds" with the same saved data, which can look like it was refreshed.
// Not encrypted: the files are protected by the phone's app sandbox and wiped on logout, but they aren't encrypted themselves.