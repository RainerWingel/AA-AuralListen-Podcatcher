import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:aapodcastguru/core/app_language.dart';
import 'package:aapodcastguru/core/formatting.dart';
import 'package:aapodcastguru/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Message keys of an ARB file in file order, duplicates included (a JSON
/// decoder would silently keep only the last of two equal keys).
List<String> _messageKeys(File file) => RegExp(
  r'^  "([^"@][^"]*)":',
  multiLine: true,
).allMatches(file.readAsStringSync()).map((m) => m.group(1)!).toList();

void main() {
  test('all ARB files have the same number and names of messages', () {
    final files =
        Directory('lib/l10n')
            .listSync()
            .whereType<File>()
            .where((f) => RegExp(r'app_\w+\.arb$').hasMatch(f.path))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    expect(files.length, greaterThanOrEqualTo(2));

    final template = File('lib/l10n/app_de.arb');
    final expected = _messageKeys(template);
    // The regex must agree with a real JSON parser on the template.
    final decoded = (jsonDecode(template.readAsStringSync()) as Map).keys.where(
      (k) => !(k as String).startsWith('@'),
    );
    expect(expected.toSet(), decoded.toSet());

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      final keys = _messageKeys(file);
      final duplicates = [
        for (final (i, k) in keys.indexed)
          if (keys.indexOf(k) != i) k,
      ];
      final missing = expected.toSet().difference(keys.toSet());
      final extra = keys.toSet().difference(expected.toSet());
      final context = '$name vs. app_de.arb';
      expect(duplicates, isEmpty, reason: '$context: duplicate keys');
      expect(missing, isEmpty, reason: '$context: missing keys');
      expect(extra, isEmpty, reason: '$context: keys not in the template');
      expect(keys.length, expected.length, reason: '$context: key count');
    }
  });

  test('every app language is supported by the generated localizations', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      unorderedEquals(AppLanguage.values.map((l) => l.name)),
    );
  });

  test('every language has its own chart country', () {
    expect(AppLanguage.values.map((l) => l.chartCountry), ['de', 'us', 'fr']);
  });

  test('stored setting and device default', () {
    expect(AppLanguage.fromSetting('en'), AppLanguage.en);
    expect(AppLanguage.fromSetting(null), isNull);
    expect(AppLanguage.fromSetting('fr'), AppLanguage.fr);
    expect(AppLanguage.fromSetting('it'), isNull);
    expect(AppLanguage.forDevice(const Locale('de', 'AT')), AppLanguage.de);
    expect(AppLanguage.forDevice(const Locale('fr', 'CA')), AppLanguage.fr);
    expect(AppLanguage.forDevice(const Locale('it')), AppLanguage.en);
    expect(AppLanguage.forDevice(null), AppLanguage.en);
  });

  test('sizes use the decimal separator of the language', () {
    const size = 1288490189; // 1.2 GiB
    expect(formatBytes(size, 'de'), '1,2 GB');
    expect(formatBytes(size, 'en'), '1.2 GB');
    expect(formatBytes(size, 'fr'), '1,2 Go');
    expect(formatBytes(350 * 1024 * 1024, 'fr'), '350 Mo');
  });

  test('list dates use the short month name', () async {
    await initializeDateFormatting();
    final now = DateTime(2026, 9, 29);
    String date(String locale, DateTime d) =>
        formatEpisodeDate(d, now: now, locale: locale);
    expect(date('en', DateTime(2026, 3, 15)), 'Mar 15');
    expect(date('en', DateTime(2026, 2, 27)), 'Feb 27');
    expect(date('en', DateTime(2025, 9, 26)), 'Sep 26, 2025');
    expect(date('de', DateTime(2026, 2, 27)), '27. Feb.');
    expect(date('de', DateTime(2026, 3, 15)), '15. März');
    expect(date('de', DateTime(2025, 9, 26)), '26. Sept. 2025');
    expect(date('fr', DateTime(2026, 3, 15)), '15 mars');
  });
}
