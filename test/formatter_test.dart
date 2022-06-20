import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/src/formatter.dart';
import 'package:i18next/src/options.dart';

void main() {
  const locale = Locale('en');
  late I18NextOptions options;

  setUp(() {
    options = I18NextOptions.base;
  });

  group('format', () {
    test('given no formats', () {
      options = options.copyWith(formats: {});
      final result = format('value', [], locale, options);
      expect(result, 'value');
    });

    test('given no matching formats by name', () {
      options = options.copyWith(formats: {});
      final result = format('value', ['format'], locale, options);
      expect(result, 'value');
    });

    group('when there is one format', () {
      test('and it successfully formats', () {
        options = options.copyWith(
          formats: {
            'format': expectAsync4((value, formatOptions, loc, opt) {
              expect(value, 'My Value');
              expect(formatOptions, isEmpty);
              expect(loc, locale);
              expect(opt, options);
              return 'Replaced Value';
            }),
          },
        );
        final result = format('My Value', ['format'], locale, options);
        expect(result, 'Replaced Value');
      });

      test('and it throws while formatting', () {
        options = options.copyWith(
          formats: {
            'format': expectAsync4(
              (value, formatOptions, loc, opt) => throw 'Some error',
            ),
          },
        );
        expect(
          () => format('My Value', ['format'], locale, options),
          throwsAssertionError,
        );
      });

      test('and it returns null', () {
        options = options.copyWith(
          formats: {
            'format': expectAsync4((value, formatOptions, loc, opt) => null),
          },
        );
        final result = format('My Value', ['format'], locale, options);
        expect(result, isNull);
      });
    });

    group('when there are multiple formats', () {
      test('and finds all format names', () {
        options = options.copyWith(formats: {
          'fmt1': expectAsync4((value, formatOptions, loc, opt) {
            expect(value, 'initial value');
            expect(formatOptions, isEmpty);
            return 'replaced first value';
          }),
          'fmt2': expectAsync4((value, formatOptions, loc, opt) {
            expect(value, 'replaced first value');
            expect(formatOptions, {'option': 'optValue'});
            return 'replaced second value';
          }),
          'fmt3': expectAsync4((value, formatOptions, loc, opt) {
            expect(value, 'replaced second value');
            expect(formatOptions, {
              'option1': 'option value 1',
              'option2': 'option value 2',
            });
            return 'replaced third value';
          }),
        });
        final result = format(
          'initial value',
          [
            'fmt1',
            'fmt2(option:optValue)',
            'fmt3(option1: option value 1; option2: option value 2)'
          ],
          locale,
          options,
        );
        expect(result, 'replaced third value');
      });

      test('and the formats return different types', () {
        options = options.copyWith(formats: {
          'fmt1': expectAsync4((value, formatOptions, loc, opt) {
            expect(value, 'initial value');
            expect(formatOptions, isEmpty);
            return 123.456;
          }),
          'fmt2': expectAsync4((value, formatOptions, loc, opt) {
            expect(value, 123.456);
            expect(formatOptions, isEmpty);
            return const MapEntry('Some Key', 999);
          }),
          'fmt3': expectAsync4((value, formatOptions, loc, opt) {
            expect(value, const MapEntry('Some Key', 999));
            expect(formatOptions, isEmpty);
            return ['a', 'b', 'c'];
          }),
        });
        final result =
            format('initial value', ['fmt1', 'fmt2', 'fmt3'], locale, options);
        expect(result, '[a, b, c]');
      });

      test(
        'and the first format returns null, '
        'but last format returns a value',
        () {
          options = options.copyWith(formats: {
            'fmt1': expectAsync4((value, formatOptions, loc, opt) {
              expect(value, 'initial value');
              expect(formatOptions, isEmpty);
              return null;
            }),
            'fmt2': expectAsync4((value, formatOptions, loc, opt) {
              expect(value, isNull);
              expect(formatOptions, isEmpty);
              return 'replaced second value';
            }),
          });
          final result = format(
            'initial value',
            ['fmt1', 'fmt2'],
            locale,
            options,
          );
          expect(result, 'replaced second value');
        },
      );
    });
  });

  group('parseFormatString', () {
    test('given a simple format', () {
      final formats = [
        'someFormat',
        '  someFormat',
        'someFormat   ',
        '   someFormat   ',
      ];
      for (final string in formats) {
        final format = parseFormatString(string, options);
        expect(format.name, 'someFormat');
        expect(format.options, isEmpty);
      }
    });

    test('given a format without options', () {
      final formats = [
        'someFormat()',
        '  someFormat()',
        'someFormat()  ',
        '  someFormat()  ',
        '  someFormat(  )  ',
        '  someFormat  (  )  ',
      ];
      for (final string in formats) {
        final format = parseFormatString(string, options);
        expect(format.name, 'someFormat');
        expect(format.options, isEmpty);
      }
    });

    test('given a format with one option', () {
      final formats = [
        'someFormat(opt:one)',
        '  someFormat(opt:one)',
        'someFormat(opt:one)  ',
        '  someFormat(opt:one)  ',
        '  someFormat( opt:one )  ',
        '  someFormat  ( opt : one )  ',
        // with trailing separator(s)
        'someFormat(opt:one;)',
        'someFormat(opt:one;;;;)',
        'someFormat(opt:one; ; ; ; )',
      ];
      for (final string in formats) {
        final format = parseFormatString(string, options);
        expect(format.name, 'someFormat');
        expect(format.options, {'opt': 'one'});
      }
    });

    test('given a format with multiple options', () {
      final formats = [
        'someFormat(opt:one;opt2:two)',
        '  someFormat(opt:one;opt2:two)',
        'someFormat(opt:one;opt2:two)  ',
        '  someFormat(opt:one;opt2:two)  ',
        '  someFormat( opt:one;opt2:two )  ',
        '  someFormat  ( opt : one ; opt2:two )  ',
        // with trailing separator(s)
        'someFormat(opt:one;opt2:two;)',
        'someFormat(opt:one;opt2:two;;;;)',
        'someFormat(opt:one;opt2:two; ; ; ; )',
      ];
      for (final string in formats) {
        final format = parseFormatString(string, options);
        expect(format.name, 'someFormat');
        expect(format.options, {'opt': 'one', 'opt2': 'two'});
      }
    });

    test('given a format with default formatter values', () {
      final format = parseFormatString(
        'someFormat(a:true; b:false)',
        options,
      );
      expect(format.name, 'someFormat');
      expect(format.options, {'a': true, 'b': false});
    });

    test('given a format with custom formatter values', () {
      final format = parseFormatString(
        'someFormat(a:true; b:false; c:another)',
        options.copyWith(
          formatterValues: {'true': 1, 'false': 0, 'another': 'Custom value'},
        ),
      );
      expect(format.name, 'someFormat');
      expect(format.options, {'a': 1, 'b': 0, 'c': 'Custom value'});
    });
  });
}