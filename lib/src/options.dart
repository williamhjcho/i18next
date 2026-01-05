import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'interpolation_format.dart';

// ignore_for_file: lines_longer_than_80_chars

/// The formatter signature for [I18NextOptions.formats].
///
/// The [value] can be null if the variable wasn't evaluated properly, giving a
/// chance for the formatter to do something
typedef ValueFormatter =
    Object? Function(
      Object? value,
      InterpolationFormat format,
      Locale locale,
      I18NextOptions options,
    );

typedef MissingKeyHandler =
    String? Function(
      Locale locale,
      String key,
      Map<String, dynamic> variables,
      I18NextOptions options,
    );

typedef TranslationFailedHandler =
    String Function(
      Locale locale,
      String namespace,
      String key,
      Map<String, dynamic> variables,
      I18NextOptions options,
      Object error,
    );

typedef EscapeHandler = String Function(String input);

/// Contains all options for [I18Next] to work properly.
class I18NextOptions with Diagnosticable {
  const I18NextOptions({
    this.fallbackNamespaces,
    this.fallbackLanguages,
    this.namespaceSeparator,
    this.contextSeparator,
    this.pluralSeparator,
    this.keySeparator,
    this.interpolationPrefix,
    this.interpolationSuffix,
    this.formatSeparator,
    this.interpolationUnescapePrefix,
    this.interpolationUnescapeSuffix,
    this.formatterValues,
    this.formats,
    this.optionsSeparator,
    this.optionValueSeparator,
    this.nestingPrefix,
    this.nestingSuffix,
    this.nestingSeparator,
    this.pluralSuffix,
    this.missingKeyHandler,
    this.missingInterpolationHandler,
    this.translationFailedHandler,
    this.escape,
    this.escapeValue,
  }) : super();

  static const I18NextOptions base = I18NextOptions(
    fallbackNamespaces: null,
    fallbackLanguages: null,
    namespaceSeparator: ':',
    contextSeparator: '_',
    pluralSeparator: '_',
    keySeparator: '.',
    interpolationPrefix: '{{',
    interpolationSuffix: '}}',
    interpolationUnescapePrefix: '-',
    interpolationUnescapeSuffix: '',
    formatSeparator: ',',
    formatterValues: {'true': true, 'false': false},
    formats: {},
    optionsSeparator: ';',
    optionValueSeparator: ':',
    nestingPrefix: r'$t(',
    nestingSuffix: ')',
    nestingSeparator: ',',
    pluralSuffix: 'plural',
    missingKeyHandler: null,
    missingInterpolationHandler: null,
    translationFailedHandler: null,
    escape: null,
    escapeValue: true,
  );

  /// The namespaces used to fallback to when no key matches were found on the
  /// current namespace.
  /// These namespaces are evaluated in the order they are put in the list.
  ///
  /// Defaults to null.
  final List<String>? fallbackNamespaces;

  /// The languages that will be used to fallback when no key matches were found
  /// in the current language.
  /// These languages are evaluated in the order they are put in the list.
  ///
  /// [fallbackNamespaces] will take priority over language.
  /// [missingKeyHandler] is called only after all languages have been evaluated.
  ///
  /// The fallback languages must be loaded with the primary language.
  ///
  /// Defaults to null.
  final List<Locale>? fallbackLanguages;

  /// The separator used when splitting the key.
  ///
  /// Defaults to ':'.
  final String? namespaceSeparator;

  /// The separator for contexts, it is inserted between the key and the
  /// context value.
  ///
  /// Defaults to '_'.
  final String? contextSeparator;

  /// The separator for plural suffixes, it is inserted between the key and the
  /// plural value ("plural" for simple rules, or a numeric index for complex
  /// rules with multiple plurals).
  ///
  /// Defaults to '_'.
  final String? pluralSeparator;

  /// The separator for nested keys. It is used to denote multiple object
  /// levels of access when retrieving a key from a namespace.
  ///
  /// Defaults to '.'.
  final String? keySeparator;

  /// [pluralSuffix] is used for the pluralization mechanism.
  ///
  /// Defaults to 'plural' and is used for simple pluralization rules.
  ///
  /// For example, in english where it only has singular or plural forms:
  ///
  /// ```
  /// "friend": "A friend"
  /// "friend_plural": "{{count}} friends"
  /// ```
  final String? pluralSuffix;

