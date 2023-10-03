import 'dart:convert';
import 'dart:ui';

import 'src/formatter.dart' as formatter;
import 'src/options.dart';
import 'utils.dart';

typedef Translate = String? Function(
  String key,
  Locale locale,
  Map<String, dynamic> variables,
  I18NextOptions options,
);

/// Exception thrown when the [interpolate] fails while processing
/// for either not containing a variable or with malformed or
/// incoherent evaluations.
class InterpolationException implements Exception {
  InterpolationException(this.message, this.match);

  final String message;
  final Match match;

  @override
  String toString() => 'InterpolationException: $message in "${match[0]}"';
}

/// Exception thrown when the [nest] fails while processing
class NestingException implements Exception {
  NestingException(this.message, this.match);

  final String message;
  final Match match;

  @override
  String toString() => 'NestingException: $message in "${match[0]}"';
}

/// Replaces occurrences of matches in [string] for the named values
/// in [options] (if they exist), by first passing through the
/// [I18NextOptions.formats] before joining the resulting string.
///
/// - 'Hello {{name}}' + {name: 'World'} -> 'Hello World'.
///   This example illustrates a simple interpolation.
/// - 'Now is {{date, dd/MM}}' + {date: DateTime.now()} -> 'Now is 23/09'.
///   In this example, [I18NextOptions.formats] must be able to
///   properly format the date.
/// - 'A string with {{grouped.key}}' + {'grouped': {'key': "grouped keys}} ->
///   'A string with grouped keys'. In this example the variables are in the
///   grouped formation (denoted by the [I18NextOptions.keySeparator]).
String interpolate(
  Locale locale,
  String string,
  Map<String, dynamic> variables,
  I18NextOptions options,
) {
  final formatSeparator = options.formatSeparator ?? ',';
  final keySeparator = options.keySeparator ?? '.';
  final escapeValue = options.escapeValue ?? true;

  final todo = [
    _InterpolationHelper(
      interpolationUnescapePattern(options),
      (input) => input,
    ),
    _InterpolationHelper(
      interpolationPattern(options),
      escapeValue ? (options.escape ?? escape) : (input) => input,
    ),
  ];

  return todo.fold<String>(
    string,
    (result, helper) => result.splitMapJoin(helper.pattern, onMatch: (match) {
      var variable = match[1]!.trim();

      Iterable<String> formats = [];
      if (variable.contains(formatSeparator)) {
        final variableParts = variable.split(formatSeparator);
        variable = variableParts.first.trim();
        formats = variableParts.skip(1).map((e) => e.trim());
      }

      if (variable.isEmpty) {
        throw InterpolationException('Missing variable', match);
      }

      final path = variable.split(keySeparator);
      final value = evaluate(path, variables);
      final formatted = formatter.format(value, formats, locale, options) ??
          (throw InterpolationException(
              'Could not evaluate or format variable', match));
      return helper.escape(formatted);
    }),
  );
}

class _InterpolationHelper {
  _InterpolationHelper(this.pattern, this.escape);

  final RegExp pattern;
  final EscapeHandler escape;
}

/// Replaces occurrences of nested key-values in [string] for other
/// key-values. Essentially calls [I18Next.translate] with the nested value.
///
/// E.g.:
/// ```json
/// {
///   key1: "Hello $t(key2)!"
///   key2: "World"
/// }
/// i18Next.t('key1') // "Hello World!"
/// ```
String nest(
  Locale locale,
  String string,
  Translate translate,
  Map<String, dynamic> variables,
  I18NextOptions options,
) {
  final pattern = nestingPattern(options);
  return string.splitMapJoin(pattern, onMatch: (match) {
    match = match as RegExpMatch;
    final key = match.namedGroup('key');
    if (key == null || key.isEmpty) {
      throw NestingException('Key not found', match);
    }

    var newVariables = variables;
    final varsString = match.namedGroup('variables');
    if (varsString != null && varsString.isNotEmpty) {
      final Map<String, dynamic> decoded = jsonDecode(varsString);
      newVariables = Map<String, dynamic>.of(variables)..addAll(decoded);
    }

    final value = translate(key, locale, newVariables, options);
    if (value == null) {
      throw NestingException('Translation not found', match);
    }
    return value;
  });
}

RegExp interpolationPattern(I18NextOptions options) {
  final prefix = RegExp.escape(options.interpolationPrefix ?? '{{');
  final suffix = RegExp.escape(options.interpolationSuffix ?? '}}');
  return RegExp('$prefix(.*?)$suffix', dotAll: true);
}

RegExp interpolationUnescapePattern(I18NextOptions options) {
  final prefix = RegExp.escape(options.interpolationPrefix ?? '{{');
  final suffix = RegExp.escape(options.interpolationSuffix ?? '}}');
  final unescapePrefix = RegExp.escape(
    options.interpolationUnescapePrefix ?? '-',
  );
  final unescapeSuffix = RegExp.escape(
    options.interpolationUnescapeSuffix ?? '',
  );
  return RegExp(
    '$prefix$unescapePrefix(.+?)$unescapeSuffix$suffix',
    dotAll: true,
  );
}

RegExp nestingPattern(I18NextOptions options) {
  final prefix = RegExp.escape(options.nestingPrefix ?? r'$t(');
  final suffix = RegExp.escape(options.nestingSuffix ?? ')');
  final separator = RegExp.escape(options.nestingSeparator ?? ',');
  return RegExp(
    '$prefix'
    '(?<key>.*?)'
    '($separator\\s*(?<variables>.*?)\\s*)?'
    '$suffix',
  );
}

String escape(String input) {
  const entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '/': '&#x2F;',
  };

  final pattern = RegExp('[&<>"\'\\/]');
  return input.replaceAllMapped(pattern, (match) {
    final char = match[0]!;
    return entityMap[char] ?? char;
  });
}
