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

  /// No description provided for @navSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
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
