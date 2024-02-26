# [0.7.3]

- Don't schedule an extra microtask when loading a synchronous data source contents in `I18NextLocalizationDelegate`.
  - [Issue #19](https://github.com/williamhjcho/i18next/issues/19) - thanks @wbusey0!

# [0.7.2]

- Updates sdk constraints to `>=2.18.0`
  - required by flutter_lints
- Updates build workflow

# [0.7.1]

- Updates sdk constraints to `>=2.14.0`

# [0.7.0]

- Adds `getNamespace(Locale locale, String namespace)` in `ResourceStore` to retrieve a whole namespace set (if it exists)
  - [Issue #17](https://github.com/williamhjcho/i18next/issues/17) - thanks @Ahmadre!
- Fixes deprecation issues on example app
- Updates analysis_options with flutter_lints recommended rules

# [0.6.1]

- Adds `orElse` argument to `t()` to provide a fallback value or throw an exception when the translation cannot be found
- Adds `tOrNull` function that returns null if the translation cannot be found

# [0.6.0]

- Promote 0.6.0-dev+4 to 0.6.0 (stable)

# [0.6.0-dev+4]

- Fix `context` and `count` cast when they are inserted by variables
  - They will now just be ignored and used for interpolation (if any)

# [0.6.0-dev+3]

- Adds `I18NextOptions.interpolationUnescapePrefix|interpolationUnescapeSuffix`
  - They can be used within your localization files to denote an unescaped interpolation like so:
    - `Some text {{-myVariable}}`
    - `Some text {{-some.variable, format1, format2}}`

# [0.6.0-dev+2]

- Adds variable (XML) escaping by default
  - To override this behavior, set `I18NextOptions.escape`
  - Or to disable it, set `I18NextOptions.escapeValue = false`

# [0.6.0-dev+1]

- Fix `missingInterpolationHandler` to also be called for interpolations that do not result into String (and are not null)
  e.g. `{{someVar}}` with no formats

# [0.6.0-dev]

- Adds `AssetBundleLocalizationDataSource.cache` property (default is still true)
- Adds name arguments to the typedefs
- Refactors: `interpolation` and `nesting` methods with dedicated `Exceptions` while running `splitMapJoin`
  - The final result is still the same, if either interpolation or nesting fails, the translator will fallback to null,
    which in turn is converted back into the original key.
  - Also, json deserialization issues on `nesting` now fail, rather than silently recovering
- Fixes immediate key recursion after nesting
- Moves `I18NextOptions.defaultFormatter` as an internal `interpolator.dart` method.
- Adds `MissingKeyHandler` and `TranslationFailedHandler` on `I18NextOptions` to allow custom handling if needed
  (default behavior is to return the key itself).
- Refactors formatters **BREAKING CHANGE**:
  - Now the formatters are registered by name rather than just by a single function:

    ```dart
    I18NextOptions(formats: {
      'uppercase': (variable, variableOptions, locale, options) => variable?.toUpperCase(),
      'lowercase': (variable, variableOptions, locale, options) => variable?.toUpperCase(),
      // (...)
    });
    ```

    The callback of the formatter may receive and return a null value so the next formats may have a chance to handle it
    before returning to the interpolation call. Which if it is still null, will be considered a translation error, resulting
    in the original key being returned.

    ```
    "key": "Hello {{name, uppercase}}!" // "Hello WORLD!"

    // multiple formatters in sequence
    "key": "Hello {{name, fmt1, fmt2, fmt3}}!"
    ```

    And they also accept options if the format needs them:

    ```json
    {
      "key": "Some format {{value, formatName}}",
      "keyWithOptions": "Some format {{value, formatName(option1Name: option1Value; option2Name: option2Value)}}"
    }
    ```

  - Also adds a `I18NextOptions.missingInterpolationHandler` that can also be used as the previous implementation,
    to avoid a full migration if needed.

## [0.5.2]

- Fix: Unnecessary reloads of the localizationDataSource

## [0.5.1]

- Fix: Asset path (rely on Flutter asset specifications)

## [0.5.0]

- Adds support for multiple fallback namespaces

## [0.4.1]

- Officializes the null-safety migration

## [0.4.0-nullsafety.0]

- Migrates the codebase to flutter stable 2.0.3 + null-safety
  Renames `I18NextOptions.apply -> merge`

## [0.3.1]

- Renames `utils.dart -> definitions.dart`
- Adds and moves `evaluate` to `lib/utils.dart` as a part of the package, but without explicitly exporting it.
- Allows interpolations to access grouped variables like so:
  `'An example with {{grouped.key}}' + {'grouped': {'key': 'grouped keys'}} = 'An example with grouped keys'`
- Moves `lib/src/interpolator.dart` to `lib/interpolator.dart`
  To allow the interpolator usage as a separate package import

## [0.3.0]

- Bumps to flutter stable 1.20

## [0.2.0]

- Updates README bitrise badge
- Adds pluralization to non-english locales (Fixes #6) @lynn

## [0.1.0]

- Bumps to match flutter version 1.17

## [0.0.1+8]

- Bumps analysis options #9
- Adds fallback namespace #10
- Refactors Translator to a callable class #10
- Refactors interpolator class to global pure functions #10

## [0.0.1+7]

- Change the namespaces type from `Map<String, Map<String, Object>> -> Map<String, Object>`
- Adds I18Next.of(BuildContext) from Localizations
- Adds `I18NextLocalizationDelegate`
- Adds convenience methods to `ResourceStore` for adding, removing, and verifiying locales and namespaces
- Adds asset bundle data source and the LocalizationDataSource interface
- Changes links to nubank/i18next
- Adds example app

## [0.0.1+6]

- Migrated repository to `williamhjcho/i18next`
- Reduce description size

## [0.0.1+5]

- Adds plural separator in I18NextOptions
- Adds key separator in I18NextOptions
- Adds and replaces LocalizationDataSource for ResourceStore
- Makes `I18Next.t`'s parameters supersede the options parameter
- Removes `Map` extension from `I18NextOptions`
- Makes `I18NextOptions` `Diagnosticable`
- Improves and adds more cases on `Interpolator`

## [0.0.1+4]

- Renames arguments to variables
- Replaces InterpolationOptions for I18NextOptions
- Updates I18Next inner workings to more contextualized methods.
- Escapes interpolation strings in options for RegExp
- Adds base nesting mechanism
- Isolates Translator, PluralResolver, and Interpolator into separate classes
- Makes I18NextOptions's properties optional and allows individual overrides
- Makes I18NextOption conform to Map<String, Object>
- Reduces API surface by merging most of the optional properties into I18NextOptions itself
- Moves pattern builders from options to the classes themselves
- Keeps property variables in I18NextOptions while keeping Map extension.
- Adds/merges locale property in I18NextOptions

## [0.0.1+3]

- Adds InterpolationOption
- Allows locale and interpolation options override on `t`
- Adds a little more documentation

Internal:

- Splits data fetching and translation into separate methods

## [0.0.1] - TODO: Add release date

- TODO: Describe initial release.
