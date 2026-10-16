import 'package:flutter/foundation.dart';

@immutable
class Country {
  const Country({required this.code, required this.name});

  /// ISO 3166-1 alpha-2 code, e.g. `IN`.
  final String code;
  final String name;

  /// Flag emoji built from the ISO code (works for every country).
  String get flag => String.fromCharCodes(
    code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41),
  );

  @override
  bool operator ==(Object other) => other is Country && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