  /// [interpolationPrefix] and [interpolationSuffix] are the deliminators
  /// for the variable interpolation and formatting mechanism.
  /// By default they are '{{' and '}}' respectively and can't be null but
  /// can be empty.
  ///
  /// [formatSeparator] is used to separate the variable's
  /// name from the format (if any). Defaults to ',' and cannot be null nor
  /// empty (otherwise it'll match every char in the interpolation).
  ///
  /// - '{{title}}'
  /// - '{{some.variable.name}}'
  /// - '{{some.variable.name, format1, format2}}'
  /// - '{{some.variable.name, format(option: value)}}'
  final String? interpolationPrefix, interpolationSuffix, formatSeparator;

  /// [interpolationUnescapePrefix] and [interpolationUnescapeSuffix] are used
  /// to denote that a specific interpolation is not supposed to be [escape]d.
  ///
  /// By default they are used with a prefix:
  /// - '{{-variable}}'
  /// - '{{-some.variable.name, format1, format2}}'
  final String? interpolationUnescapePrefix, interpolationUnescapeSuffix;

  /// [formats] is called when an interpolation has been found and it was marked
  /// with formatting options.
  ///
  /// If the format doesn't exist then it either moves to the next format or
  /// the value is returned as is (in string form: [Object.toString]).
  final Map<String, ValueFormatter>? formats;

  /// Helper that maps known or common [formats] values to a specific value.
  ///
  /// e.g.:
  /// `{{formatName(option: true)}}`
  /// Maps the "true" string to a bool value while parsing.
  final Map<String, Object>? formatterValues;

  /// Options are delimited for the [formats], and are defined
  /// between '(' and ')'.
  ///
  /// [optionsSeparator] separates all the available options between the
  /// prefix and suffix, while the [optionValueSeparator] separates the key
  /// values for each option.
  ///
  /// "Some format {{value, formatName(optionName: optionValue)}}",
  /// "Some format {{value, formatName(option1Name: option1Value; option2Name: option2Value)}}"
  final String? optionsSeparator, optionValueSeparator;

  /// [nestingPrefix] and [nestingSuffix] are the deliminators for nesting
  /// mechanism. By default they are '$t(' and ')' respectively and can't be
  /// null but can be empty.
  ///
  /// [nestingSeparator] is used to separate the key's name from the variables
  /// (if any) which must be JSON. Defaults to ',' and cannot be null nor empty
  /// (otherwise it'll match every char in the nesting).
  ///
  /// ```json
  /// {
  ///   key1: "Hello $t(key2)!"
  ///   key2: "World"
  /// }
  /// i18Next.t('key1') // "Hello World!"
  /// ```
  final String? nestingPrefix, nestingSuffix, nestingSeparator;

  /// The default behavior is to just return the key itself that was used in
  /// [I18Next.t].
  final MissingKeyHandler? missingKeyHandler;

  /// Called when the interpolation format in [formats] is not found, or when
  /// the value being interpolated is not a [String].
  ///
  /// The default behavior just returns the value itself (which will fallback
  /// into a [Object.toString] call.
  final ValueFormatter? missingInterpolationHandler;

  /// A callback that is used when the translation failed while being evaluated
  /// (e.g. interpolation, nesting).
  ///
  /// If the key was missing, then it will call [missingKeyHandler] instead.
  final TranslationFailedHandler? translationFailedHandler;

  /// The escape handler that is called after interpolating and formatting a
  /// variable only if [escapeValue] is enabled.
  ///
  /// By default will escape XML tags.
  final EscapeHandler? escape;

  /// Whether to call [escape] after interpolating and formatting a variable.
  ///
  /// Default is true.
  final bool? escapeValue;

