import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/i18next.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalizationDataSource extends Mock
    implements LocalizationDataSource {}

class MockResourceStore extends Mock implements ResourceStore {}

void main() {
  const en = Locale('en'), enUS = Locale('en', 'US');
  const pt = Locale('pt'), ptBR = Locale('pt', 'BR');
  const ar = Locale('ar');

  late MockLocalizationDataSource dataSource;
  late MockResourceStore resourceStore;
  late I18NextLocalizationDelegate localizationDelegate;

  setUpAll(() {
    registerFallbackValue(Locale('any'));
  });

  setUp(() {
    dataSource = MockLocalizationDataSource();
    resourceStore = MockResourceStore();
    localizationDelegate = I18NextLocalizationDelegate(
      locales: [en, ptBR],
      dataSource: dataSource,
      resourceStore: resourceStore,
    );
  });

  group('#isSupported', () {
    test('given an exact matching locale', () {
      expect(localizationDelegate.isSupported(en), isTrue);
      expect(localizationDelegate.isSupported(ptBR), isTrue);
    });

    test('given a language code matching locale', () {
      expect(localizationDelegate.isSupported(enUS), isTrue);
      expect(localizationDelegate.isSupported(pt), isTrue);
    });

    test('given a non matching language code locale', () {
      expect(localizationDelegate.isSupported(ar), isFalse);
    });
  });

  group('#normalizeLocale', () {
    test('given an exact matching locale', () {
      expect(localizationDelegate.normalizeLocale(en), en);
      expect(localizationDelegate.normalizeLocale(ptBR), ptBR);
    });

    test('given a language code matching locale', () {
      expect(localizationDelegate.normalizeLocale(enUS), en);
      expect(localizationDelegate.normalizeLocale(pt), ptBR);
    });

    test('given a non matching language code locale', () {
      expect(() => localizationDelegate.normalizeLocale(ar), throwsException);
    });
  });

  group('#load', () {
    test('given an exact matching locale', () async {
      when(() => dataSource.load(any())).thenAnswer((_) async => {});

      await expectLater(localizationDelegate.load(en), completes);
      verify(() => dataSource.load([en])).called(1);
    });

    test('given a language code matching locale', () async {
      when(() => dataSource.load(any())).thenAnswer((_) async => {});

      await expectLater(localizationDelegate.load(enUS), completes);
      verify(() => dataSource.load([en])).called(1);
    });

    test('given a non matching language code locale', () async {
      when(() => dataSource.load(any())).thenAnswer((_) async => {});

      await expectLater(() => localizationDelegate.load(ar), throwsException);
      verifyNever(() => dataSource.load(any()));
    });

    test('given fallback locales', () async {
      localizationDelegate = I18NextLocalizationDelegate(
        locales: [en],
        dataSource: dataSource,
        resourceStore: resourceStore,
        options: I18NextOptions(fallbackLocales: [ptBR]),
      );
      when(() => dataSource.load(any())).thenAnswer((_) async => {});

      await expectLater(localizationDelegate.load(enUS), completes);
      // loads locales that aren't marked in supported locales as well.
      verify(() => dataSource.load([en, ptBR])).called(1);
    });

    test('when dataSource errors', () async {
      const error = 'Some error';
      when(() => dataSource.load(any())).thenAnswer((_) async => throw error);

      await expectLater(localizationDelegate.load(en), throwsA(error));
    });

    test('when dataSource succeeds', () async {
      const data1 = <String, Object>{'key': 'ns1'};
      const data2 = <String, Object>{'key': 'ns1'};
      when(() => dataSource.load(any())).thenAnswer(
        (_) async => {
          en: {'ns1': data1, 'ns2': data2},
        },
      );

      final i18next = await localizationDelegate.load(en);
      expect(i18next.locale, en);
      verify(
        () => resourceStore.addLocale(en, {'ns1': data1, 'ns2': data2}),
      ).called(1);
    });

    test('when dataSource is synchronous', () {
      const data1 = <String, Object>{'key': 'ns1'};
      when(() => dataSource.load(any())).thenAnswer(
        (_) => SynchronousFuture({
          en: {'ns1': data1},
        }),
      );

      // checking if this is being called sync
      I18Next? result;
      localizationDelegate.load(en).then((value) => result = value);
      expect(result, isNotNull);
      expect(result!.locale, en);
      verify(() => resourceStore.addLocale(en, {'ns1': data1})).called(1);
    });
  });
}
