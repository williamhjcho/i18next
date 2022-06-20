import 'dart:ui';

import 'options.dart';

// ignore_for_file: lines_longer_than_80_chars

/// Runs through the [formats] starting with [value], and returns the final
/// formatted output in its [Object.toString] form.
///
/// While running, if one the of the formatters returns null, there's still a
/// chance for the next formats to interpret it and evaluate it into
/// something else.
/// If any of the formatters throw, it'll get swallowed and the current value
/// is used for the next format.
String? format(
  Object? value,
  Iterable<String> formats,
  Locale locale,
  I18NextOptions options,
) {
  final result = formats.fold<Object?>(value, (currentValue, format) {
    try {
      final parsedFormat = parseFormatString(format, options);
      final formatter = options.formats?[parsedFormat.name];
      if (formatter != null) {
        return formatter(currentValue, parsedFormat.options, locale, options);
      }
    } catch (error, stackTrace) {
      assert(
        false,
        'Formatting failed for: "$format".'
        '\n$error\n$stackTrace',
      );
    }
    return currentValue;
  });
  return result?.toString();
}

/// Parses the [formatString] into the format name its options.
///
/// Examples
/// "Some format {{value, formatName}}",
/// "Some format {{value, formatName(optionName: optionValue)}}",
/// "Some format {{value, formatName(option1Name: option1Value; option2Name: option2Value)}}"
InterpolationFormat parseFormatString(
  String formatString,
  I18NextOptions options,
) {
  const optionsPrefix = '(';
  final optionsSeparator = options.optionsSeparator ?? ';';
  final optionValueSeparator = options.optionValueSeparator ?? ':';

  var formatName = formatString.trim();
  final formatOptions = <String, Object>{};
  if (formatName.contains(optionsPrefix)) {
    final parts = formatName.split(optionsPrefix);
    formatName = parts[0].trim();
    final optionString = parts[1].substring(0, parts[1].length - 1).trim();
    final allOptions = optionString
        .split(optionsSeparator)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    final formatterValues = options.formatterValues ?? _defaultFormatterValues;
    for (final option in allOptions) {
      // splits and uses the first value (before :) as the key, and the rest
      // as the value (which might contain other : chars)
      final optSplit = option.split(optionValueSeparator);
      final key = optSplit.first.trim();
      final value = optSplit.sublist(1).join(optionValueSeparator).trim();
      // only adding it for the first named option
      formatOptions[key] ??= formatterValues[value] ?? value;
    }
  }

  return InterpolationFormat(formatName, formatOptions);
}

const Map<String, Object> _defaultFormatterValues = {
  'true': true,
  'false': false,
};

/// A parsed format from a string.
///
/// e.g.
/// `formatName` = name='formatName' options=empty
/// `formatName()` = name='formatName' options=empty
/// `formatName(op1: true; op2: some text)` = name='formatName' options={'op1': true, op2:'some text'}
class InterpolationFormat {
  InterpolationFormat(this.name, this.options);

  /// The name of the format
  final String name;

  /// The options that were associated to [name].
  final Map<String, Object> options;

  @override
  int get hashCode => hashValues(name, options);

  @override
  bool operator ==(Object other) =>
      other is InterpolationFormat &&
      other.name == name &&
      other.options == options;

  @override
  String toString() => '($name, $options)';
}
