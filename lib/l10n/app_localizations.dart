import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'AA-AuralListen Podcatcher'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get navHome;

  /// No description provided for @navSubscriptions.
  ///
  /// In de, this message translates to:
  /// **'Abos'**
  String get navSubscriptions;

  /// No description provided for @navPlaylists.
  ///
  /// In de, this message translates to:
  /// **'Playlists'**
  String get navPlaylists;

  /// No description provided for @navDownloads.
  ///
  /// In de, this message translates to:
  /// **'Downloads'**
  String get navDownloads;

  /// Short tab label (5 tabs must fit on a phone). The screen title is settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Optionen'**
  String get navSettings;

  /// Temporary text on screens that are not implemented yet.
  ///
  /// In de, this message translates to:
  /// **'Kommt bald'**
  String get placeholderComingSoon;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @loadError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden'**
  String get loadError;

  /// No description provided for @homeEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Folgen'**
  String get homeEmpty;

  /// No description provided for @homeEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Abonniere Podcasts im Tab „Abos“.'**
  String get homeEmptyHint;

  /// No description provided for @subscriptionsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Abos'**
  String get subscriptionsEmpty;

  /// No description provided for @subscriptionsEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Füge deinen ersten Podcast per RSS-URL hinzu.'**
  String get subscriptionsEmptyHint;

  /// No description provided for @addFeedAction.
  ///
  /// In de, this message translates to:
  /// **'Per RSS-URL hinzufügen'**
  String get addFeedAction;

  /// No description provided for @addFeedTitle.
  ///
  /// In de, this message translates to:
  /// **'Podcast hinzufügen'**
  String get addFeedTitle;

  /// No description provided for @addFeedLabel.
  ///
  /// In de, this message translates to:
  /// **'RSS-URL'**
  String get addFeedLabel;

  /// No description provided for @addFeedHint.
  ///
  /// In de, this message translates to:
  /// **'https://beispiel.de/feed.xml'**
  String get addFeedHint;

  /// No description provided for @addFeedSubmit.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get addFeedSubmit;

  /// No description provided for @subscribeErrorInvalidUrl.
  ///
  /// In de, this message translates to:
  /// **'Das ist keine gültige Adresse.'**
  String get subscribeErrorInvalidUrl;

  /// No description provided for @subscribeErrorAlreadySubscribed.
  ///
  /// In de, this message translates to:
  /// **'Diesen Podcast hast du schon abonniert.'**
  String get subscribeErrorAlreadySubscribed;

  /// No description provided for @subscribeErrorNetwork.
  ///
  /// In de, this message translates to:
  /// **'Der Feed konnte nicht geladen werden. Bitte Adresse und Internetverbindung prüfen.'**
  String get subscribeErrorNetwork;

  /// No description provided for @subscribeErrorNotAFeed.
  ///
  /// In de, this message translates to:
  /// **'Unter dieser Adresse liegt kein Podcast-Feed.'**
  String get subscribeErrorNotAFeed;

  /// No description provided for @refreshFailed.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Feed konnte nicht aktualisiert werden.} other{{count} Feeds konnten nicht aktualisiert werden.}}'**
  String refreshFailed(int count);

  /// No description provided for @podcastNotFound.
  ///
  /// In de, this message translates to:
  /// **'Podcast nicht gefunden'**
  String get podcastNotFound;

  /// No description provided for @podcastRefreshError.
  ///
  /// In de, this message translates to:
  /// **'Letzte Aktualisierung fehlgeschlagen'**
  String get podcastRefreshError;

  /// No description provided for @episodeCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Folgen} =1{1 Folge} other{{count} Folgen}}'**
  String episodeCount(int count);

  /// No description provided for @episodeNew.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get episodeNew;

  /// No description provided for @episodePlayed.
  ///
  /// In de, this message translates to:
  /// **'Gespielt'**
  String get episodePlayed;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In de, this message translates to:
  /// **'{hours} Std. {minutes} Min.'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In de, this message translates to:
  /// **'{minutes} Min.'**
  String durationMinutes(int minutes);

  /// No description provided for @unsubscribe.
  ///
  /// In de, this message translates to:
  /// **'Deabonnieren'**
  String get unsubscribe;

  /// No description provided for @unsubscribeConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Deabonnieren?'**
  String get unsubscribeConfirmTitle;

  /// No description provided for @unsubscribeConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ und alle Folgen werden aus der App entfernt.'**
  String unsubscribeConfirmBody(String title);

  /// No description provided for @search.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In de, this message translates to:
  /// **'Podcast suchen'**
  String get searchHint;

  /// No description provided for @searchStart.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Titel, Thema oder Autor'**
  String get searchStart;

  /// No description provided for @searchStartHint.
  ///
  /// In de, this message translates to:
  /// **'Durchsucht Apple Podcasts und fyyd.de'**
  String get searchStartHint;

  /// Abos tab: the search there only looks in subscribed podcasts and their episodes (local).
  ///
  /// In de, this message translates to:
  /// **'In Abos suchen'**
  String get subsSearchHint;

  /// No description provided for @subsSearchClose.
  ///
  /// In de, this message translates to:
  /// **'Suche schließen'**
  String get subsSearchClose;

  /// No description provided for @searchClear.
  ///
  /// In de, this message translates to:
  /// **'Eingabe löschen'**
  String get searchClear;

  /// No description provided for @subsSearchPodcasts.
  ///
  /// In de, this message translates to:
  /// **'Podcasts'**
  String get subsSearchPodcasts;

  /// No description provided for @subsSearchEpisodes.
  ///
  /// In de, this message translates to:
  /// **'Folgen'**
  String get subsSearchEpisodes;

  /// No description provided for @subsSearchNothing.
  ///
  /// In de, this message translates to:
  /// **'Nichts gefunden in deinen Abos'**
  String get subsSearchNothing;

  /// No description provided for @subsSearchNothingHint.
  ///
  /// In de, this message translates to:
  /// **'Neue Podcasts findest du über die Suche auf „Start“.'**
  String get subsSearchNothingHint;

  /// No description provided for @searchNoResults.
  ///
  /// In de, this message translates to:
  /// **'Keine Podcasts gefunden'**
  String get searchNoResults;

  /// No description provided for @searchFailed.
  ///
  /// In de, this message translates to:
  /// **'Suche fehlgeschlagen. Bitte Internetverbindung prüfen.'**
  String get searchFailed;

  /// No description provided for @searchPartialFailure.
  ///
  /// In de, this message translates to:
  /// **'{names} nicht erreichbar – Ergebnisse unvollständig'**
  String searchPartialFailure(String names);

  /// No description provided for @subscribed.
  ///
  /// In de, this message translates to:
  /// **'Abonniert'**
  String get subscribed;

  /// No description provided for @subscribeAction.
  ///
  /// In de, this message translates to:
  /// **'Abonnieren'**
  String get subscribeAction;

  /// No description provided for @subscribedSnack.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ abonniert'**
  String subscribedSnack(String title);

  /// No description provided for @open.
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get open;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @settingsSectionSubscriptions.
  ///
  /// In de, this message translates to:
  /// **'Abos'**
  String get settingsSectionSubscriptions;

  /// No description provided for @opmlImport.
  ///
  /// In de, this message translates to:
  /// **'OPML-Datei importieren'**
  String get opmlImport;

  /// No description provided for @opmlImportSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Abos aus einer anderen App übernehmen'**
  String get opmlImportSubtitle;

  /// No description provided for @opmlInvalid.
  ///
  /// In de, this message translates to:
  /// **'Die Datei ist keine gültige OPML-Datei.'**
  String get opmlInvalid;

  /// No description provided for @opmlTooLarge.
  ///
  /// In de, this message translates to:
  /// **'Die Datei ist zu groß.'**
  String get opmlTooLarge;

  /// No description provided for @opmlEmpty.
  ///
  /// In de, this message translates to:
  /// **'In der Datei wurden keine Podcasts gefunden.'**
  String get opmlEmpty;

  /// No description provided for @opmlConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Abos importieren?'**
  String get opmlConfirmTitle;

  /// No description provided for @opmlConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Podcast gefunden.} other{{count} Podcasts gefunden.}} Bereits vorhandene Abos werden übersprungen.'**
  String opmlConfirmBody(int count);

  /// No description provided for @opmlImportAction.
  ///
  /// In de, this message translates to:
  /// **'Importieren'**
  String get opmlImportAction;

  /// No description provided for @opmlProgress.
  ///
  /// In de, this message translates to:
  /// **'Importiere {done} von {total} …'**
  String opmlProgress(int done, int total);

  /// No description provided for @opmlResultTitle.
  ///
  /// In de, this message translates to:
  /// **'Import abgeschlossen'**
  String get opmlResultTitle;

  /// No description provided for @opmlResultBody.
  ///
  /// In de, this message translates to:
  /// **'Neu: {added}\nBereits vorhanden: {already}\nFehlgeschlagen: {failed}'**
  String opmlResultBody(int added, int already, int failed);

  /// No description provided for @opmlResultFailedList.
  ///
  /// In de, this message translates to:
  /// **'Nicht importiert:'**
  String get opmlResultFailedList;

  /// No description provided for @playerPlay.
  ///
  /// In de, this message translates to:
  /// **'Abspielen'**
  String get playerPlay;

  /// No description provided for @playerPause.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// No description provided for @playerRewind.
  ///
  /// In de, this message translates to:
  /// **'15 Sekunden zurück'**
  String get playerRewind;

  /// No description provided for @playerForward.
  ///
  /// In de, this message translates to:
  /// **'30 Sekunden vor'**
  String get playerForward;

  /// No description provided for @playerClose.
  ///
  /// In de, this message translates to:
  /// **'Player schließen'**
  String get playerClose;

  /// No description provided for @playerOpen.
  ///
  /// In de, this message translates to:
  /// **'Player öffnen'**
  String get playerOpen;

  /// No description provided for @nowPlaying.
  ///
  /// In de, this message translates to:
  /// **'Läuft gerade'**
  String get nowPlaying;

  /// No description provided for @boostTitle.
  ///
  /// In de, this message translates to:
  /// **'Lautstärke-Boost'**
  String get boostTitle;

  /// No description provided for @speedTitle.
  ///
  /// In de, this message translates to:
  /// **'Abspielgeschwindigkeit'**
  String get speedTitle;

  /// No description provided for @speedOff.
  ///
  /// In de, this message translates to:
  /// **'Aus ({value})'**
  String speedOff(String value);

  /// No description provided for @speedButton.
  ///
  /// In de, this message translates to:
  /// **'Tempo: {value}'**
  String speedButton(String value);

  /// No description provided for @boostOff.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get boostOff;

  /// No description provided for @boostValue.
  ///
  /// In de, this message translates to:
  /// **'+{db} dB'**
  String boostValue(int db);

  /// No description provided for @boostButton.
  ///
  /// In de, this message translates to:
  /// **'Boost: {value}'**
  String boostButton(String value);

  /// No description provided for @boostPerPodcast.
  ///
  /// In de, this message translates to:
  /// **'Nur für diesen Podcast'**
  String get boostPerPodcast;

  /// No description provided for @boostPerPodcastHint.
  ///
  /// In de, this message translates to:
  /// **'Sonst gilt der Wert für alle Podcasts ohne eigene Einstellung.'**
  String get boostPerPodcastHint;

  /// No description provided for @markPlayed.
  ///
  /// In de, this message translates to:
  /// **'Als gespielt markieren'**
  String get markPlayed;

  /// No description provided for @markUnplayed.
  ///
  /// In de, this message translates to:
  /// **'Als ungespielt markieren'**
  String get markUnplayed;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @download.
  ///
  /// In de, this message translates to:
  /// **'Herunterladen'**
  String get download;

  /// No description provided for @episodeNumberingSeasons.
  ///
  /// In de, this message translates to:
  /// **'Staffel-Podcast: Es gelten die Nummern aus dem Feed, je Staffel (z. B. „S2·5“). Eine eigene Zählung ist hier nicht möglich.'**
  String get episodeNumberingSeasons;

  /// No description provided for @episodeNumberOffsetSeasons.
  ///
  /// In de, this message translates to:
  /// **'Bei Staffel-Podcasts nicht möglich.'**
  String get episodeNumberOffsetSeasons;

  /// No description provided for @seasonAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get seasonAll;

  /// No description provided for @seasonLabel.
  ///
  /// In de, this message translates to:
  /// **'Staffel {season}'**
  String seasonLabel(int season);

  /// No description provided for @podcastWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get podcastWebsite;

  /// No description provided for @podcastSupport.
  ///
  /// In de, this message translates to:
  /// **'Unterstützen'**
  String get podcastSupport;

  /// No description provided for @playlistContinueOffer.
  ///
  /// In de, this message translates to:
  /// **'Antippen: am Ende mit der nächsten Folge dieser Playlist weitermachen'**
  String get playlistContinueOffer;

  /// No description provided for @downloadCancel.
  ///
  /// In de, this message translates to:
  /// **'Download abbrechen'**
  String get downloadCancel;

  /// No description provided for @downloadDelete.
  ///
  /// In de, this message translates to:
  /// **'Download löschen'**
  String get downloadDelete;

  /// No description provided for @downloadRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut herunterladen'**
  String get downloadRetry;

  /// No description provided for @downloadDone.
  ///
  /// In de, this message translates to:
  /// **'Heruntergeladen'**
  String get downloadDone;

  /// No description provided for @episodeInPlaylist.
  ///
  /// In de, this message translates to:
  /// **'In einer Playlist'**
  String get episodeInPlaylist;

  /// No description provided for @downloadFailed.
  ///
  /// In de, this message translates to:
  /// **'Download fehlgeschlagen'**
  String get downloadFailed;

  /// No description provided for @downloadQueued.
  ///
  /// In de, this message translates to:
  /// **'Wartet …'**
  String get downloadQueued;

  /// No description provided for @downloadWifiWaiting.
  ///
  /// In de, this message translates to:
  /// **'Wartet auf WLAN …'**
  String get downloadWifiWaiting;

  /// No description provided for @downloadNowMobile.
  ///
  /// In de, this message translates to:
  /// **'Jetzt über Mobilfunk laden'**
  String get downloadNowMobile;

  /// No description provided for @downloadDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ vom Gerät löschen? Die Folge bleibt in der App und kann weiter gestreamt werden.'**
  String downloadDeleteConfirm(String title);

  /// No description provided for @detailsEpisode.
  ///
  /// In de, this message translates to:
  /// **'Folge'**
  String get detailsEpisode;

  /// No description provided for @detailsAuthor.
  ///
  /// In de, this message translates to:
  /// **'Autor'**
  String get detailsAuthor;

  /// No description provided for @detailsPublished.
  ///
  /// In de, this message translates to:
  /// **'Erschienen'**
  String get detailsPublished;

  /// No description provided for @detailsDuration.
  ///
  /// In de, this message translates to:
  /// **'Länge'**
  String get detailsDuration;

  /// No description provided for @detailsSize.
  ///
  /// In de, this message translates to:
  /// **'Größe'**
  String get detailsSize;

  /// No description provided for @detailsDownloadedAt.
  ///
  /// In de, this message translates to:
  /// **'Heruntergeladen'**
  String get detailsDownloadedAt;

  /// No description provided for @detailsStatus.
  ///
  /// In de, this message translates to:
  /// **'Download'**
  String get detailsStatus;

  /// No description provided for @detailsListening.
  ///
  /// In de, this message translates to:
  /// **'Hörstand'**
  String get detailsListening;

  /// No description provided for @detailsInProgress.
  ///
  /// In de, this message translates to:
  /// **'Angefangen bei {position}'**
  String detailsInProgress(String position);

  /// No description provided for @detailsPlayedAt.
  ///
  /// In de, this message translates to:
  /// **'Gespielt am {date}'**
  String detailsPlayedAt(String date);

  /// No description provided for @downloadsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Downloads'**
  String get downloadsEmpty;

  /// No description provided for @downloadsEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Folge lange drücken → „Herunterladen“, oder Auto-Download in den Podcast-Einstellungen aktivieren.'**
  String get downloadsEmptyHint;

  /// No description provided for @downloadsUsage.
  ///
  /// In de, this message translates to:
  /// **'{used} von {limit} belegt'**
  String downloadsUsage(String used, String limit);

  /// No description provided for @cleanUpNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt aufräumen'**
  String get cleanUpNow;

  /// No description provided for @cleanUpResult.
  ///
  /// In de, this message translates to:
  /// **'{freed} freigegeben'**
  String cleanUpResult(String freed);

  /// No description provided for @cleanUpNothing.
  ///
  /// In de, this message translates to:
  /// **'Alles aufgeräumt – nichts zu löschen.'**
  String get cleanUpNothing;

  /// No description provided for @podcastSettings.
  ///
  /// In de, this message translates to:
  /// **'Podcast-Einstellungen'**
  String get podcastSettings;

  /// No description provided for @autoDownload.
  ///
  /// In de, this message translates to:
  /// **'Automatisch herunterladen'**
  String get autoDownload;

  /// No description provided for @autoDownloadOff.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get autoDownloadOff;

  /// No description provided for @autoDownloadWifi.
  ///
  /// In de, this message translates to:
  /// **'Nur WLAN'**
  String get autoDownloadWifi;

  /// No description provided for @autoDownloadAlways.
  ///
  /// In de, this message translates to:
  /// **'Immer'**
  String get autoDownloadAlways;

  /// No description provided for @autoDownloadMax.
  ///
  /// In de, this message translates to:
  /// **'Anzahl ungespielter Folgen auf dem Gerät'**
  String get autoDownloadMax;

  /// No description provided for @autoDownloadMaxHint.
  ///
  /// In de, this message translates to:
  /// **'Neue Folgen werden nachgeladen, bis so viele ungespielte heruntergeladen sind. Gelöscht wird dabei nichts.'**
  String get autoDownloadMaxHint;

  /// No description provided for @autoDownloadPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Neue Folgen zur Playlist hinzufügen'**
  String get autoDownloadPlaylist;

  /// No description provided for @autoDownloadPlaylistNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get autoDownloadPlaylistNone;

  /// No description provided for @autoDownloadPlaylistHint.
  ///
  /// In de, this message translates to:
  /// **'Ohne Auto-Download werden neue Folgen nur eingereiht und gestreamt. Wurde die Playlist gelöscht, legt die App sie beim nächsten Mal wieder an.'**
  String get autoDownloadPlaylistHint;

  /// No description provided for @episodeCounter.
  ///
  /// In de, this message translates to:
  /// **'Folgennummer am Cover'**
  String get episodeCounter;

  /// No description provided for @episodeCounterHint.
  ///
  /// In de, this message translates to:
  /// **'Schmaler Streifen am linken Rand der Cover in den Folgenlisten.'**
  String get episodeCounterHint;

  /// No description provided for @episodeNumbering.
  ///
  /// In de, this message translates to:
  /// **'Nummerierung'**
  String get episodeNumbering;

  /// No description provided for @episodeNumberingFeed.
  ///
  /// In de, this message translates to:
  /// **'Feed-Nummern'**
  String get episodeNumberingFeed;

  /// No description provided for @episodeNumberingOwn.
  ///
  /// In de, this message translates to:
  /// **'Eigene Zählung'**
  String get episodeNumberingOwn;

  /// No description provided for @episodeNumberOffset.
  ///
  /// In de, this message translates to:
  /// **'Versatz der Zählung'**
  String get episodeNumberOffset;

  /// No description provided for @episodeNumberOffsetHint.
  ///
  /// In de, this message translates to:
  /// **'Wird zur Zählung ab der ältesten Folge addiert – z. B. −1, damit sie die 0 bekommt.'**
  String get episodeNumberOffsetHint;

  /// No description provided for @episodeNumberOffsetFeed.
  ///
  /// In de, this message translates to:
  /// **'Der Versatz gilt nur für die eigene Zählung.'**
  String get episodeNumberOffsetFeed;

  /// No description provided for @episodeNumberDecrease.
  ///
  /// In de, this message translates to:
  /// **'Verringern'**
  String get episodeNumberDecrease;

  /// No description provided for @episodeNumberIncrease.
  ///
  /// In de, this message translates to:
  /// **'Erhöhen'**
  String get episodeNumberIncrease;

  /// No description provided for @autoDeletePlayed.
  ///
  /// In de, this message translates to:
  /// **'Gespielte Folgen löschen'**
  String get autoDeletePlayed;

  /// No description provided for @autoDeletePlayedHint.
  ///
  /// In de, this message translates to:
  /// **'96 Stunden nachdem eine Folge zu Ende gespielt wurde'**
  String get autoDeletePlayedHint;

  /// No description provided for @settingsSectionDownloads.
  ///
  /// In de, this message translates to:
  /// **'Downloads'**
  String get settingsSectionDownloads;

  /// No description provided for @downloadLimit.
  ///
  /// In de, this message translates to:
  /// **'Speicherlimit für Downloads'**
  String get downloadLimit;

  /// No description provided for @downloadLimitHint.
  ///
  /// In de, this message translates to:
  /// **'Ist das Limit erreicht, werden zuerst gespielte Folgen gelöscht. Ungespielte werden nie automatisch gelöscht – es wird nur nichts Neues mehr geladen.'**
  String get downloadLimitHint;

  /// No description provided for @playlistNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Playlist'**
  String get playlistNew;

  /// No description provided for @playlistName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get playlistName;

  /// No description provided for @playlistNameTaken.
  ///
  /// In de, this message translates to:
  /// **'Eine Playlist mit diesem Namen gibt es schon.'**
  String get playlistNameTaken;

  /// No description provided for @ratingStars.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Stern} other{{count} Sterne}}'**
  String ratingStars(int count);

  /// No description provided for @ratingRemove.
  ///
  /// In de, this message translates to:
  /// **'Bewertung entfernen'**
  String get ratingRemove;

  /// No description provided for @subsProvisional.
  ///
  /// In de, this message translates to:
  /// **'Vorläufig'**
  String get subsProvisional;

  /// No description provided for @podcastAdd.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get podcastAdd;

  /// No description provided for @podcastInAbos.
  ///
  /// In de, this message translates to:
  /// **'Schon in deinen Abos'**
  String get podcastInAbos;

  /// No description provided for @addedProvisionalSnack.
  ///
  /// In de, this message translates to:
  /// **'„{title}“ vorläufig hinzugefügt'**
  String addedProvisionalSnack(String title);

  /// No description provided for @podcastRemove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get podcastRemove;

  /// No description provided for @podcastRemoveConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Podcast entfernen?'**
  String get podcastRemoveConfirmTitle;

  /// No description provided for @playlistActivated.
  ///
  /// In de, this message translates to:
  /// **'Playlist „{name}“ ist aktiviert'**
  String playlistActivated(String name);

  /// No description provided for @playlistOpen.
  ///
  /// In de, this message translates to:
  /// **'Playlist öffnen'**
  String get playlistOpen;

  /// No description provided for @finishedRemoval.
  ///
  /// In de, this message translates to:
  /// **'Fertige Folgen aus Playlist entfernen'**
  String get finishedRemoval;

  /// No description provided for @finishedRemovalHint.
  ///
  /// In de, this message translates to:
  /// **'Gilt für bis zum Ende gehörte Folgen. „Als gespielt markieren“ entfernt immer sofort aus allen Playlists.'**
  String get finishedRemovalHint;

  /// No description provided for @finishedRemovalNow.
  ///
  /// In de, this message translates to:
  /// **'Sofort'**
  String get finishedRemovalNow;

  /// No description provided for @finishedRemovalAfter10Minutes.
  ///
  /// In de, this message translates to:
  /// **'Nach 10 Minuten'**
  String get finishedRemovalAfter10Minutes;

  /// No description provided for @finishedRemovalNever.
  ///
  /// In de, this message translates to:
  /// **'Nie'**
  String get finishedRemovalNever;

  /// No description provided for @autoMarkNewPlayed.
  ///
  /// In de, this message translates to:
  /// **'Neue automatisch als gespielt markieren'**
  String get autoMarkNewPlayed;

  /// No description provided for @chapterProgress.
  ///
  /// In de, this message translates to:
  /// **'{percent} %'**
  String chapterProgress(int percent);

  /// No description provided for @averageEpisodeLength.
  ///
  /// In de, this message translates to:
  /// **'Ø {duration} pro Folge'**
  String averageEpisodeLength(String duration);

  /// No description provided for @averageEpisodeLengthUnknown.
  ///
  /// In de, this message translates to:
  /// **'Durchschnittliche Länge unbekannt'**
  String get averageEpisodeLengthUnknown;

  /// No description provided for @episodeHot.
  ///
  /// In de, this message translates to:
  /// **'Beliebt: diesen Podcast hörst du fast immer'**
  String get episodeHot;

  /// Playlist menu: pick a category color (dialog title too).
  ///
  /// In de, this message translates to:
  /// **'Farbe…'**
  String get playlistColor;

  /// No description provided for @playlistColorNone.
  ///
  /// In de, this message translates to:
  /// **'Keine Farbe'**
  String get playlistColorNone;

  /// No description provided for @colorRed.
  ///
  /// In de, this message translates to:
  /// **'Rot'**
  String get colorRed;

  /// No description provided for @colorOrange.
  ///
  /// In de, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorYellow.
  ///
  /// In de, this message translates to:
  /// **'Gelb'**
  String get colorYellow;

  /// No description provided for @colorGreen.
  ///
  /// In de, this message translates to:
  /// **'Grün'**
  String get colorGreen;

  /// No description provided for @colorBlue.
  ///
  /// In de, this message translates to:
  /// **'Blau'**
  String get colorBlue;

  /// No description provided for @colorIndigo.
  ///
  /// In de, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @colorViolet.
  ///
  /// In de, this message translates to:
  /// **'Violett'**
  String get colorViolet;

  /// No description provided for @appColor.
  ///
  /// In de, this message translates to:
  /// **'App-Farbe'**
  String get appColor;

  /// App color taken from the phone's wallpaper (Android 12+ Material You).
  ///
  /// In de, this message translates to:
  /// **'Wie Hintergrundbild'**
  String get appColorWallpaper;

  /// No description provided for @colorPink.
  ///
  /// In de, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In de, this message translates to:
  /// **'Lila'**
  String get colorPurple;

  /// No description provided for @colorTeal.
  ///
  /// In de, this message translates to:
  /// **'Petrol'**
  String get colorTeal;

  /// No description provided for @colorBrown.
  ///
  /// In de, this message translates to:
  /// **'Braun'**
  String get colorBrown;

  /// No description provided for @playlistRename.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get playlistRename;

  /// No description provided for @playlistDelete.
  ///
  /// In de, this message translates to:
  /// **'Playlist löschen'**
  String get playlistDelete;

  /// No description provided for @playlistDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ löschen? Die Folgen selbst bleiben erhalten.'**
  String playlistDeleteConfirm(String name);

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @create.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get create;

  /// No description provided for @playlistsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Playlists'**
  String get playlistsEmpty;

  /// No description provided for @playlistEmpty.
  ///
  /// In de, this message translates to:
  /// **'Diese Playlist ist leer'**
  String get playlistEmpty;

  /// No description provided for @playlistEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Folge lange drücken → „Zu Playlist hinzufügen…“'**
  String get playlistEmptyHint;

  /// No description provided for @playlistSummary.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Leer} =1{1 Folge} other{{count} Folgen}}{duration}'**
  String playlistSummary(int count, String duration);

  /// No description provided for @addToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Zu Playlist hinzufügen…'**
  String get addToPlaylist;

  /// No description provided for @playNext.
  ///
  /// In de, this message translates to:
  /// **'Als Nächstes spielen'**
  String get playNext;

  /// No description provided for @playNextHint.
  ///
  /// In de, this message translates to:
  /// **'Direkt nach der laufenden Folge in „{playlist}“'**
  String playNextHint(String playlist);

  /// No description provided for @playNextDone.
  ///
  /// In de, this message translates to:
  /// **'Folgt als Nächstes in „{playlist}“.'**
  String playNextDone(String playlist);

  /// No description provided for @appendToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Ans Ende der Playlist „{playlist}“ anfügen'**
  String appendToPlaylist(String playlist);

  /// No description provided for @appendToPlaylistDone.
  ///
  /// In de, this message translates to:
  /// **'Ans Ende von „{playlist}“ angefügt.'**
  String appendToPlaylistDone(String playlist);

  /// No description provided for @episodeDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get episodeDescription;

  /// No description provided for @episodeNumberLabel.
  ///
  /// In de, this message translates to:
  /// **'Folge {number}'**
  String episodeNumberLabel(String number);

  /// No description provided for @episodeNoDescription.
  ///
  /// In de, this message translates to:
  /// **'Für diese Folge gibt es keine Beschreibung.'**
  String get episodeNoDescription;

  /// No description provided for @addedToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Zu „{name}“ hinzugefügt'**
  String addedToPlaylist(String name);

  /// No description provided for @alreadyInPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Schon in „{name}“'**
  String alreadyInPlaylist(String name);

  /// No description provided for @removedFromPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Aus der Playlist entfernt'**
  String get removedFromPlaylist;

  /// No description provided for @removeFromPlaylistTitle.
  ///
  /// In de, this message translates to:
  /// **'Aus Playlist entfernen?'**
  String get removeFromPlaylistTitle;

  /// No description provided for @removeFromPlaylistBody.
  ///
  /// In de, this message translates to:
  /// **'Die Folge ist schon in „{name}“. Möchtest du sie daraus entfernen?'**
  String removeFromPlaylistBody(String name);

  /// No description provided for @removeFromPlaylistAction.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get removeFromPlaylistAction;

  /// No description provided for @removedFromNamedPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Aus „{name}“ entfernt'**
  String removedFromNamedPlaylist(String name);

  /// No description provided for @undo.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get undo;

  /// No description provided for @playerNext.
  ///
  /// In de, this message translates to:
  /// **'Nächste Folge'**
  String get playerNext;

  /// No description provided for @playerPrevious.
  ///
  /// In de, this message translates to:
  /// **'Vorherige Folge'**
  String get playerPrevious;

  /// No description provided for @playingFromPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Aus Playlist „{name}“'**
  String playingFromPlaylist(String name);

  /// No description provided for @dragToReorder.
  ///
  /// In de, this message translates to:
  /// **'Zum Verschieben ziehen'**
  String get dragToReorder;

  /// No description provided for @autoDownloadThemes.
  ///
  /// In de, this message translates to:
  /// **'Themen für Auto-Download und Playlist'**
  String get autoDownloadThemes;

  /// No description provided for @autoDownloadThemesHint.
  ///
  /// In de, this message translates to:
  /// **'Nur angehakte Themen werden automatisch geladen bzw. in die Playlist gelegt. Neue Themen erst, wenn du sie hier anhakst.'**
  String get autoDownloadThemesHint;

  /// No description provided for @themeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Folge} other{{count} Folgen}} · zuletzt {date}'**
  String themeSubtitle(int count, String date);

  /// No description provided for @selectAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get selectAll;

  /// No description provided for @selectNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get selectNone;

  /// No description provided for @chapters.
  ///
  /// In de, this message translates to:
  /// **'Kapitel'**
  String get chapters;

  /// No description provided for @chapterCurrent.
  ///
  /// In de, this message translates to:
  /// **'Kapitel {index}/{count}: {title}'**
  String chapterCurrent(int index, int count, String title);

  /// No description provided for @bookmarkAdd.
  ///
  /// In de, this message translates to:
  /// **'Lesezeichen setzen'**
  String get bookmarkAdd;

  /// No description provided for @bookmarkNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz (optional)'**
  String get bookmarkNote;

  /// No description provided for @bookmarkAdded.
  ///
  /// In de, this message translates to:
  /// **'Lesezeichen bei {time} gesetzt'**
  String bookmarkAdded(String time);

  /// No description provided for @bookmarks.
  ///
  /// In de, this message translates to:
  /// **'Lesezeichen'**
  String get bookmarks;

  /// No description provided for @bookmarksCount.
  ///
  /// In de, this message translates to:
  /// **'Lesezeichen ({count})'**
  String bookmarksCount(int count);

  /// No description provided for @bookmarksEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Lesezeichen'**
  String get bookmarksEmpty;

  /// No description provided for @history.
  ///
  /// In de, this message translates to:
  /// **'Abspielverlauf'**
  String get history;

  /// No description provided for @historySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die letzten 100 zu Ende gehörten Folgen'**
  String get historySubtitle;

  /// No description provided for @historyEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Folge zu Ende gehört'**
  String get historyEmpty;

  /// No description provided for @historyEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Hier erscheinen Folgen, sobald sie bis zum Ende abgespielt wurden.'**
  String get historyEmptyHint;

  /// No description provided for @historyClear.
  ///
  /// In de, this message translates to:
  /// **'Verlauf löschen'**
  String get historyClear;

  /// No description provided for @historyClearConfirm.
  ///
  /// In de, this message translates to:
  /// **'Den ganzen Abspielverlauf löschen? Folgen und Hörstände bleiben erhalten.'**
  String get historyClearConfirm;

  /// No description provided for @historyClearAction.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get historyClearAction;

  /// No description provided for @historyEpisodeGone.
  ///
  /// In de, this message translates to:
  /// **'Diese Folge ist nicht mehr in deinen Abos.'**
  String get historyEpisodeGone;

  /// No description provided for @bookmarksEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Im Player auf „Lesezeichen setzen“ tippen.'**
  String get bookmarksEmptyHint;

  /// No description provided for @bookmarkDeleted.
  ///
  /// In de, this message translates to:
  /// **'Lesezeichen gelöscht'**
  String get bookmarkDeleted;

  /// No description provided for @bookmarkDelete.
  ///
  /// In de, this message translates to:
  /// **'Lesezeichen löschen?'**
  String get bookmarkDelete;

  /// No description provided for @bookmarkDeleteConfirm.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ wirklich löschen?'**
  String bookmarkDeleteConfirm(String name);

  /// No description provided for @bookmarkEditNote.
  ///
  /// In de, this message translates to:
  /// **'Notiz bearbeiten'**
  String get bookmarkEditNote;

  /// No description provided for @settingsSectionListening.
  ///
  /// In de, this message translates to:
  /// **'Hören'**
  String get settingsSectionListening;

  /// No description provided for @markPlayedUntil.
  ///
  /// In de, this message translates to:
  /// **'Als gespielt markieren bis …'**
  String get markPlayedUntil;

  /// No description provided for @markPlayedUntilPick.
  ///
  /// In de, this message translates to:
  /// **'Alle Folgen bis einschließlich'**
  String get markPlayedUntilPick;

  /// No description provided for @markPlayedUntilConfirm.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Folge} other{{count} Folgen}} bis einschließlich {date} als gespielt markieren?'**
  String markPlayedUntilConfirm(int count, String date);

  /// No description provided for @markPlayedUntilHint.
  ///
  /// In de, this message translates to:
  /// **'Sie verschwinden aus den Playlists; heruntergeladene Folgen werden nach 96 Stunden gelöscht.'**
  String get markPlayedUntilHint;

  /// No description provided for @markPlayedUntilNone.
  ///
  /// In de, this message translates to:
  /// **'Bis {date} gibt es keine ungespielten Folgen.'**
  String markPlayedUntilNone(String date);

  /// No description provided for @markPlayedUntilDone.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Folge} other{{count} Folgen}} als gespielt markiert'**
  String markPlayedUntilDone(int count);

  /// No description provided for @markAction.
  ///
  /// In de, this message translates to:
  /// **'Markieren'**
  String get markAction;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get settingsSectionAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In de, this message translates to:
  /// **'Sicherung'**
  String get settingsSectionBackup;

  /// No description provided for @opmlExport.
  ///
  /// In de, this message translates to:
  /// **'Abos als OPML exportieren'**
  String get opmlExport;

  /// No description provided for @opmlExportSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Für andere Podcast-Apps'**
  String get opmlExportSubtitle;

  /// No description provided for @opmlExported.
  ///
  /// In de, this message translates to:
  /// **'Abos exportiert'**
  String get opmlExported;

  /// No description provided for @backupCreate.
  ///
  /// In de, this message translates to:
  /// **'Backup erstellen'**
  String get backupCreate;

  /// No description provided for @backupCreateSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Abos, Hörstand, Playlists, Lesezeichen, Verlauf, Einstellungen – ohne Audiodateien'**
  String get backupCreateSubtitle;

  /// No description provided for @backupCreated.
  ///
  /// In de, this message translates to:
  /// **'Backup gespeichert'**
  String get backupCreated;

  /// No description provided for @backupRestore.
  ///
  /// In de, this message translates to:
  /// **'Backup wiederherstellen'**
  String get backupRestore;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Ersetzt alle aktuellen Daten'**
  String get backupRestoreSubtitle;

  /// No description provided for @backupInvalid.
  ///
  /// In de, this message translates to:
  /// **'Die Datei ist kein gültiges Backup dieser App.'**
  String get backupInvalid;

  /// No description provided for @backupTooNew.
  ///
  /// In de, this message translates to:
  /// **'Das Backup stammt aus einer neueren App-Version.'**
  String get backupTooNew;

  /// No description provided for @backupConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Backup wiederherstellen?'**
  String get backupConfirmTitle;

  /// No description provided for @backupConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Backup vom {date}:\n{podcasts} Abos · {episodes} Folgen · {playlists} Playlists · {bookmarks} Lesezeichen\n\nAlle aktuellen Daten werden ersetzt. Heruntergeladene Folgen werden gelöscht.'**
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  );

  /// No description provided for @backupRestoreAction.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get backupRestoreAction;

  /// No description provided for @backupRestored.
  ///
  /// In de, this message translates to:
  /// **'Backup wiederhergestellt'**
  String get backupRestored;

  /// No description provided for @saveFailed.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen'**
  String get saveFailed;

  /// No description provided for @feedUrl.
  ///
  /// In de, this message translates to:
  /// **'Feed-Adresse'**
  String get feedUrl;

  /// No description provided for @feedUrlChange.
  ///
  /// In de, this message translates to:
  /// **'Feed-Adresse ändern'**
  String get feedUrlChange;

  /// No description provided for @feedUrlChangeHint.
  ///
  /// In de, this message translates to:
  /// **'Nur nötig, wenn der Podcast umgezogen ist und die alte Adresse nicht mehr funktioniert. Hörstand und Downloads bleiben erhalten.'**
  String get feedUrlChangeHint;

  /// No description provided for @feedUrlChangeSubmit.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get feedUrlChangeSubmit;

  /// No description provided for @feedUrlChanged.
  ///
  /// In de, this message translates to:
  /// **'Feed-Adresse geändert.'**
  String get feedUrlChanged;

  /// No description provided for @feedUrlTaken.
  ///
  /// In de, this message translates to:
  /// **'Diese Adresse gehört schon zu einem anderen Abo.'**
  String get feedUrlTaken;

  /// No description provided for @feedsMoved.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Podcast ist umgezogen – die Adresse wurde aktualisiert.} other{{count} Podcasts sind umgezogen – die Adressen wurden aktualisiert.}}'**
  String feedsMoved(int count);

  /// No description provided for @chapterSkip.
  ///
  /// In de, this message translates to:
  /// **'Skip'**
  String get chapterSkip;

  /// No description provided for @chapterSkipHint.
  ///
  /// In de, this message translates to:
  /// **'Kapitel beim Abspielen überspringen (gilt bis zum Neustart der App)'**
  String get chapterSkipHint;

  /// No description provided for @backgroundPlayback.
  ///
  /// In de, this message translates to:
  /// **'Hintergrund-Wiedergabe'**
  String get backgroundPlayback;

  /// No description provided for @backgroundPlaybackUnrestricted.
  ///
  /// In de, this message translates to:
  /// **'Akku: Nicht eingeschränkt ✓ – tippen für die App-Einstellungen'**
  String get backgroundPlaybackUnrestricted;

  /// No description provided for @backgroundPlaybackRestricted.
  ///
  /// In de, this message translates to:
  /// **'Akku-Optimierung aktiv: Android kann die Wiedergabe bei ausgeschaltetem Bildschirm beenden. Tippen öffnet die App-Einstellungen → Akku → „Nicht eingeschränkt“.'**
  String get backgroundPlaybackRestricted;

  /// No description provided for @unplayedCount.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 ungespielte Folge} other{{count} ungespielte Folgen}}'**
  String unplayedCount(int count);

  /// No description provided for @playbackLoadFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Folge konnte nicht geladen werden. Bitte Internetverbindung prüfen.'**
  String get playbackLoadFailed;

  /// No description provided for @playbackStalled.
  ///
  /// In de, this message translates to:
  /// **'Die Wiedergabe hing und wurde angehalten. Position ist gespeichert – bitte Verbindung prüfen.'**
  String get playbackStalled;

  /// No description provided for @sleepTimer.
  ///
  /// In de, this message translates to:
  /// **'Sleep-Timer'**
  String get sleepTimer;

  /// No description provided for @sleepTimerOff.
  ///
  /// In de, this message translates to:
  /// **'Aus'**
  String get sleepTimerOff;

  /// No description provided for @sleepTimerMinutes.
  ///
  /// In de, this message translates to:
  /// **'{minutes} Minuten'**
  String sleepTimerMinutes(int minutes);

  /// No description provided for @sleepTimerEpisodeEnd.
  ///
  /// In de, this message translates to:
  /// **'Bis Ende der Folge'**
  String get sleepTimerEpisodeEnd;

  /// No description provided for @sleepTimerEpisodeEndShort.
  ///
  /// In de, this message translates to:
  /// **'Bis Folgenende'**
  String get sleepTimerEpisodeEndShort;

  /// No description provided for @sleepTimerLeft.
  ///
  /// In de, this message translates to:
  /// **'noch {time}'**
  String sleepTimerLeft(String time);

  /// No description provided for @playbackBrokenDownload.
  ///
  /// In de, this message translates to:
  /// **'Der Download war beschädigt und wurde gelöscht. Die Folge wird jetzt gestreamt.'**
  String get playbackBrokenDownload;

  /// No description provided for @playbackEpisodeGone.
  ///
  /// In de, this message translates to:
  /// **'Diese Folge ist beim Anbieter nicht mehr verfügbar.'**
  String get playbackEpisodeGone;

  /// No description provided for @playbackUnsupported.
  ///
  /// In de, this message translates to:
  /// **'Diese Folge liegt in einem Format vor, das nicht abgespielt werden kann.'**
  String get playbackUnsupported;

  /// No description provided for @playbackStreamChanged.
  ///
  /// In de, this message translates to:
  /// **'Die Folge kam beim Neuladen anders an (z. B. andere Werbung) – die Stelle kann abweichen. Heruntergeladen passiert das nicht.'**
  String get playbackStreamChanged;

  /// No description provided for @playbackStreamVaries.
  ///
  /// In de, this message translates to:
  /// **'Dieser Podcast fügt beim Streamen wechselnde Werbung ein – Fortsetzen kann ungenau sein. Tipp: Folge herunterladen.'**
  String get playbackStreamVaries;

  /// No description provided for @playNewEpisodes.
  ///
  /// In de, this message translates to:
  /// **'Alle neuen Episoden spielen'**
  String get playNewEpisodes;

  /// No description provided for @playNewEpisodesHint.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine neuen Folgen in den letzten 96 Stunden} =1{1 Folge aus den letzten 96 Stunden} other{{count} Folgen aus den letzten 96 Stunden}}'**
  String playNewEpisodesHint(int count);

  /// No description provided for @playUnplayedEpisodes.
  ///
  /// In de, this message translates to:
  /// **'Alle ungespielten Episoden spielen'**
  String get playUnplayedEpisodes;

  /// No description provided for @addNewEpisodesToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Alle neuen Episoden in Playlist'**
  String get addNewEpisodesToPlaylist;

  /// No description provided for @addUnplayedSinceToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Ungespielte Episoden seit … in Playlist'**
  String get addUnplayedSinceToPlaylist;

  /// No description provided for @addUnplayedEpisodesToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Alle ungespielten Episoden in Playlist'**
  String get addUnplayedEpisodesToPlaylist;

  /// No description provided for @podcastMenuPlayNew.
  ///
  /// In de, this message translates to:
  /// **'Alle neuen Episoden abspielen'**
  String get podcastMenuPlayNew;

  /// No description provided for @podcastMenuPlaySince.
  ///
  /// In de, this message translates to:
  /// **'Ungespielte Episoden seit … abspielen'**
  String get podcastMenuPlaySince;

  /// No description provided for @podcastMenuPlayUnplayed.
  ///
  /// In de, this message translates to:
  /// **'Alle ungespielten Episoden abspielen'**
  String get podcastMenuPlayUnplayed;

  /// No description provided for @noUnplayedEpisodes.
  ///
  /// In de, this message translates to:
  /// **'Keine ungespielten Folgen.'**
  String get noUnplayedEpisodes;

  /// No description provided for @episodesAddedNoPlay.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Alle Folgen waren schon in „{playlist}“.} =1{1 Folge zu „{playlist}“ hinzugefügt.} other{{count} Folgen zu „{playlist}“ hinzugefügt.}}'**
  String episodesAddedNoPlay(int count, String playlist);

  /// No description provided for @episodesAddedToPlaylist.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Alle Folgen waren schon in „{playlist}“ – Wiedergabe startet.} =1{1 Folge zu „{playlist}“ hinzugefügt.} other{{count} Folgen zu „{playlist}“ hinzugefügt.}}'**
  String episodesAddedToPlaylist(int count, String playlist);

  /// No description provided for @sleepTimerCustom.
  ///
  /// In de, this message translates to:
  /// **'Eigene Zeit…'**
  String get sleepTimerCustom;

  /// No description provided for @sleepTimerCustomSet.
  ///
  /// In de, this message translates to:
  /// **'Eigene Zeit: {minutes} Minuten'**
  String sleepTimerCustomSet(int minutes);

  /// No description provided for @sleepTimerCustomLabel.
  ///
  /// In de, this message translates to:
  /// **'Minuten'**
  String get sleepTimerCustomLabel;

  /// No description provided for @sleepTimerCustomRange.
  ///
  /// In de, this message translates to:
  /// **'{min} bis {max} Minuten'**
  String sleepTimerCustomRange(int min, int max);

  /// No description provided for @sleepTimerStart.
  ///
  /// In de, this message translates to:
  /// **'Starten'**
  String get sleepTimerStart;

  /// No description provided for @playUnplayedSince.
  ///
  /// In de, this message translates to:
  /// **'Ungespielte Episoden seit … spielen'**
  String get playUnplayedSince;

  /// No description provided for @playUnplayedSinceHint.
  ///
  /// In de, this message translates to:
  /// **'Datum wählen'**
  String get playUnplayedSinceHint;

  /// No description provided for @playUnplayedSincePick.
  ///
  /// In de, this message translates to:
  /// **'Ungespielte Folgen seit'**
  String get playUnplayedSincePick;

  /// No description provided for @playUnplayedSinceNone.
  ///
  /// In de, this message translates to:
  /// **'Keine ungespielten Folgen seit dem {date}.'**
  String playUnplayedSinceNone(String date);

  /// No description provided for @markUnplayedSince.
  ///
  /// In de, this message translates to:
  /// **'Als ungespielt markieren seit …'**
  String get markUnplayedSince;

  /// No description provided for @markUnplayedSincePick.
  ///
  /// In de, this message translates to:
  /// **'Alle gespielten Folgen seit einschließlich'**
  String get markUnplayedSincePick;

  /// No description provided for @markUnplayedSinceConfirm.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 gespielte Folge} other{{count} gespielte Folgen}} seit einschließlich {date} als ungespielt markieren?'**
  String markUnplayedSinceConfirm(int count, String date);

  /// No description provided for @markUnplayedSinceHint.
  ///
  /// In de, this message translates to:
  /// **'Sie beginnen wieder von vorn und werden nicht mehr automatisch gelöscht. Angefangene Folgen bleiben, wie sie sind.'**
  String get markUnplayedSinceHint;

  /// No description provided for @markUnplayedSinceNone.
  ///
  /// In de, this message translates to:
  /// **'Seit dem {date} gibt es keine gespielten Folgen.'**
  String markUnplayedSinceNone(String date);

  /// No description provided for @markUnplayedSinceDone.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Folge} other{{count} Folgen}} als ungespielt markiert'**
  String markUnplayedSinceDone(int count);

  /// Play menu of a podcast or topic: switches to markAllUnplayed only when every affected episode is played.
  ///
  /// In de, this message translates to:
  /// **'Alle als gespielt markieren'**
  String get markAllPlayed;

  /// No description provided for @markAllUnplayed.
  ///
  /// In de, this message translates to:
  /// **'Alle als ungespielt markieren'**
  String get markAllUnplayed;

  /// No description provided for @markAllPlayedConfirm.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Folge} other{{count} Folgen}} als gespielt markieren?'**
  String markAllPlayedConfirm(int count);

  /// No description provided for @markAllUnplayedConfirm.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 gespielte Folge} other{{count} gespielte Folgen}} als ungespielt markieren?'**
  String markAllUnplayedConfirm(int count);

  /// No description provided for @playlistSortDateAscending.
  ///
  /// In de, this message translates to:
  /// **'Aufsteigend nach Datum sortieren'**
  String get playlistSortDateAscending;

  /// No description provided for @playlistSortDateDescending.
  ///
  /// In de, this message translates to:
  /// **'Absteigend nach Datum sortieren'**
  String get playlistSortDateDescending;

  /// No description provided for @playlistSortNameAscending.
  ///
  /// In de, this message translates to:
  /// **'Aufsteigend nach Namen sortieren'**
  String get playlistSortNameAscending;

  /// No description provided for @playlistSortedDateAscending.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ nach Datum sortiert (älteste zuerst).'**
  String playlistSortedDateAscending(String name);

  /// No description provided for @playlistSortedDateDescending.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ nach Datum sortiert (neueste zuerst).'**
  String playlistSortedDateDescending(String name);

  /// No description provided for @playlistSortedName.
  ///
  /// In de, this message translates to:
  /// **'„{name}“ nach Namen sortiert (A–Z).'**
  String playlistSortedName(String name);

  /// Playlist: continue with the episode last played from it (else the first one).
  ///
  /// In de, this message translates to:
  /// **'Fortsetzen'**
  String get playlistResume;

  /// No description provided for @playlistDownloadAll.
  ///
  /// In de, this message translates to:
  /// **'Alles downloaden'**
  String get playlistDownloadAll;

  /// No description provided for @playlistDownloadAllConfirm.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Folge} other{{count} Folgen}} aus „{name}“ herunterladen?'**
  String playlistDownloadAllConfirm(int count, String name);

  /// No description provided for @playlistDownloadAllSize.
  ///
  /// In de, this message translates to:
  /// **'(ca. {size})'**
  String playlistDownloadAllSize(String size);

  /// No description provided for @playlistDownloadAllHint.
  ///
  /// In de, this message translates to:
  /// **'Die Downloads starten sofort, auch über mobile Daten. Schon heruntergeladene Folgen werden übersprungen.'**
  String get playlistDownloadAllHint;

  /// No description provided for @playlistDownloadAllNone.
  ///
  /// In de, this message translates to:
  /// **'Alle Folgen dieser Playlist sind schon heruntergeladen.'**
  String get playlistDownloadAllNone;

  /// No description provided for @playlistDownloadAllStarted.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Download gestartet.} other{{count} Downloads gestartet.}}'**
  String playlistDownloadAllStarted(int count);

  /// No description provided for @infoTitle.
  ///
  /// In de, this message translates to:
  /// **'Info'**
  String get infoTitle;

  /// No description provided for @infoAbout.
  ///
  /// In de, this message translates to:
  /// **'Über die App'**
  String get infoAbout;

  /// No description provided for @infoVersion.
  ///
  /// In de, this message translates to:
  /// **'Version {name} (Build {build})'**
  String infoVersion(String name, int build);

  /// No description provided for @infoVersionShort.
  ///
  /// In de, this message translates to:
  /// **'Version {name}'**
  String infoVersionShort(String name);

  /// No description provided for @infoDeveloper.
  ///
  /// In de, this message translates to:
  /// **'Entwickelt von {name}'**
  String infoDeveloper(String name);

  /// No description provided for @infoPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get infoPrivacy;

  /// No description provided for @infoSourceCode.
  ///
  /// In de, this message translates to:
  /// **'Quellcode auf GitHub'**
  String get infoSourceCode;

  /// No description provided for @infoLinkFailed.
  ///
  /// In de, this message translates to:
  /// **'Der Link konnte nicht geöffnet werden.'**
  String get infoLinkFailed;

  /// No description provided for @infoSourceCodeHint.
  ///
  /// In de, this message translates to:
  /// **'Quellcode, Releases und Möglichkeit zur freiwilligen Unterstützung'**
  String get infoSourceCodeHint;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// Always the language's own name – same text in every ARB file.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Always the language's own name – same text in every ARB file.
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// First start: headline at the top of the language picker.
  ///
  /// In de, this message translates to:
  /// **'Willkommen beim Podcatcher „AA-AuralListen“'**
  String get languagePickerWelcome;

  /// First start: shown in the device language before anything is chosen.
  ///
  /// In de, this message translates to:
  /// **'Sprache wählen'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerHint.
  ///
  /// In de, this message translates to:
  /// **'Du kannst die Sprache später unter Optionen ändern.'**
  String get languagePickerHint;

  /// Name of the Android notification channel (system settings → app notifications).
  ///
  /// In de, this message translates to:
  /// **'Wiedergabe'**
  String get notificationChannelPlayback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
