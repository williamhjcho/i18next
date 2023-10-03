import 'package:collection/collection.dart';

// ignore_for_file: lines_longer_than_80_chars

/// A parsed format from a string.
///
/// e.g.
/// `formatName` = name='formatName' options=empty
/// `formatName()` = name='formatName' options=empty
/// `formatName(op1: true; op2: some text)` = name='formatName' options={'op1': true, op2:'some text'}
class InterpolationFormat {
  const InterpolationFormat(this.name, this.options);

  /// Special interpolation case where the value was not a [String], and no
  /// other formats were found.
  static const fallback = InterpolationFormat('fallback', {});

  /// The name of the format
  final String name;

  /// The options that were associated to [name].
  final Map<String, Object> options;

  @override
  int get hashCode => Object.hash(name, options);

  @override
  bool operator ==(Object other) =>
      other is InterpolationFormat &&
      other.name == name &&
      const MapEquality().equals(other.options, options);

  @override
  String toString() => '($name, $options)';
}
