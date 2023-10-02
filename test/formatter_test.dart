import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/src/formatter.dart';
import 'package:i18next/src/interpolation_format.dart';
import 'package:i18next/src/options.dart';

void main() {
  const locale = Locale('en');
  late I18NextOptions options;

  setUp(() {
    options = I18NextOptions.base;
  });

  group('format', () {
    group('given no formats', () {
      test('without a missingInterpolationHandler', () {
        options = options.copyWith(formats: {});
        final result = format('value', [], locale, options);
        expect(result, 'value');
      });

      group('with a missingInterpolationHandler', () {
        test('when the result is a string', () {
          options = options.copyWith(
            missingInterpolationHandler: expectAsync4(
              (value, format, loc, opt) => fail(''),
              count: 0,
            ),
          );
          expect(format('Value', [], locale, options), 'Value');
        });

        group('when the result is not a string', () {
          test('and the fallback returns a value', () {
            final Object? value = ['Value'];
            options = options.copyWith(
              missingInterpolationHandler: expectAsync4(
                (val, format, loc, opt) {
                  expect(format, InterpolationFormat.fallback);
                  expect(val, value);
                  expect(loc, locale);
                  expect(opt, options);
                  return 'interpolation formatter fallback';
                },
              ),
            );
            expect(
              format(value, [], locale, options),
              'interpolation formatter fallback',
            );
          });

          test('and the fallback returns null', () {
            final Object? value = ['Value'];
            options = options.copyWith(
              missingInterpolationHandler: expectAsync4(
                (val, format, loc, opt) {
                  expect(format, InterpolationFormat.fallback);
                  expect(val, value);
                  expect(loc, locale);
                  expect(opt, options);
                  return null;
                },
              ),
            );
            expect(format(value, [], locale, options), isNull);
          });
        });
      });
    });

    group('given no matching formats by name', () {
      test('without a missingInterpolationHandler', () {
        options = options.copyWith(formats: {});
        final result = format('value', ['format'], locale, options);
        expect(result, 'value');
      });

      test('with a missingInterpolationHandler', () {
        options = options.copyWith(
          missingInterpolationHandler: expectAsync4(
            (value, format, loc, opt) {
              expect(value, 'Value');
              expect(format.name, 'format');
              expect(format.options, isEmpty);
              expect(loc, locale);
              expect(opt, options);
              return 'interpolation formatter fallback';
            },
          ),
        );
        expect(
          format('Value', ['format'], locale, options),
          'interpolation formatter fallback',
        );
      });
    });

    group('when there is one format', () {
      test('and it successfully formats', () {
        options = options.copyWith(
          formats: {
            'format': expectAsync4((value, format, loc, opt) {
              expect(value, 'My Value');
              expect(format.name, 'format');
              expect(format.options, isEmpty);
              expect(loc, locale);
              expect(opt, options);
              return 'Replaced Value';
            }),
          },
          // should not have been called
          missingInterpolationHandler: expectAsync4(
            (value, format, loc, opt) => fail(''),
            count: 0,
          ),
        );
        final result = format('My Value', ['format'], locale, options);
        expect(result, 'Replaced Value');
      });

      test('and it throws while formatting', () {
        options = options.copyWith(
          formats: {
            'format': expectAsync4(
              (value, format, loc, opt) => throw 'Some error',
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
            'format': expectAsync4((value, format, loc, opt) => null),
          },
        );
        final result = format('My Value', ['format'], locale, options);
        expect(result, isNull);
      });
    });

    group('when there are multiple formats', () {
      test('and finds all format names', () {
        options = options.copyWith(formats: {
          'fmt1': expectAsync4((value, format, loc, opt) {
            expect(value, 'initial value');
            expect(format.name, 'fmt1');
            expect(format.options, isEmpty);
            return 'replaced first value';
          }),
          'fmt2': expectAsync4((value, format, loc, opt) {
            expect(value, 'replaced first value');
            expect(format.name, 'fmt2');
            expect(format.options, {'option': 'optValue'});
            return 'replaced second value';
          }),
          'fmt3': expectAsync4((value, format, loc, opt) {
            expect(value, 'replaced second value');
            expect(format.name, 'fmt3');
            expect(format.options, {
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
          'fmt1': expectAsync4((value, format, loc, opt) {
            expect(value, 'initial value');
            expect(format.name, 'fmt1');
            expect(format.options, isEmpty);
            return 123.456;
          }),
          'fmt2': expectAsync4((value, format, loc, opt) {
            expect(value, 123.456);
            expect(format.name, 'fmt2');
            expect(format.options, isEmpty);
            return const MapEntry('Some Key', 999);
          }),
          'fmt3': expectAsync4((value, format, loc, opt) {
            expect(value, const MapEntry('Some Key', 999));
            expect(format.name, 'fmt3');
            expect(format.options, isEmpty);
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
            'fmt1': expectAsync4((value, format, loc, opt) {
              expect(value, 'initial value');
              expect(format.name, 'fmt1');
              expect(format.options, isEmpty);
              return null;
            }),
            'fmt2': expectAsync4((value, format, loc, opt) {
              expect(value, isNull);
              expect(format.name, 'fmt2');
              expect(format.options, isEmpty);
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
