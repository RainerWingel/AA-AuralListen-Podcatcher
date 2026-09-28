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

  @override
  String get playlistNew => 'Neue Playlist';

  @override
  String get playlistName => 'Name';

  @override
  String get playlistRename => 'Umbenennen';

  @override
  String get playlistDelete => 'Playlist löschen';

  @override
  String playlistDeleteConfirm(String name) {
    return '„$name“ löschen? Die Folgen selbst bleiben erhalten.';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get create => 'Anlegen';

  @override
  String get playlistsEmpty => 'Keine Playlists';

  @override
  String get playlistEmpty => 'Diese Playlist ist leer';

  @override
  String get playlistEmptyHint =>
      'Folge lange drücken → „Zu Playlist hinzufügen…“';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Folgen',
      one: '1 Folge',
      zero: 'Leer',
    );
    return '$_temp0$duration';
  }

  @override
  String get playlistPlay => 'Playlist abspielen';

  @override
  String get addToPlaylist => 'Zu Playlist hinzufügen…';

  @override
  String addedToPlaylist(String name) {
    return 'Zu „$name“ hinzugefügt';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Schon in „$name“';
  }

  @override
  String get removedFromPlaylist => 'Aus der Playlist entfernt';

  @override
  String get undo => 'Rückgängig';

  @override
  String get playerNext => 'Nächste Folge';

  @override
  String playingFromPlaylist(String name) {
    return 'Aus Playlist „$name“';
  }

  @override
  String get dragToReorder => 'Zum Verschieben ziehen';

  @override
  String get autoDownloadThemes => 'Themen für automatische Downloads';

  @override
  String get autoDownloadThemesHint =>
      'Nur angehakte Themen werden automatisch geladen. Neue Themen erst, wenn du sie hier anhakst.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Folgen',
      one: '1 Folge',
    );
    return '$_temp0 · zuletzt $date';
  }

  @override
  String get selectAll => 'Alle';

  @override
  String get selectNone => 'Keine';

  @override
  String get chapters => 'Kapitel';

  @override
  String chapterCurrent(int index, int count, String title) {
    return 'Kapitel $index/$count: $title';
  }

  @override
  String get bookmarkAdd => 'Lesezeichen setzen';

  @override
  String get bookmarkNote => 'Notiz (optional)';

  @override
  String bookmarkAdded(String time) {
    return 'Lesezeichen bei $time gesetzt';
  }

  @override
  String get bookmarks => 'Lesezeichen';

  @override
  String bookmarksCount(int count) {
    return 'Lesezeichen ($count)';
  }

  @override
  String get bookmarksEmpty => 'Keine Lesezeichen';

  @override
  String get bookmarksEmptyHint => 'Im Player auf „Lesezeichen setzen“ tippen.';

  @override
  String get bookmarkDeleted => 'Lesezeichen gelöscht';

  @override
  String get bookmarkEditNote => 'Notiz bearbeiten';

  @override
  String get settingsSectionListening => 'Hören';

  @override
  String get markPlayedUntil => 'Als gehört markieren bis …';

  @override
  String get markPlayedUntilPick => 'Alle Folgen bis einschließlich';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Folgen',
      one: '1 Folge',
    );
    return '$_temp0 bis einschließlich $date als gehört markieren?';
  }

  @override
  String get markPlayedUntilHint =>
      'Sie verschwinden aus den Playlists; heruntergeladene Folgen werden nach 96 Stunden gelöscht.';

  @override
  String markPlayedUntilNone(String date) {
    return 'Bis $date gibt es keine ungehörten Folgen.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Folgen',
      one: '1 Folge',
    );
    return '$_temp0 als gehört markiert';
  }

  @override
  String get markAction => 'Markieren';

  @override
  String get settingsSectionAppearance => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsSectionBackup => 'Sicherung';

  @override
  String get opmlExport => 'Abos als OPML exportieren';

  @override
  String get opmlExportSubtitle => 'Für andere Podcast-Apps';

  @override
  String get opmlExported => 'Abos exportiert';

  @override
  String get backupCreate => 'Backup erstellen';

  @override
  String get backupCreateSubtitle =>
      'Abos, Hörstand, Playlists, Lesezeichen, Einstellungen – ohne Audiodateien';

  @override
  String get backupCreated => 'Backup gespeichert';

  @override
  String get backupRestore => 'Backup wiederherstellen';

  @override
  String get backupRestoreSubtitle => 'Ersetzt alle aktuellen Daten';

  @override
  String get backupInvalid => 'Die Datei ist kein gültiges Backup dieser App.';

  @override
  String get backupTooNew => 'Das Backup stammt aus einer neueren App-Version.';

  @override
  String get backupConfirmTitle => 'Backup wiederherstellen?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Backup vom $date:\n$podcasts Abos · $episodes Folgen · $playlists Playlists · $bookmarks Lesezeichen\n\nAlle aktuellen Daten werden ersetzt. Heruntergeladene Folgen werden gelöscht.';
  }

  @override
  String get backupRestoreAction => 'Wiederherstellen';

  @override
  String get backupRestored => 'Backup wiederhergestellt';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get feedUrl => 'Feed-Adresse';

  @override
  String get feedUrlChange => 'Feed-Adresse ändern';

  @override
  String get feedUrlChangeHint =>
      'Nur nötig, wenn der Podcast umgezogen ist und die alte Adresse nicht mehr funktioniert. Hörstand und Downloads bleiben erhalten.';

  @override
  String get feedUrlChangeSubmit => 'Übernehmen';

  @override
  String get feedUrlChanged => 'Feed-Adresse geändert.';

  @override
  String get feedUrlTaken => 'Diese Adresse gehört schon zu einem anderen Abo.';

  @override
  String feedsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Podcasts sind umgezogen – die Adressen wurden aktualisiert.',
      one: '1 Podcast ist umgezogen – die Adresse wurde aktualisiert.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Skip';

  @override
  String get chapterSkipHint =>
      'Kapitel beim Abspielen überspringen (gilt bis zum Neustart der App)';

  @override
  String get backgroundPlayback => 'Hintergrund-Wiedergabe';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Akku: Nicht eingeschränkt ✓ – tippen für die App-Einstellungen';

  @override
  String get backgroundPlaybackRestricted =>
      'Akku-Optimierung aktiv: Android kann die Wiedergabe bei ausgeschaltetem Bildschirm beenden. Tippen zum Ändern.';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungespielte Folgen',
      one: '1 ungespielte Folge',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'Die Folge konnte nicht geladen werden. Bitte Internetverbindung prüfen.';

  @override
  String get playbackStalled =>
      'Die Wiedergabe hing und wurde angehalten. Position ist gespeichert – bitte Verbindung prüfen.';
}
