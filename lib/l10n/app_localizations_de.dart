// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'AA-PodcastGuru';

  @override
  String get navHome => 'Start';

  @override
  String get navSubscriptions => 'Abos';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get placeholderComingSoon => 'Kommt bald';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get loadError => 'Fehler beim Laden';

  @override
  String get homeEmpty => 'Noch keine Folgen';

  @override
  String get homeEmptyHint => 'Abonniere Podcasts im Tab „Abos“.';

  @override
  String get subscriptionsEmpty => 'Noch keine Abos';

  @override
  String get subscriptionsEmptyHint =>
      'Füge deinen ersten Podcast per RSS-URL hinzu.';

  @override
  String get addFeedAction => 'Per RSS-URL hinzufügen';

  @override
  String get addFeedTitle => 'Podcast hinzufügen';

  @override
  String get addFeedLabel => 'RSS-URL';

  @override
  String get addFeedHint => 'https://beispiel.de/feed.xml';

  @override
  String get addFeedSubmit => 'Abonnieren';

  @override
  String get subscribeErrorInvalidUrl => 'Das ist keine gültige Adresse.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'Diesen Podcast hast du schon abonniert.';

  @override
  String get subscribeErrorNetwork =>
      'Der Feed konnte nicht geladen werden. Bitte Adresse und Internetverbindung prüfen.';

  @override
  String get subscribeErrorNotAFeed =>
      'Unter dieser Adresse liegt kein Podcast-Feed.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Feeds konnten nicht aktualisiert werden.',
      one: '1 Feed konnte nicht aktualisiert werden.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Podcast nicht gefunden';

  @override
  String get podcastRefreshError => 'Letzte Aktualisierung fehlgeschlagen';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Folgen',
      one: '1 Folge',
      zero: 'Keine Folgen',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'Neu';

  @override
  String get episodePlayed => 'Gespielt';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get unsubscribe => 'Abo kündigen';

  @override
  String get unsubscribeConfirmTitle => 'Abo kündigen?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '„$title“ und alle Folgen werden aus der App entfernt.';
  }
}
