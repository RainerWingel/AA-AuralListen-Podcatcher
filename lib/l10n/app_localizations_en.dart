// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AA-AuralListen Podcatcher';

  @override
  String get navHome => 'Home';

  @override
  String get navSubscriptions => 'Subs';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navSettings => 'Settings';

  @override
  String get placeholderComingSoon => 'Coming soon';

  @override
  String get cancel => 'Cancel';

  @override
  String get loadError => 'Error while loading';

  @override
  String get homeEmpty => 'No episodes yet';

  @override
  String get homeEmptyHint =>
      'Subscribe to podcasts in the “Subscriptions” tab.';

  @override
  String get subscriptionsEmpty => 'No subscriptions yet';

  @override
  String get subscriptionsEmptyHint => 'Add your first podcast by its RSS URL.';

  @override
  String get addFeedAction => 'Add by RSS URL';

  @override
  String get addFeedTitle => 'Add podcast';

  @override
  String get addFeedLabel => 'RSS URL';

  @override
  String get addFeedHint => 'https://example.com/feed.xml';

  @override
  String get addFeedSubmit => 'Add';

  @override
  String get subscribeErrorInvalidUrl => 'This is not a valid address.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'You are already subscribed to this podcast.';

  @override
  String get subscribeErrorNetwork =>
      'The feed could not be loaded. Please check the address and your internet connection.';

  @override
  String get subscribeErrorNotAFeed =>
      'There is no podcast feed at this address.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count feeds could not be updated.',
      one: '1 feed could not be updated.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Podcast not found';

  @override
  String get podcastRefreshError => 'Last update failed';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
      zero: 'No episodes',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'New';

  @override
  String get episodePlayed => 'Played';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get unsubscribeConfirmTitle => 'Unsubscribe?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '“$title” and all its episodes will be removed from the app.';
  }

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search podcasts';

  @override
  String get searchStart => 'Search by title, topic or author';

  @override
  String get searchStartHint => 'Searches Apple Podcasts and fyyd.de';

  @override
  String get subsSearchHint => 'Search subscriptions';

  @override
  String get subsSearchClose => 'Close search';

  @override
  String get searchClear => 'Clear';

  @override
  String get subsSearchPodcasts => 'Podcasts';

  @override
  String get subsSearchEpisodes => 'Episodes';

  @override
  String get subsSearchNothing => 'Nothing found in your subscriptions';

  @override
  String get subsSearchNothingHint =>
      'Find new podcasts with the search on “Home”.';

  @override
  String get searchNoResults => 'No podcasts found';

  @override
  String get searchFailed =>
      'Search failed. Please check your internet connection.';

  @override
  String searchPartialFailure(String names) {
    return '$names not reachable – results incomplete';
  }

  @override
  String get subscribed => 'Subscribed';

  @override
  String get subscribeAction => 'Subscribe';

  @override
  String subscribedSnack(String title) {
    return 'Subscribed to “$title”';
  }

  @override
  String get open => 'Open';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Subscriptions';

  @override
  String get opmlImport => 'Import OPML file';

  @override
  String get opmlImportSubtitle => 'Bring your subscriptions from another app';

  @override
  String get opmlInvalid => 'The file is not a valid OPML file.';

  @override
  String get opmlTooLarge => 'The file is too large.';

  @override
  String get opmlEmpty => 'No podcasts were found in the file.';

  @override
  String get opmlConfirmTitle => 'Import subscriptions?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts found.',
      one: '1 podcast found.',
    );
    return '$_temp0 Existing subscriptions are skipped.';
  }

  @override
  String get opmlImportAction => 'Import';

  @override
  String opmlProgress(int done, int total) {
    return 'Importing $done of $total …';
  }

  @override
  String get opmlResultTitle => 'Import finished';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'New: $added\nAlready subscribed: $already\nFailed: $failed';
  }

  @override
  String get opmlResultFailedList => 'Not imported:';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerRewind => 'Back 15 seconds';

  @override
  String get playerForward => 'Forward 30 seconds';

  @override
  String get playerClose => 'Close player';

  @override
  String get playerOpen => 'Open player';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String get boostTitle => 'Volume boost';

  @override
  String get speedTitle => 'Playback speed';

  @override
  String speedOff(String value) {
    return 'Off ($value)';
  }

  @override
  String speedButton(String value) {
    return 'Speed: $value';
  }

  @override
  String get boostOff => 'Off';

  @override
  String boostValue(int db) {
    return '+$db dB';
  }

  @override
  String boostButton(String value) {
    return 'Boost: $value';
  }

  @override
  String get boostPerPodcast => 'Only for this podcast';

  @override
  String get boostPerPodcastHint =>
      'Otherwise the value applies to all podcasts without their own setting.';

  @override
  String get markPlayed => 'Mark as played';

  @override
  String get markUnplayed => 'Mark as unplayed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get download => 'Download';

  @override
  String get episodeNumberingSeasons =>
      'Podcast with seasons: the feed\'s numbers per season apply (e.g. \"S2·5\"). An own count is not possible here.';

  @override
  String get episodeNumberOffsetSeasons =>
      'Not possible for podcasts with seasons.';

  @override
  String get seasonAll => 'All';

  @override
  String seasonLabel(int season) {
    return 'Season $season';
  }

  @override
  String get podcastWebsite => 'Website';

  @override
  String get podcastSupport => 'Support';

  @override
  String get playlistContinueOffer =>
      'Tap to continue with this playlist\'s next episode at the end';

  @override
  String get downloadCancel => 'Cancel download';

  @override
  String get downloadDelete => 'Delete download';

  @override
  String get downloadRetry => 'Download again';

  @override
  String get downloadDone => 'Downloaded';

  @override
  String get episodeInPlaylist => 'In a playlist';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get downloadQueued => 'Waiting …';

  @override
  String get downloadWifiWaiting => 'Waiting for Wi-Fi …';

  @override
  String get downloadNowMobile => 'Download now over mobile data';

  @override
  String downloadDeleteConfirm(String title) {
    return 'Delete “$title” from the device? The episode stays in the app and can still be streamed.';
  }

  @override
  String get detailsEpisode => 'Episode';

  @override
  String get detailsAuthor => 'Author';

  @override
  String get detailsPublished => 'Published';

  @override
  String get detailsDuration => 'Length';

  @override
  String get detailsSize => 'Size';

  @override
  String get detailsDownloadedAt => 'Downloaded';

  @override
  String get detailsStatus => 'Download';

  @override
  String get detailsListening => 'Listening state';

  @override
  String detailsInProgress(String position) {
    return 'Started, at $position';
  }

  @override
  String detailsPlayedAt(String date) {
    return 'Played on $date';
  }

  @override
  String get downloadsEmpty => 'No downloads';

  @override
  String get downloadsEmptyHint =>
      'Long-press an episode → “Download”, or turn on auto-download in the podcast settings.';

  @override
  String downloadsUsage(String used, String limit) {
    return '$used of $limit used';
  }

  @override
  String get cleanUpNow => 'Clean up now';

  @override
  String cleanUpResult(String freed) {
    return '$freed freed';
  }

  @override
  String get cleanUpNothing => 'All tidy – nothing to delete.';

  @override
  String get podcastSettings => 'Podcast settings';

  @override
  String get autoDownload => 'Download automatically';

  @override
  String get autoDownloadOff => 'Off';

  @override
  String get autoDownloadWifi => 'Wi-Fi only';

  @override
  String get autoDownloadAlways => 'Always';

  @override
  String get autoDownloadMax => 'Number of unplayed episodes on the phone';

  @override
  String get autoDownloadMaxHint =>
      'New episodes are downloaded until this many unplayed ones are on the phone. Nothing is deleted by this.';

  @override
  String get autoDownloadPlaylist => 'Add new episodes to playlist';

  @override
  String get autoDownloadPlaylistNone => 'None';

  @override
  String get autoDownloadPlaylistHint =>
      'Without auto-download, new episodes are only queued and streamed. If the playlist was deleted, the app creates it again next time.';

  @override
  String get episodeCounter => 'Episode number on the cover';

  @override
  String get episodeCounterHint =>
      'A narrow strip on the left edge of the covers in episode lists.';

  @override
  String get episodeNumbering => 'Numbering';

  @override
  String get episodeNumberingFeed => 'Feed numbers';

  @override
  String get episodeNumberingOwn => 'Own count';

  @override
  String get episodeNumberOffset => 'Counting offset';

  @override
  String get episodeNumberOffsetHint =>
      'Added to the count from the oldest episode – e.g. −1 so that it gets 0.';

  @override
  String get episodeNumberOffsetFeed =>
      'The offset only applies to the own count.';

  @override
  String get episodeNumberDecrease => 'Decrease';

  @override
  String get episodeNumberIncrease => 'Increase';

  @override
  String get autoDeletePlayed => 'Delete played episodes';

  @override
  String get autoDeletePlayedHint =>
      '96 hours after an episode has been played to the end';

  @override
  String get settingsSectionDownloads => 'Downloads';

  @override
  String get downloadLimit => 'Storage limit for downloads';

  @override
  String get downloadLimitHint =>
      'When the limit is reached, played episodes are deleted first. Unplayed episodes are never deleted automatically – nothing new is downloaded instead.';

  @override
  String get playlistNew => 'New playlist';

  @override
  String get playlistName => 'Name';

  @override
  String get playlistNameTaken => 'A playlist with this name already exists.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get ratingRemove => 'Remove rating';

  @override
  String get subsProvisional => 'Provisional';

  @override
  String get podcastAdd => 'Add';

  @override
  String get podcastInAbos => 'Already in your subscriptions';

  @override
  String addedProvisionalSnack(String title) {
    return '“$title” added provisionally';
  }

  @override
  String get podcastRemove => 'Remove';

  @override
  String get podcastRemoveConfirmTitle => 'Remove podcast?';

  @override
  String playlistActivated(String name) {
    return 'Playlist “$name” is active';
  }

  @override
  String get playlistOpen => 'Open playlist';

  @override
  String get finishedRemoval => 'Remove finished episodes from playlist';

  @override
  String get finishedRemovalHint =>
      'Applies to episodes played to the end and to “Mark as played” (also “All” and “up to …”).';

  @override
  String get finishedRemovalNow => 'Immediately';

  @override
  String get finishedRemovalAfter5Minutes => 'After 5 minutes';

  @override
  String get finishedRemovalNever => 'Never';

  @override
  String get autoMarkNewPlayed => 'Mark new ones as played automatically';

  @override
  String chapterProgress(int percent) {
    return '$percent%';
  }

  @override
  String averageEpisodeLength(String duration) {
    return 'Ø $duration per episode';
  }

  @override
  String get averageEpisodeLengthUnknown => 'Average length unknown';

  @override
  String get episodeHot => 'Popular: you almost always listen to this podcast';

  @override
  String get playlistColor => 'Color…';

  @override
  String get playlistColorNone => 'No color';

  @override
  String get colorRed => 'Red';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorViolet => 'Violet';

  @override
  String get appColor => 'App color';

  @override
  String get appColorWallpaper => 'Match wallpaper';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorBrown => 'Brown';

  @override
  String get playlistRename => 'Rename';

  @override
  String get playlistDelete => 'Delete playlist';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Delete “$name”? The episodes themselves are kept.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get create => 'Create';

  @override
  String get playlistsEmpty => 'No playlists';

  @override
  String get playlistEmpty => 'This playlist is empty';

  @override
  String get playlistEmptyHint => 'Long-press an episode → “Add to playlist…”';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
      zero: 'Empty',
    );
    return '$_temp0$duration';
  }

  @override
  String get addToPlaylist => 'Add to playlist…';

  @override
  String get playNext => 'Play next';

  @override
  String playNextHint(String playlist) {
    return 'Right after the current episode in “$playlist”';
  }

  @override
  String playNextDone(String playlist) {
    return 'Plays next in “$playlist”.';
  }

  @override
  String appendToPlaylist(String playlist) {
    return 'Add to the end of “$playlist”';
  }

  @override
  String appendToPlaylistDone(String playlist) {
    return 'Added to the end of “$playlist”.';
  }

  @override
  String get episodeDescription => 'Description';

  @override
  String episodeNumberLabel(String number) {
    return 'Episode $number';
  }

  @override
  String get episodeNoDescription => 'This episode has no description.';

  @override
  String addedToPlaylist(String name) {
    return 'Added to “$name”';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Already in “$name”';
  }

  @override
  String get removedFromPlaylist => 'Removed from the playlist';

  @override
  String get removeFromPlaylistTitle => 'Remove from playlist?';

  @override
  String removeFromPlaylistBody(String name) {
    return 'The episode is already in “$name”. Do you want to remove it from there?';
  }

  @override
  String get removeFromPlaylistAction => 'Remove';

  @override
  String removedFromNamedPlaylist(String name) {
    return 'Removed from “$name”';
  }

  @override
  String get undo => 'Undo';

  @override
  String get playerNext => 'Next episode';

  @override
  String get playerPrevious => 'Previous episode';

  @override
  String playingFromPlaylist(String name) {
    return 'From playlist “$name”';
  }

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get autoDownloadThemes => 'Topics for auto-download and playlist';

  @override
  String get autoDownloadThemesHint =>
      'Only checked topics are downloaded or added to the playlist automatically. New topics only once you check them here.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0 · latest $date';
  }

  @override
  String get selectAll => 'All';

  @override
  String get selectNone => 'None';

  @override
  String get chapters => 'Chapters';

  @override
  String chapterCurrent(int index, int count, String title) {
    return 'Chapter $index/$count: $title';
  }

  @override
  String get bookmarkAdd => 'Add bookmark';

  @override
  String get bookmarkNote => 'Note (optional)';

  @override
  String bookmarkAdded(String time) {
    return 'Bookmark added at $time';
  }

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String bookmarksCount(int count) {
    return 'Bookmarks ($count)';
  }

  @override
  String get bookmarksEmpty => 'No bookmarks';

  @override
  String get history => 'Playback history';

  @override
  String get historySubtitle => 'The last 100 episodes played to the end';

  @override
  String get historyEmpty => 'No episode played to the end yet';

  @override
  String get historyEmptyHint =>
      'Episodes show up here once they have been played to the end.';

  @override
  String get historyClear => 'Clear history';

  @override
  String get historyClearConfirm =>
      'Clear the whole playback history? Episodes and listening positions stay.';

  @override
  String get historyClearAction => 'Clear';

  @override
  String get historyEpisodeGone =>
      'This episode is no longer in your subscriptions.';

  @override
  String get bookmarksEmptyHint => 'Tap “Add bookmark” in the player.';

  @override
  String get bookmarkDeleted => 'Bookmark deleted';

  @override
  String get bookmarkDelete => 'Delete bookmark?';

  @override
  String bookmarkDeleteConfirm(String name) {
    return 'Really delete “$name”?';
  }

  @override
  String get bookmarkEditNote => 'Edit note';

  @override
  String get settingsSectionListening => 'Listening';

  @override
  String get markPlayedUntil => 'Mark as played up to …';

  @override
  String get markPlayedUntilPick => 'All episodes up to and including';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return 'Mark $_temp0 up to and including $date as played?';
  }

  @override
  String get markPlayedUntilHint =>
      'They leave the playlists (when: see “Remove finished episodes from playlist” in the options); downloaded episodes are deleted after 96 hours.';

  @override
  String markPlayedUntilNone(String date) {
    return 'There are no unplayed episodes up to $date.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0 marked as played';
  }

  @override
  String get markAction => 'Mark';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get opmlExport => 'Export subscriptions as OPML';

  @override
  String get opmlExportSubtitle => 'For other podcast apps';

  @override
  String get opmlExported => 'Subscriptions exported';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupCreateSubtitle =>
      'Subscriptions, progress, playlists, bookmarks, history, settings – without audio files';

  @override
  String get backupCreated => 'Backup saved';

  @override
  String get backupRestore => 'Restore backup';

  @override
  String get backupRestoreSubtitle => 'Replaces all current data';

  @override
  String get backupInvalid => 'The file is not a valid backup of this app.';

  @override
  String get backupTooNew => 'The backup comes from a newer app version.';

  @override
  String get backupConfirmTitle => 'Restore backup?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Backup from $date:\n$podcasts subscriptions · $episodes episodes · $playlists playlists · $bookmarks bookmarks\n\nAll current data will be replaced. Downloaded episodes will be deleted.';
  }

  @override
  String get backupRestoreAction => 'Restore';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get saveFailed => 'Saving failed';

  @override
  String get feedUrl => 'Feed address';

  @override
  String get feedUrlChange => 'Change feed address';

  @override
  String get feedUrlChangeHint =>
      'Only needed if the podcast has moved and the old address no longer works. Progress and downloads are kept.';

  @override
  String get feedUrlChangeSubmit => 'Apply';

  @override
  String get feedUrlChanged => 'Feed address changed.';

  @override
  String get feedUrlTaken =>
      'This address already belongs to another subscription.';

  @override
  String feedsMoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts have moved – their addresses were updated.',
      one: '1 podcast has moved – its address was updated.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Skip';

  @override
  String get chapterSkipHint =>
      'Skip chapters during playback (until the app is restarted)';

  @override
  String get backgroundPlayback => 'Background playback';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Battery: Unrestricted ✓ – tap for the app settings';

  @override
  String get backgroundPlaybackRestricted =>
      'Battery optimization is on: Android may stop playback while the screen is off. Tap to open the app settings → Battery → “Unrestricted”.';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unplayed episodes',
      one: '1 unplayed episode',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'The episode could not be loaded. Please check your internet connection.';

  @override
  String get playbackStalled =>
      'Playback got stuck and was paused. The position is saved – please check your connection.';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get sleepTimerOff => 'Off';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get sleepTimerEpisodeEnd => 'Until end of episode';

  @override
  String get sleepTimerEpisodeEndShort => 'Until episode end';

  @override
  String sleepTimerLeft(String time) {
    return '$time left';
  }

  @override
  String get playbackBrokenDownload =>
      'The download was damaged and has been deleted. The episode is now streamed.';

  @override
  String get playbackEpisodeGone =>
      'This episode is no longer available from the provider.';

  @override
  String get playbackUnsupported =>
      'This episode is in a format that cannot be played.';

  @override
  String get playbackStreamChanged =>
      'The episode arrived differently after reloading (e.g. other ads) – the position may be off. Downloaded episodes are not affected.';

  @override
  String get playbackStreamVaries =>
      'This podcast inserts changing ads when streaming – resuming may be inaccurate. Tip: download the episode.';

  @override
  String get playNewEpisodes => 'Play all new episodes';

  @override
  String playNewEpisodesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes from the last 96 hours',
      one: '1 episode from the last 96 hours',
      zero: 'No new episodes in the last 96 hours',
    );
    return '$_temp0';
  }

  @override
  String get playUnplayedEpisodes => 'Play all unplayed episodes';

  @override
  String get addNewEpisodesToPlaylist => 'All new episodes to a playlist';

  @override
  String get addUnplayedSinceToPlaylist =>
      'Unplayed episodes since … to a playlist';

  @override
  String get addUnplayedEpisodesToPlaylist =>
      'All unplayed episodes to a playlist';

  @override
  String get podcastMenuPlayNew => 'Play all new episodes';

  @override
  String get podcastMenuPlaySince => 'Play unplayed episodes since …';

  @override
  String get podcastMenuPlayUnplayed => 'Play all unplayed episodes';

  @override
  String get noUnplayedEpisodes => 'No unplayed episodes.';

  @override
  String episodesAddedNoPlay(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes added to “$playlist”.',
      one: '1 episode added to “$playlist”.',
      zero: 'All episodes were already in “$playlist”.',
    );
    return '$_temp0';
  }

  @override
  String episodesAddedToPlaylist(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes added to “$playlist”.',
      one: '1 episode added to “$playlist”.',
      zero: 'All episodes were already in “$playlist” – playback starts.',
    );
    return '$_temp0';
  }

  @override
  String get sleepTimerCustom => 'Custom time…';

  @override
  String sleepTimerCustomSet(int minutes) {
    return 'Custom time: $minutes minutes';
  }

  @override
  String get sleepTimerCustomLabel => 'Minutes';

  @override
  String sleepTimerCustomRange(int min, int max) {
    return '$min to $max minutes';
  }

  @override
  String get sleepTimerStart => 'Start';

  @override
  String get playUnplayedSince => 'Play unplayed episodes since …';

  @override
  String get playUnplayedSinceHint => 'Pick a date';

  @override
  String get playUnplayedSincePick => 'Unplayed episodes since';

  @override
  String playUnplayedSinceNone(String date) {
    return 'No unplayed episodes since $date.';
  }

  @override
  String get markUnplayedSince => 'Mark as unplayed since …';

  @override
  String get markUnplayedSincePick => 'All played episodes since and including';

  @override
  String markUnplayedSinceConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count played episodes',
      one: '1 played episode',
    );
    return 'Mark $_temp0 since and including $date as unplayed?';
  }

  @override
  String get markUnplayedSinceHint =>
      'They start from the beginning again and are no longer deleted automatically. Episodes in progress stay as they are.';

  @override
  String markUnplayedSinceNone(String date) {
    return 'There are no played episodes since $date.';
  }

  @override
  String markUnplayedSinceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0 marked as unplayed';
  }

  @override
  String get markAllPlayed => 'Mark all as played';

  @override
  String get markAllUnplayed => 'Mark all as unplayed';

  @override
  String markAllPlayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return 'Mark $_temp0 as played?';
  }

  @override
  String markAllUnplayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count played episodes',
      one: '1 played episode',
    );
    return 'Mark $_temp0 as unplayed?';
  }

  @override
  String get playlistSortDateAscending => 'Sort by date, ascending';

  @override
  String get playlistSortDateDescending => 'Sort by date, descending';

  @override
  String get playlistSortNameAscending => 'Sort by name, ascending';

  @override
  String playlistSortedDateAscending(String name) {
    return '“$name” sorted by date (oldest first).';
  }

  @override
  String playlistSortedDateDescending(String name) {
    return '“$name” sorted by date (newest first).';
  }

  @override
  String playlistSortedName(String name) {
    return '“$name” sorted by name (A–Z).';
  }

  @override
  String get playlistResume => 'Resume';

  @override
  String get playlistDownloadAll => 'Download all';

  @override
  String playlistDownloadAllConfirm(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return 'Download $_temp0 from “$name”?';
  }

  @override
  String playlistDownloadAllSize(String size) {
    return '(approx. $size)';
  }

  @override
  String get playlistDownloadAllHint =>
      'Downloads start right away, also over mobile data. Episodes already downloaded are skipped.';

  @override
  String get playlistDownloadAllNone =>
      'All episodes of this playlist are already downloaded.';

  @override
  String playlistDownloadAllStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads started.',
      one: '1 download started.',
    );
    return '$_temp0';
  }

  @override
  String get infoTitle => 'Info';

  @override
  String get infoAbout => 'About the app';

  @override
  String infoVersion(String name, int build) {
    return 'Version $name (build $build)';
  }

  @override
  String infoVersionShort(String name) {
    return 'Version $name';
  }

  @override
  String infoDeveloper(String name) {
    return 'Developed by $name';
  }

  @override
  String get infoPrivacy => 'Privacy policy';

  @override
  String get infoSourceCode => 'Source code on GitHub';

  @override
  String get infoLinkFailed => 'The link could not be opened.';

  @override
  String get infoSourceCodeHint =>
      'Source code, releases and a way to support the app voluntarily';

  @override
  String get language => 'Language';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePickerWelcome =>
      'Welcome to the Podcatcher “AA-AuralListen”';

  @override
  String get languagePickerTitle => 'Choose language';

  @override
  String get languagePickerHint =>
      'You can change the language later in Settings.';

  @override
  String get notificationChannelPlayback => 'Playback';
}
