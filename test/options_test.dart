import 'package:flutter_test/flutter_test.dart';
import 'package:i18next/src/options.dart';

void main() {
  const base = I18NextOptions.base;

  test('default values', () {
    const options = I18NextOptions();
    expect(options.namespaceSeparator, isNull);
    expect(options.contextSeparator, isNull);
    expect(options.pluralSeparator, isNull);
    expect(options.keySeparator, isNull);
    expect(options.interpolationPrefix, isNull);
    expect(options.interpolationSuffix, isNull);
    expect(options.formatSeparator, isNull);
    expect(options.formats, isNull);
    expect(options.optionsSeparator, isNull);
    expect(options.optionValueSeparator, isNull);
    expect(options.nestingPrefix, isNull);
    expect(options.nestingSuffix, isNull);
    expect(options.nestingSeparator, isNull);
    expect(options.pluralSuffix, isNull);
    expect(options.missingKeyHandler, isNull);
    expect(options.translationFailedHandler, isNull);
  });

  test('default base values', () {
    expect(base.namespaceSeparator, ':');
    expect(base.contextSeparator, '_');
    expect(base.pluralSeparator, '_');
    expect(base.keySeparator, '.');
    expect(base.interpolationPrefix, '{{');
    expect(base.interpolationSuffix, '}}');
    expect(base.formatSeparator, ',');
    expect(base.formats, const {});
    expect(base.optionsSeparator, ';');
    expect(base.optionValueSeparator, ':');
    expect(base.nestingPrefix, r'$t(');
    expect(base.nestingSuffix, ')');
    expect(base.nestingSeparator, ',');
    expect(base.pluralSuffix, 'plural');
    expect(base.missingKeyHandler, isNull);
    expect(base.translationFailedHandler, isNull);
  });

  group('#merge', () {
    const empty = I18NextOptions();
    final another = I18NextOptions(
      fallbackNamespaces: ['Some fallbackNamespace'],
      namespaceSeparator: 'Some namespaceSeparator',
      contextSeparator: 'Some contextSeparator',
      pluralSeparator: 'Some pluralSeparator',
      keySeparator: 'Some keySeparator',
      interpolationPrefix: 'Some interpolationPrefix',
      interpolationSuffix: 'Some interpolationSuffix',
      formatSeparator: 'Some interpolationSeparator',
      formatterValues: {'key': 'Some formatterValues'},
      formats: {'fmt': (value, options, loc, opt) => value?.toString()},
      optionsSeparator: 'Some optionsSeparator',
      optionValueSeparator: 'Some optionValueSeparator',
      nestingPrefix: 'Some nestingPrefix',
      nestingSuffix: 'Some nestingSuffix',
      nestingSeparator: 'Some nestingSeparator',
      pluralSuffix: 'Some pluralSuffix',
      escapeValue: true,
    );

    test('given no values', () {
      expect(base.merge(base), base);
      expect(base.copyWith(), base);
      expect(empty.merge(empty), empty);
      expect(another.copyWith(), another);
      expect(another.merge(another), another);
    });

    test('from empty given full', () {
      expect(empty.merge(base), base);
      expect(empty.merge(another), another);
    });

    test('from full given empty', () {
      expect(base.merge(empty), base);
      expect(another.merge(empty), another);
    });

    test('from full given full', () {
      expect(base.merge(another), another);
      expect(another.merge(another), another);
    });

    test('given null', () {
      expect(base.merge(null), equals(base));
      expect(empty.merge(null), empty);
      expect(another.merge(null), another);

      expect(identical(base.merge(null), base), isTrue);
    });
  });

  group('#copyWith', () {
    final another = I18NextOptions(
      fallbackNamespaces: ['Some fallbackNamespace'],
      namespaceSeparator: 'Some namespaceSeparator',
      contextSeparator: 'Some contextSeparator',
      pluralSeparator: 'Some pluralSeparator',
      keySeparator: 'Some keySeparator',
      interpolationPrefix: 'Some interpolationPrefix',
      interpolationSuffix: 'Some interpolationSuffix',
      formatSeparator: 'Some interpolationSeparator',
      formatterValues: {'a': 0},
      formats: {'fmt': (value, options, loc, opt) => value?.toString()},
      optionsSeparator: 'Some optionsSeparator',
      optionValueSeparator: 'Some optionValueSeparator',
      nestingPrefix: 'Some nestingPrefix',
      nestingSuffix: 'Some nestingSuffix',
      nestingSeparator: 'Some nestingSeparator',
      pluralSuffix: 'Some pluralSuffix',
    );

    test('equality', () {
      expect(base == base, isTrue);
      expect(another == another, isTrue);
      expect(another == base, isFalse);
    });

    test('given no values', () {
      expect(base.copyWith(), base);
      expect(another.copyWith(), another);
    });

    for (final permutation in _generatePermutations([
      another.fallbackNamespaces!,
      another.namespaceSeparator!,
      another.contextSeparator!,
      another.pluralSeparator!,
      another.keySeparator!,
      another.interpolationPrefix!,
      another.interpolationSuffix!,
      another.formatSeparator!,
      another.formatterValues!,
      another.formats!,
      another.optionsSeparator!,
      another.optionValueSeparator!,
      another.nestingPrefix!,
      another.nestingSuffix!,
      another.nestingSeparator!,
      another.pluralSuffix!,
    ])) {
      test('given individual values=$permutation', () {
        final result = base.copyWith(
          fallbackNamespaces: permutation[0] as List<String>?,
          namespaceSeparator: permutation[1] as String?,
          contextSeparator: permutation[2] as String?,
          pluralSeparator: permutation[3] as String?,
          keySeparator: permutation[4] as String?,
          interpolationPrefix: permutation[5] as String?,
          interpolationSuffix: permutation[6] as String?,
          formatSeparator: permutation[7] as String?,
          formatterValues: permutation[8] as dynamic,
          formats: permutation[9] as dynamic,
          optionsSeparator: permutation[10] as String?,
          optionValueSeparator: permutation[11] as String?,
          nestingPrefix: permutation[12] as String?,
          nestingSuffix: permutation[13] as String?,
          nestingSeparator: permutation[14] as String?,
          pluralSuffix: permutation[15] as String?,
        );
        // at least one should be different
        expect(result, isNot(base));
        expect(
          result.fallbackNamespaces,
          permutation[0] ?? base.fallbackNamespaces,
        );
        expect(
          result.namespaceSeparator,
          permutation[1] ?? base.namespaceSeparator,
        );
        expect(
          result.contextSeparator,
          permutation[2] ?? base.contextSeparator,
        );
        expect(
          result.pluralSeparator,
          permutation[3] ?? base.pluralSeparator,
        );
        expect(
          result.keySeparator,
          permutation[4] ?? base.keySeparator,
        );
        expect(
          result.interpolationPrefix,
          permutation[5] ?? base.interpolationPrefix,
        );
        expect(
          result.interpolationSuffix,
          permutation[6] ?? base.interpolationSuffix,
        );
        expect(
          result.formatSeparator,
          permutation[7] ?? base.formatSeparator,
        );
        expect(
          result.formatterValues,
          permutation[8] ?? base.formatterValues,
        );
        expect(
          result.formats,
          permutation[9] ?? base.formats,
        );
        expect(
          result.optionsSeparator,
          permutation[10] ?? base.optionsSeparator,
        );
        expect(
          result.optionValueSeparator,
          permutation[11] ?? base.optionValueSeparator,
        );
        expect(
          result.nestingPrefix,
          permutation[12] ?? base.nestingPrefix,
        );
        expect(
          result.nestingSuffix,
          permutation[13] ?? base.nestingSuffix,
        );
        expect(
          result.nestingSeparator,
          permutation[14] ?? base.nestingSeparator,
        );
        expect(
          result.pluralSuffix,
          permutation[15] ?? base.pluralSuffix,
        );
      });
    }
  });
}

/// Generates a list of [input]s with just one non-null value
List<List<Object?>> _generatePermutations(List<Object> input) {
  final result = <List<Object?>>[];
  for (var index = 0; index < input.length; index += 1) {
    final alteredInput = List<Object?>.filled(input.length, null);
    alteredInput[index] = input[index];
    result.add(alteredInput);
  }
  return result;
}
