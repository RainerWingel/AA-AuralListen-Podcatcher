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
    expect(AppLanguage.values.map((l) => l.chartCountry), [
      'de',
      'us',
      'fr',
      'es',
      'br',
      'ru',
      'it',
    ]);
  });

  test('stored setting and device default', () {
    expect(AppLanguage.fromSetting('en'), AppLanguage.en);
    expect(AppLanguage.fromSetting(null), isNull);
    expect(AppLanguage.fromSetting('fr'), AppLanguage.fr);
    expect(AppLanguage.fromSetting('nl'), isNull);
    expect(AppLanguage.forDevice(const Locale('de', 'AT')), AppLanguage.de);
    expect(AppLanguage.forDevice(const Locale('fr', 'CA')), AppLanguage.fr);
    expect(AppLanguage.forDevice(const Locale('es', 'MX')), AppLanguage.es);
    expect(AppLanguage.forDevice(const Locale('pt', 'PT')), AppLanguage.pt);
    expect(AppLanguage.forDevice(const Locale('ru', 'KZ')), AppLanguage.ru);
    expect(AppLanguage.forDevice(const Locale('it', 'CH')), AppLanguage.it);
    expect(AppLanguage.forDevice(const Locale('nl')), AppLanguage.en);
    expect(AppLanguage.forDevice(null), AppLanguage.en);
  });

  test('a new language is offered only if it is new to the user', () {
    AppLanguage? offer(String device, {String? known, String current = 'en'}) =>
        AppLanguage.newlyAvailable(
          current: AppLanguage.fromSetting(current),
          device: Locale(device),
          known: known,
        );
    // Updated from 1.3.5 (nothing stored): only languages added since.
    expect(offer('ru'), AppLanguage.ru);
    expect(offer('fr'), AppLanguage.fr);
    expect(offer('de'), isNull);
    expect(offer('en', current: 'de'), isNull);
    expect(offer('ru', current: 'ru'), isNull);
    expect(offer('it'), AppLanguage.it);
    expect(offer('nl'), isNull);
    // Seen in the language list (picker, Settings or this offer).
    expect(offer('ru', known: AppLanguage.allNames), isNull);
    expect(offer('ru', known: 'de,en,fr,es,pt'), AppLanguage.ru);
  });

  test('sizes use the decimal separator of the language', () {
    const size = 1288490189; // 1.2 GiB
    expect(formatBytes(size, 'de'), '1,2 GB');
    expect(formatBytes(size, 'en'), '1.2 GB');
    expect(formatBytes(size, 'fr'), '1,2 Go');
    expect(formatBytes(350 * 1024 * 1024, 'fr'), '350 Mo');
    expect(formatBytes(size, 'es'), '1,2 GB');
    expect(formatBytes(size, 'pt'), '1,2 GB');
    expect(formatBytes(size, 'ru'), '1,2 ГБ');
    expect(formatBytes(350 * 1024 * 1024, 'ru'), '350 МБ');
  });

  test('Russian uses its three plural forms', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.episodeCount(0), 'Нет выпусков');
    expect(ru.episodeCount(1), '1 выпуск');
    expect(ru.episodeCount(2), '2 выпуска');
    expect(ru.episodeCount(5), '5 выпусков');
    expect(ru.episodeCount(11), '11 выпусков');
    expect(ru.episodeCount(21), '21 выпуск');
    expect(ru.episodeCount(22), '22 выпуска');
    expect(ru.episodeCount(25), '25 выпусков');
    expect(ru.ratingStars(5), '5 звёзд');
    expect(ru.feedsMoved(1, 'A'), '1 подкаст переехал (A) — адрес обновлён.');
    expect(ru.feedsMoved(21, 'A'), startsWith('21 подкаст переехал'));
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
