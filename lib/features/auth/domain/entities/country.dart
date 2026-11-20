import 'package:flutter/foundation.dart';

@immutable
class Country {
  const Country({required this.code, required this.name});

  /// ISO 3166-1 alpha-2 code, e.g. `IN`. The four UK nations use the ISO
  /// 3166-2 style codes `GB-ENG`, `GB-SCT`, `GB-WLS` and `GB-NIR`
  /// (plain `SC` / `NI` are Seychelles / Nicaragua).
  final String code;
  final String name;

  /// Flag emoji for [code]; empty when the code has no flag.
  String get flag => Country.flagOf(code);

  /// Flag emoji for any country code (null / unknown -> empty string).
  static String flagOf(String? code) {
    if (code == null) return '';
    final c = code.trim().toUpperCase();
    final special = _nations[c];
    if (special != null) return special;
    if (c.length != 2) return '';
    return String.fromCharCodes(c.codeUnits.map((u) => 0x1F1E6 + u - 0x41));
  }

  // England / Scotland / Wales have their own flag emoji (tag sequences).
  // Northern Ireland has no official emoji: it uses the UK flag.
  static const Map<String, String> _nations = <String, String>{
    'GB-ENG': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0065}\u{E006E}\u{E0067}\u{E007F}',
    'GB-SCT': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0073}\u{E0063}\u{E0074}\u{E007F}',
    'GB-WLS': '\u{1F3F4}\u{E0067}\u{E0062}\u{E0077}\u{E006C}\u{E0073}\u{E007F}',
    'GB-NIR': '\u{1F1EC}\u{1F1E7}',
  };

  @override
  bool operator ==(Object other) => other is Country && other.code == code;

  @override
  int get hashCode => code.hashCode;
}