  /// Creates a new instance of [I18NextOptions] overriding any properties
  /// where [other] isn't null.
  ///
  /// If [other] is null, returns this.
  I18NextOptions merge(I18NextOptions? other) {
    if (other == null) return this;
    return copyWith(
      fallbackNamespaces: other.fallbackNamespaces ?? fallbackNamespaces,
      fallbackLanguages: other.fallbackLanguages ?? fallbackLanguages,
      namespaceSeparator: other.namespaceSeparator ?? namespaceSeparator,
      contextSeparator: other.contextSeparator ?? contextSeparator,
      pluralSeparator: other.pluralSeparator ?? pluralSeparator,
      keySeparator: other.keySeparator ?? keySeparator,
      pluralSuffix: other.pluralSuffix ?? pluralSuffix,
      interpolationPrefix: other.interpolationPrefix ?? interpolationPrefix,
      interpolationSuffix: other.interpolationSuffix ?? interpolationSuffix,
      formatSeparator: other.formatSeparator ?? formatSeparator,
      interpolationUnescapePrefix:
          other.interpolationUnescapePrefix ?? interpolationUnescapePrefix,
      interpolationUnescapeSuffix:
          other.interpolationUnescapeSuffix ?? interpolationUnescapeSuffix,
      formatterValues: other.formatterValues ?? formatterValues,
      formats: formats == null
          ? other.formats
          : other.formats == null
          ? formats
          : {...?formats, ...?other.formats},
      optionsSeparator: other.optionsSeparator ?? optionsSeparator,
      optionValueSeparator: other.optionValueSeparator ?? optionValueSeparator,
      nestingPrefix: other.nestingPrefix ?? nestingPrefix,
      nestingSuffix: other.nestingSuffix ?? nestingSuffix,
      nestingSeparator: other.nestingSeparator ?? nestingSeparator,
      missingKeyHandler: other.missingKeyHandler ?? missingKeyHandler,
      missingInterpolationHandler:
          other.missingInterpolationHandler ?? missingInterpolationHandler,
      translationFailedHandler:
          other.translationFailedHandler ?? translationFailedHandler,
      escape: other.escape ?? escape,
      escapeValue: other.escapeValue ?? escapeValue,
    );
  }

  /// Creates a new instance of [I18NextOptions] overriding any of the
  /// properties that aren't null.
  I18NextOptions copyWith({
    List<String>? fallbackNamespaces,
    List<Locale>? fallbackLanguages,
    String? namespaceSeparator,
    String? contextSeparator,
    String? pluralSeparator,
    String? keySeparator,
    String? pluralSuffix,
    String? interpolationPrefix,
    String? interpolationSuffix,
    String? formatSeparator,
    String? interpolationUnescapePrefix,
    String? interpolationUnescapeSuffix,
    Map<String, Object>? formatterValues,
    Map<String, ValueFormatter>? formats,
    String? optionsSeparator,
    String? optionValueSeparator,
    String? nestingPrefix,
    String? nestingSuffix,
    String? nestingSeparator,
    MissingKeyHandler? missingKeyHandler,
    ValueFormatter? missingInterpolationHandler,
    TranslationFailedHandler? translationFailedHandler,
    EscapeHandler? escape,
    bool? escapeValue,
  }) {
    return I18NextOptions(
      fallbackNamespaces: fallbackNamespaces ?? this.fallbackNamespaces,
      fallbackLanguages: fallbackLanguages ?? this.fallbackLanguages,
      namespaceSeparator: namespaceSeparator ?? this.namespaceSeparator,
      contextSeparator: contextSeparator ?? this.contextSeparator,
      pluralSeparator: pluralSeparator ?? this.pluralSeparator,
      keySeparator: keySeparator ?? this.keySeparator,
      pluralSuffix: pluralSuffix ?? this.pluralSuffix,
      interpolationPrefix: interpolationPrefix ?? this.interpolationPrefix,
      interpolationSuffix: interpolationSuffix ?? this.interpolationSuffix,
      formatSeparator: formatSeparator ?? this.formatSeparator,
      interpolationUnescapePrefix:
          interpolationUnescapePrefix ?? this.interpolationUnescapePrefix,
      interpolationUnescapeSuffix:
          interpolationUnescapeSuffix ?? this.interpolationUnescapeSuffix,
      formatterValues: formatterValues ?? this.formatterValues,
      formats: formats ?? this.formats,
      optionsSeparator: optionsSeparator ?? this.optionsSeparator,
      optionValueSeparator: optionValueSeparator ?? this.optionValueSeparator,
      nestingPrefix: nestingPrefix ?? this.nestingPrefix,
      nestingSuffix: nestingSuffix ?? this.nestingSuffix,
      nestingSeparator: nestingSeparator ?? this.nestingSeparator,
      missingKeyHandler: missingKeyHandler ?? this.missingKeyHandler,
      missingInterpolationHandler:
          missingInterpolationHandler ?? this.missingInterpolationHandler,
      translationFailedHandler:
          translationFailedHandler ?? this.translationFailedHandler,
      escape: escape ?? this.escape,
      escapeValue: escapeValue ?? this.escapeValue,
    );
  }

