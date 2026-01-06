import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'localization_data_source.dart';

/// A [LocalizationDataSource] that retrieves assets from an [AssetBundle].
class AssetBundleLocalizationDataSource implements LocalizationDataSource {
  AssetBundleLocalizationDataSource({
    required this.bundlePath,
    AssetBundle? bundle,
    this.cache = true,
  }) : bundle = bundle ?? rootBundle;

  /// The path prefixed to the asset when retrieving from the [bundle].
  ///
  /// e.g. `l10n` if your assets are located in `l10n/en-US/feature.json`.
  final String bundlePath;

  /// The [AssetBundle] where it retrieves the assets from.
  ///
  /// Defaults to [rootBundle].
  final AssetBundle bundle;

  /// Whether to cache the loaded assets from the [bundle].
  ///
  /// Defaults to `true`.
  final bool cache;

  /// Loads all '.json' localization files declared in the bundle's asset
  /// manfiest with [bundlePath] given the [locales].
  /// The assets themselves must have been previously declared in `pubspec.yaml`.
  ///
  /// For example, if your project structure is as follows:
  ///
  /// ```
  /// /app/
  ///   - l10n/
  ///     - en-US/
  ///         - common.json
  ///         - feature_a.json
  ///     - pt-BR/
  ///         - common.json
  ///         - feature_a.json
  /// ```
  ///
  /// Then the desired [bundlePath] should be `l10n`.
  ///
  /// The end result is a [Map] that contains all the namespaces which are
  /// the file names themselves (case sensitive).
  @override
  Future<Map<Locale, Map<String, dynamic>>> load(List<Locale> locales) async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(bundle);
    final assetFiles = assetManifest
        .listAssets()
        .where((key) => path.extension(key) == '.json')
        .toList();

    final loadedLocales = <Locale, Map<String, dynamic>>{};
    await Future.wait(
      locales.map((locale) async {
        /// On every platform you never should try to get the `path.separator`,
        /// because Flutter is fetching all assets in `/` style.
        /// `path.separator` should only be used to handle OS files.
        final assetPath = '$bundlePath/${locale.toLanguageTag()}';
        final localeAssetFiles = assetFiles.where((f) => f.contains(assetPath));
        final namespaces = await loadFromFiles(localeAssetFiles);
        loadedLocales[locale] = namespaces;
      }),
    );
    return loadedLocales;
  }

  Future<Map<String, dynamic>> loadFromFiles(Iterable<String> files) async {
    final namespaces = HashMap<String, dynamic>();
    await Future.wait(
      files.map((file) async {
        final namespace = path.basenameWithoutExtension(file);
        final string = await bundle.loadString(file, cache: cache);
        namespaces[namespace] = jsonDecode(string);
      }),
    );
    return namespaces;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetBundleLocalizationDataSource &&
          runtimeType == other.runtimeType &&
          bundlePath == other.bundlePath &&
          cache == other.cache &&
          bundle == other.bundle;

  @override
  int get hashCode => Object.hash(bundlePath, bundle, cache);
}
