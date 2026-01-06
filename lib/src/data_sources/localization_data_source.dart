import 'dart:ui';

abstract class LocalizationDataSource {
  Future<Map<Locale, Map<String, dynamic>>> load(List<Locale> locales);
}