  @override
  int get hashCode => Object.hashAll([
    fallbackNamespaces,
    fallbackLanguages,
    namespaceSeparator,
    contextSeparator,
    pluralSeparator,
    keySeparator,
    interpolationPrefix,
    interpolationSuffix,
    formatSeparator,
    interpolationUnescapePrefix,
    interpolationUnescapeSuffix,
    formatterValues,
    formats,
    optionsSeparator,
    optionValueSeparator,
    nestingPrefix,
    nestingSuffix,
    nestingSeparator,
    pluralSuffix,
    missingKeyHandler,
    missingInterpolationHandler,
    translationFailedHandler,
    escape,
    escapeValue,
  ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other.runtimeType == runtimeType &&
        other is I18NextOptions &&
        other.fallbackNamespaces == fallbackNamespaces &&
        other.fallbackLanguages == fallbackLanguages &&
        other.namespaceSeparator == namespaceSeparator &&
        other.contextSeparator == contextSeparator &&
        other.pluralSeparator == pluralSeparator &&
        other.keySeparator == keySeparator &&
        other.interpolationPrefix == interpolationPrefix &&
        other.interpolationSuffix == interpolationSuffix &&
        other.formatSeparator == formatSeparator &&
        other.formatterValues == formatterValues &&
        const MapEquality().equals(other.formats, formats) &&
        other.optionsSeparator == optionsSeparator &&
        other.optionValueSeparator == optionValueSeparator &&
        other.nestingPrefix == nestingPrefix &&
        other.nestingSuffix == nestingSuffix &&
        other.nestingSeparator == nestingSeparator &&
        other.pluralSuffix == pluralSuffix &&
        other.missingKeyHandler == missingKeyHandler &&
        other.missingInterpolationHandler == missingInterpolationHandler &&
        other.translationFailedHandler == translationFailedHandler &&
        other.escape == escape &&
        other.escapeValue == escapeValue;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty('fallbackNamespaces', fallbackNamespaces))
      ..add(IterableProperty('fallbackLanguages', fallbackLanguages))
      ..add(StringProperty('namespaceSeparator', namespaceSeparator))
      ..add(StringProperty('contextSeparator', contextSeparator))
      ..add(StringProperty('pluralSeparator', pluralSeparator))
      ..add(StringProperty('keySeparator', keySeparator))
      ..add(StringProperty('interpolationPrefix', interpolationPrefix))
      ..add(StringProperty('interpolationSuffix', interpolationSuffix))
      ..add(StringProperty('formatSeparator', formatSeparator))
      ..add(StringProperty('formatterValues', formatterValues?.toString()))
      ..add(StringProperty('formats', formats?.toString()))
      ..add(StringProperty('optionsSeparator', optionsSeparator))
      ..add(StringProperty('optionValueSeparator', optionValueSeparator))
      ..add(StringProperty('nestingPrefix', nestingPrefix))
      ..add(StringProperty('nestingSuffix', nestingSuffix))
      ..add(StringProperty('nestingSeparator', nestingSeparator))
      ..add(StringProperty('pluralSuffix', pluralSuffix))
      ..add(StringProperty('missingKeyHandler', missingKeyHandler?.toString()))
      ..add(
        StringProperty(
          'missingInterpolationHandler',
          missingInterpolationHandler?.toString(),
        ),
      )
      ..add(
        StringProperty(
          'translationFailedHandler',
          translationFailedHandler?.toString(),
        ),
      )
      ..add(StringProperty('escape', escape?.toString()))
      ..add(StringProperty('escapeValue', escapeValue?.toString()));
  }
}
