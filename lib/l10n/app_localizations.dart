import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

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
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'AA-PodcastGuru'**
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
  /// **'Abonnieren'**
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
  /// **'Abo kündigen'**
  String get unsubscribe;

  /// No description provided for @unsubscribeConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Abo kündigen?'**
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
  /// **'Abos aus einer anderen App übernehmen (z. B. Castbox)'**
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
  /// **'Neueste ungespielte Folgen behalten'**
  String get autoDownloadMax;

  /// No description provided for @autoDeletePlayed.
  ///
  /// In de, this message translates to:
  /// **'Gespielte Folgen löschen'**
  String get autoDeletePlayed;

  /// No description provided for @autoDeletePlayedHint.
  ///
  /// In de, this message translates to:
  /// **'96 Stunden nachdem eine Folge zu 98 % gehört wurde'**
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
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
