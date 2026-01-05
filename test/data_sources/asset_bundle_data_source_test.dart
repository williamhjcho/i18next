import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/i18next.dart';
import 'package:mocktail/mocktail.dart';

class MockAssetBundle extends Mock implements AssetBundle {
  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    return await loadMock(key) as T;
  }

  Future<AssetManifest> loadMock(String key);
}

class MockAssetManifest implements AssetManifest {
  MockAssetManifest(this.assets);

  final List<String> assets;

  @override
  List<String> listAssets() => assets;

  @override
  List<AssetMetadata>? getAssetVariants(String key) {
    throw UnimplementedError();
  }
}

void main() {
  const bundlePath = 'bundle/path';
  late MockAssetBundle bundle;
  late AssetBundleLocalizationDataSource dataSource;

  setUp(() {
    bundle = MockAssetBundle();
    dataSource = AssetBundleLocalizationDataSource(
      bundlePath: bundlePath,
      bundle: bundle,
    );
  });

  group('#loadFromAssetBundle', () {
    setUp(() {
      when(() => bundle.loadMock(any())).thenAnswer(
        (_) async => MockAssetManifest([
          "another/asset/path",
          "$bundlePath/en-US/file1.json",
          "$bundlePath/en-US/file2.json",
          "$bundlePath/pt/file1.json",
          "$bundlePath/pt/file2.json",
        ]),
      );
    });

    test('given any locale', () async {
      await expectLater(dataSource.load(const Locale('any')), completes);
    });

    test('given an unregistered locale', () {
      expect(dataSource.load(const Locale('ar')), completion(isEmpty));
    });

    test('given a supported full locale', () async {
      when(
        () => bundle.loadString(any(that: contains('$bundlePath/'))),
      ).thenAnswer((_) async => '{}');

      await expectLater(
        dataSource.load(const Locale('en', 'US')),
        completion(
          equals(<String, Map<String, Object>>{'file1': {}, 'file2': {}}),
        ),
      );

      verify(() => bundle.loadString('$bundlePath/en-US/file1.json')).called(1);
      verify(() => bundle.loadString('$bundlePath/en-US/file2.json')).called(1);
    });

    test('given an unsupported long locale', () async {
      await expectLater(
        dataSource.load(const Locale('pt-BR')),
        completion(isEmpty),
      );

      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/pt/'))),
      );
      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/pt-BR/'))),
      );
      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/en-US/'))),
      );
    });

    test('given a supported short locale', () async {
      when(
        () => bundle.loadString(any(that: contains('$bundlePath/'))),
      ).thenAnswer((_) async => '{}');

      await expectLater(
        dataSource.load(const Locale('pt')),
        completion(
          equals(<String, Map<String, Object>>{'file1': {}, 'file2': {}}),
        ),
      );

      verify(() => bundle.loadString('$bundlePath/pt/file1.json')).called(1);
      verify(() => bundle.loadString('$bundlePath/pt/file2.json')).called(1);
      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/en-US/'))),
      );
    });

    test('given an unsupported short locale', () async {
      await expectLater(
        dataSource.load(const Locale('ar')),
        completion(isEmpty),
      );

      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/ar/'))),
      );
      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/pt/'))),
      );
      verifyNever(
        () => bundle.loadString(any(that: contains('$bundlePath/en-US/'))),
      );
    });

    test('when bundle errors', () async {
      const error = 'Some error';
      when(() => bundle.loadMock(any())).thenAnswer((_) async => throw error);

      await expectLater(dataSource.load(const Locale('any')), throwsA(error));
    });

    test('given incorrect source-path to any bundle asset', () async {
      await expectLater(dataSource.load(const Locale('any')), completes);

      verifyNever(() => bundle.loadString(any(that: contains('bundle\\path'))));
    });
  });
}
