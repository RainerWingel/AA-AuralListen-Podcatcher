/// Lenient parsers for the date and duration formats found in real podcast feeds.
library;

const Map<String, int> _months = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

/// Offsets of the named zones allowed by RFC 822, in hours.
const Map<String, int> _zones = {
  'UT': 0,
  'UTC': 0,
  'GMT': 0,
  'Z': 0,
  'EST': -5,
  'EDT': -4,
  'CST': -6,
  'CDT': -5,
  'MST': -7,
  'MDT': -6,
  'PST': -8,
  'PDT': -7,
  'CET': 1,
  'CEST': 2,
  'MEZ': 1,
  'MESZ': 2,
};

final RegExp _rfc822 = RegExp(
  r'^(?:[A-Za-z]+,?\s+)?(\d{1,2})\s+([A-Za-z]{3})[A-Za-z]*\.?\s+(\d{2,4})'
  r'\s+(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([+-]\d{2}:?\d{2}|[A-Za-z]+)?',
);

/// Parses an RSS `pubDate` (RFC 822, with common deviations) or an ISO 8601 date.
/// Returns UTC, or null if the value cannot be understood.
DateTime? parseFeedDate(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  final m = _rfc822.firstMatch(value);
  if (m != null) {
    final month = _months[m[2]!.toLowerCase()];
    if (month == null) return null;
    var year = int.parse(m[3]!);
    if (year < 100) year += year < 70 ? 2000 : 1900;
    final utc = DateTime.utc(
      year,
      month,
      int.parse(m[1]!),
      int.parse(m[4]!),
      int.parse(m[5]!),
      int.parse(m[6] ?? '0'),
    );
    return utc.subtract(_zoneOffset(m[7]));
  }
  return DateTime.tryParse(value)?.toUtc();
}

Duration _zoneOffset(String? zone) {
  if (zone == null) return Duration.zero;
  if (zone.startsWith('+') || zone.startsWith('-')) {
    final digits = zone.replaceAll(':', '');
    final sign = digits.startsWith('-') ? -1 : 1;
    final hours = int.parse(digits.substring(1, 3));
    final minutes = int.parse(digits.substring(3, 5));
    return Duration(minutes: sign * (hours * 60 + minutes));
  }
  return Duration(hours: _zones[zone.toUpperCase()] ?? 0);
}

/// Podlove chapter time: "01:02:03.500", "02:03", "3.5" (seconds).
Duration? parseChapterTime(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  final parts = value.split(':');
  if (parts.length > 3) return null;
  var ms = 0.0;
  for (final part in parts) {
    final n = double.tryParse(part);
    if (n == null || n < 0) return null;
    ms = ms * 60 + n;
  }
  return Duration(milliseconds: (ms * 1000).round());
}

/// Parses `itunes:duration`: "3600", "3600.5", "59:30" or "1:02:03".
Duration? parseFeedDuration(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;

  if (!value.contains(':')) {
    final seconds = double.tryParse(value);
    return seconds == null || seconds <= 0
        ? null
        : Duration(milliseconds: (seconds * 1000).round());
  }

  final parts = value.split(':').map((p) => int.tryParse(p.trim())).toList();
  if (parts.length > 3 || parts.any((p) => p == null)) return null;
  var seconds = 0;
  for (final part in parts) {
    seconds = seconds * 60 + part!;
  }
  return seconds <= 0 ? null : Duration(seconds: seconds);
}
