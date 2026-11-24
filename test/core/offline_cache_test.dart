import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/response_cache.dart';

/// Answers each request with the next entry: a status code and body, or
/// null for "no connection".
class _Adapter implements HttpClientAdapter {
  final List<(int, String)?> answers;
  _Adapter(this.answers);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final next = answers.removeAt(0);
    if (next == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      next.$2,
      next.$1,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('http_cache_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  FileResponseCache cache({int max = 400}) =>
      FileResponseCache(directory: () async => tmp, maxEntries: max);

  ApiClient client(List<(int, String)?> answers, ResponseCache store) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = _Adapter(answers);
    return ApiClient.withDio(dio)..cache = store;
  }

  group('FileResponseCache', () {
    test('keeps, reads back and clears answers', () async {
      final c = cache();
      await c.write('/loans?page=1', {'n': 1});
      expect(await c.read('/loans?page=1'), {'n': 1});
      expect(await c.read('/loans?page=2'), isNull);
      await c.clear();
      expect(await c.read('/loans?page=1'), isNull);
    });

    test('file names are stable and differ per request', () {
      expect(
        FileResponseCache.fileNameFor('/a'),
        FileResponseCache.fileNameFor('/a'),
      );
      expect(
        FileResponseCache.fileNameFor('/a'),
        isNot(FileResponseCache.fileNameFor('/b')),
      );
    });

    test('drops the oldest answers past the limit', () async {
      final c = cache(max: 10);
      for (var i = 0; i < 50; i++) {
        await c.write('/k$i', i);
      }
      final files = Directory('${tmp.path}/http_cache').listSync();
      expect(files.length, lessThanOrEqualTo(10));
      expect(await c.read('/k49'), 49); // the newest stays
    });
  });

  group('ApiClient GET offline', () {
    test('a saved answer is used when the network is down', () async {
      final api = client([(200, '{"v":1}'), null], cache());
      expect(await api.get('/loans', query: {'page': 1}), {'v': 1});
      expect(await api.get('/loans', query: {'page': 1}), {'v': 1});
    });

    test('without a saved answer the network error comes through', () async {
      final api = client([null], cache());
      await expectLater(
        api.get('/loans'),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'NO_INTERNET'),
        ),
      );
    });

    test('a server error is never hidden by the saved answer', () async {
      final api = client([
        (200, '{"v":1}'),
        (500, '{"message":"boom"}'),
      ], cache());
      await api.get('/loans');
      await expectLater(
        api.get('/loans'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 500)),
      );
    });

    test('requests without a token are never kept', () async {
      final api = client([(200, '{"v":1}'), null], cache());
      await api.get('/public', auth: false);
      await expectLater(
        api.get('/public', auth: false),
        throwsA(isA<ApiException>()),
      );
    });

    test('each request reports how it ended', () async {
      final seen = <String>[];
      final api = client([(200, '{}'), (404, '{}'), null], cache())
        ..onResult = (_, e) => seen.add(e == null ? 'ok' : '${e.statusCode}');
      await api.get('/a');
      await expectLater(api.get('/b'), throwsA(isA<ApiException>()));
      await expectLater(api.get('/c'), throwsA(isA<ApiException>()));
      expect(seen, ['ok', '404', 'null']);
    });

    test('the same query in any order is the same saved answer', () {
      expect(
        ApiClient.cacheKey('/x', {'b': 2, 'a': 1}),
        ApiClient.cacheKey('/x', {'a': 1, 'b': 2}),
      );
    });
  });
}
