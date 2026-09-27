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
  String get navSettings => 'Optionen';

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

  @override
  String get search => 'Suchen';

  @override
  String get searchHint => 'Podcast suchen';

  @override
  String get searchStart => 'Suche nach Titel, Thema oder Autor';

  @override
  String get searchStartHint => 'Durchsucht Apple Podcasts und fyyd.de';

  @override
  String get searchNoResults => 'Keine Podcasts gefunden';

  @override
  String get searchFailed =>
      'Suche fehlgeschlagen. Bitte Internetverbindung prüfen.';

  @override
  String searchPartialFailure(String names) {
    return '$names nicht erreichbar – Ergebnisse unvollständig';
  }

  @override
  String get subscribed => 'Abonniert';

  @override
  String get subscribeAction => 'Abonnieren';

  @override
  String subscribedSnack(String title) {
    return '„$title“ abonniert';
  }

  @override
  String get open => 'Öffnen';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Abos';

  @override
  String get opmlImport => 'OPML-Datei importieren';

  @override
  String get opmlImportSubtitle =>
      'Abos aus einer anderen App übernehmen (z. B. Castbox)';

  @override
  String get opmlInvalid => 'Die Datei ist keine gültige OPML-Datei.';

  @override
  String get opmlTooLarge => 'Die Datei ist zu groß.';

  @override
  String get opmlEmpty => 'In der Datei wurden keine Podcasts gefunden.';

  @override
  String get opmlConfirmTitle => 'Abos importieren?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Podcasts gefunden.',
      one: '1 Podcast gefunden.',
    );
    return '$_temp0 Bereits vorhandene Abos werden übersprungen.';
  }

  @override
  String get opmlImportAction => 'Importieren';

  @override
  String opmlProgress(int done, int total) {
    return 'Importiere $done von $total …';
  }

  @override
  String get opmlResultTitle => 'Import abgeschlossen';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'Neu: $added\nBereits vorhanden: $already\nFehlgeschlagen: $failed';
  }

  @override
  String get opmlResultFailedList => 'Nicht importiert:';

  @override
  String get playerPlay => 'Abspielen';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerRewind => '15 Sekunden zurück';

  @override
  String get playerForward => '30 Sekunden vor';

  @override
  String get playerClose => 'Player schließen';

  @override
  String get playerOpen => 'Player öffnen';

  @override
  String get nowPlaying => 'Läuft gerade';

  @override
  String get boostTitle => 'Lautstärke-Boost';

  @override
  String get boostOff => 'Aus';

  @override
  String boostValue(int db) {
    return '+$db dB';
  }

  @override
  String boostButton(String value) {
    return 'Boost: $value';
  }

  @override
  String get boostPerPodcast => 'Nur für diesen Podcast';

  @override
  String get boostPerPodcastHint =>
      'Sonst gilt der Wert für alle Podcasts ohne eigene Einstellung.';

  @override
  String get markPlayed => 'Als gespielt markieren';

  @override
  String get markUnplayed => 'Als ungespielt markieren';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get download => 'Herunterladen';

  @override
  String get downloadCancel => 'Download abbrechen';

  @override
  String get downloadDelete => 'Download löschen';

  @override
  String get downloadRetry => 'Erneut herunterladen';

  @override
  String get downloadDone => 'Heruntergeladen';

  @override
  String get downloadFailed => 'Download fehlgeschlagen';

  @override
  String get downloadQueued => 'Wartet …';

  @override
  String get downloadWifiWaiting => 'Wartet auf WLAN …';

  @override
  String get downloadsEmpty => 'Keine Downloads';

  @override
  String get downloadsEmptyHint =>
      'Folge lange drücken → „Herunterladen“, oder Auto-Download in den Podcast-Einstellungen aktivieren.';

  @override
  String downloadsUsage(String used, String limit) {
    return '$used von $limit belegt';
  }

  @override
  String get cleanUpNow => 'Jetzt aufräumen';

  @override
  String cleanUpResult(String freed) {
    return '$freed freigegeben';
  }

  @override
  String get cleanUpNothing => 'Alles aufgeräumt – nichts zu löschen.';

  @override
  String get podcastSettings => 'Podcast-Einstellungen';

  @override
  String get autoDownload => 'Automatisch herunterladen';

  @override
  String get autoDownloadOff => 'Aus';

  @override
  String get autoDownloadWifi => 'Nur WLAN';

  @override
  String get autoDownloadAlways => 'Immer';

  @override
  String get autoDownloadMax => 'Neueste ungespielte Folgen behalten';

  @override
  String get autoDeletePlayed => 'Gespielte Folgen löschen';

  @override
  String get autoDeletePlayedHint =>
      '96 Stunden nachdem eine Folge zu 98 % gehört wurde';

  @override
  String get settingsSectionDownloads => 'Downloads';

  @override
  String get downloadLimit => 'Speicherlimit für Downloads';

  @override
  String get downloadLimitHint =>
      'Ist das Limit erreicht, werden zuerst gespielte Folgen gelöscht. Ungespielte werden nie automatisch gelöscht – es wird nur nichts Neues mehr geladen.';
}
