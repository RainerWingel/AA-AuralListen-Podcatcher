// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AA-AuralListen Podcatcher';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSubscriptions => 'Abos';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navDownloads => 'Téléchargés';

  @override
  String get navSettings => 'Options';

  @override
  String get carNew => 'Nouveau';

  @override
  String carNotFound(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get carNothingToPlay =>
      'Rien écouté pour l’instant – choisissez un épisode';

  @override
  String get placeholderComingSoon => 'Bientôt disponible';

  @override
  String get cancel => 'Annuler';

  @override
  String get loadError => 'Erreur de chargement';

  @override
  String get homeEmpty => 'Aucun épisode pour l’instant';

  @override
  String get homeEmptyHint =>
      'Abonnez-vous à des podcasts dans l’onglet « Abos ».';

  @override
  String get subscriptionsEmpty => 'Aucun abonnement pour l’instant';

  @override
  String get subscriptionsEmptyHint =>
      'Ajoutez votre premier podcast par son adresse RSS.';

  @override
  String get addFeedAction => 'Ajouter par adresse RSS';

  @override
  String get addFeedTitle => 'Ajouter un podcast';

  @override
  String get addFeedLabel => 'Adresse RSS';

  @override
  String get addFeedHint => 'https://example.com/feed.xml';

  @override
  String get addFeedSubmit => 'Ajouter';

  @override
  String get subscribeErrorInvalidUrl => 'Cette adresse n’est pas valide.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'Vous êtes déjà abonné à ce podcast.';

  @override
  String get subscribeErrorNetwork =>
      'Le flux n’a pas pu être chargé. Vérifiez l’adresse et votre connexion Internet.';

  @override
  String get subscribeErrorNotAFeed =>
      'Il n’y a pas de flux de podcast à cette adresse.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flux n’ont pas pu être mis à jour.',
      one: '1 flux n’a pas pu être mis à jour.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Podcast introuvable';

  @override
  String get podcastRefreshError => 'La dernière mise à jour a échoué';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes',
      one: '1 épisode',
      zero: 'Aucun épisode',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'Nouveau';

  @override
  String get episodePlayed => 'Écouté';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get unsubscribe => 'Se désabonner';

  @override
  String get unsubscribeConfirmTitle => 'Se désabonner ?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '« $title » et tous ses épisodes seront supprimés de l’application.';
  }

  @override
  String get search => 'Rechercher';

  @override
  String get searchHint => 'Rechercher des podcasts';

  @override
  String get searchStart => 'Rechercher par titre, sujet ou auteur';

  @override
  String get searchStartHint => 'Recherche dans Apple Podcasts et fyyd.de';

  @override
  String get searchPopular => 'Populaires';

  @override
  String get searchNew => 'Nouveautés';

  @override
  String get subsSearchHint => 'Rechercher dans les abos';

  @override
  String get subsSearchClose => 'Fermer la recherche';

  @override
  String get searchClear => 'Effacer';

  @override
  String get subsSearchPodcasts => 'Podcasts';

  @override
  String get subsSearchEpisodes => 'Épisodes';

  @override
  String get subsSearchNothing => 'Rien trouvé dans vos abonnements';

  @override
  String get subsSearchNothingHint =>
      'Trouvez de nouveaux podcasts avec la recherche de l’« Accueil ».';

  @override
  String get searchNoResults => 'Aucun podcast trouvé';

  @override
  String get searchFailed =>
      'La recherche a échoué. Vérifiez votre connexion Internet.';

  @override
  String searchPartialFailure(String names) {
    return '$names injoignable – résultats incomplets';
  }

  @override
  String get subscribed => 'Abonné';

  @override
  String get subscribeAction => 'S’abonner';

  @override
  String subscribedSnack(String title) {
    return 'Abonné à « $title »';
  }

  @override
  String get open => 'Ouvrir';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Abonnements';

  @override
  String get opmlImport => 'Importer un fichier OPML';

  @override
  String get opmlImportSubtitle =>
      'Reprendre vos abonnements d’une autre application';

  @override
  String get opmlInvalid => 'Ce fichier n’est pas un fichier OPML valide.';

  @override
  String get opmlTooLarge => 'Le fichier est trop volumineux.';

  @override
  String get opmlEmpty => 'Aucun podcast n’a été trouvé dans le fichier.';

  @override
  String get opmlConfirmTitle => 'Importer les abonnements ?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts trouvés.',
      one: '1 podcast trouvé.',
    );
    return '$_temp0 Les abonnements existants sont ignorés.';
  }

  @override
  String get opmlImportAction => 'Importer';

  @override
  String opmlProgress(int done, int total) {
    return 'Importation $done sur $total …';
  }

  @override
  String get opmlResultTitle => 'Importation terminée';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'Nouveaux : $added\nDéjà abonné : $already\nÉchecs : $failed';
  }

  @override
  String get opmlResultFailedList => 'Non importés :';

  @override
  String get playerPlay => 'Lecture';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerRewind => 'Reculer de 15 secondes';

  @override
  String get playerForward => 'Avancer de 30 secondes';

  @override
  String get playerClose => 'Fermer le lecteur';

  @override
  String get playerOpen => 'Ouvrir le lecteur';

  @override
  String get nowPlaying => 'En cours de lecture';

  @override
  String get boostTitle => 'Amplification du volume';

  @override
  String get speedTitle => 'Vitesse de lecture';

  @override
  String speedOff(String value) {
    return 'Normale ($value)';
  }

  @override
  String speedButton(String value) {
    return 'Vitesse : $value';
  }

  @override
  String get boostOff => 'Aucun';

  @override
  String boostValue(int db) {
    return '+$db dB';
  }

  @override
  String boostButton(String value) {
    return 'Boost : $value';
  }

  @override
  String get speedPerPodcast => 'Seulement pour ce podcast';

  @override
  String get speedPerPodcastHint =>
      'Sinon, la vitesse s’applique à tous les podcasts sans réglage propre.';

  @override
  String get boostPerPodcast => 'Seulement pour ce podcast';

  @override
  String get boostPerPodcastHint =>
      'Sinon, la valeur s’applique à tous les podcasts sans réglage propre.';

  @override
  String get markPlayed => 'Marquer comme écouté';

  @override
  String get markUnplayed => 'Marquer comme non écouté';

  @override
  String get settingsTitle => 'Options';

  @override
  String get download => 'Télécharger';

  @override
  String get episodeNumberingSeasons =>
      'Podcast avec saisons : les numéros du flux par saison s’appliquent (p. ex. « S2·5 »). Un comptage propre n’est pas possible ici.';

  @override
  String get episodeNumberOffsetSeasons =>
      'Impossible pour les podcasts avec saisons.';

  @override
  String get seasonAll => 'Toutes';

  @override
  String seasonLabel(int season) {
    return 'Saison $season';
  }

  @override
  String get podcastWebsite => 'Site web';

  @override
  String get podcastSupport => 'Soutenir';

  @override
  String get playlistContinueOffer =>
      'Touchez pour enchaîner à la fin avec l’épisode suivant de cette playlist';

  @override
  String get downloadCancel => 'Annuler le téléchargement';

  @override
  String get downloadDelete => 'Supprimer le téléchargement';

  @override
  String get downloadRetry => 'Télécharger à nouveau';

  @override
  String get downloadDone => 'Téléchargé';

  @override
  String get episodeInPlaylist => 'Dans une playlist';

  @override
  String get downloadFailed => 'Échec du téléchargement';

  @override
  String get downloadQueued => 'En attente …';

  @override
  String get downloadWifiWaiting => 'En attente du Wi-Fi …';

  @override
  String get downloadNowMobile =>
      'Télécharger maintenant via les données mobiles';

  @override
  String downloadDeleteConfirm(String title) {
    return 'Supprimer « $title » de l’appareil ? L’épisode reste dans l’application et peut toujours être écouté en streaming.';
  }

  @override
  String get detailsEpisode => 'Épisode';

  @override
  String get detailsAuthor => 'Auteur';

  @override
  String get detailsPublished => 'Publié';

  @override
  String get detailsDuration => 'Durée';

  @override
  String get detailsSize => 'Taille';

  @override
  String get detailsDownloadedAt => 'Téléchargé';

  @override
  String get detailsStatus => 'Téléchargement';

  @override
  String get detailsListening => 'État d’écoute';

  @override
  String detailsInProgress(String position) {
    return 'Commencé, à $position';
  }

  @override
  String detailsPlayedAt(String date) {
    return 'Écouté le $date';
  }

  @override
  String get downloadsEmpty => 'Aucun téléchargement';

  @override
  String get downloadsEmptyHint =>
      'Appui long sur un épisode → « Télécharger », ou activez le téléchargement automatique dans les réglages du podcast.';

  @override
  String downloadsUsage(String used, String limit) {
    return '$used sur $limit utilisés';
  }

  @override
  String get cleanUpNow => 'Faire le ménage';

  @override
  String cleanUpResult(String freed) {
    return '$freed libérés';
  }

  @override
  String get cleanUpNothing => 'Tout est en ordre – rien à supprimer.';

  @override
  String get podcastSettings => 'Réglages du podcast';

  @override
  String get autoDownload => 'Télécharger automatiquement';

  @override
  String get autoDownloadOff => 'Désactivé';

  @override
  String get autoDownloadWifi => 'Wi-Fi seul';

  @override
  String get autoDownloadAlways => 'Toujours';

  @override
  String get autoDownloadMax =>
      'Nombre d’épisodes non écoutés sur le téléphone';

  @override
  String get autoDownloadMaxHint =>
      'Les nouveaux épisodes sont téléchargés jusqu’à ce que ce nombre d’épisodes non écoutés soit sur le téléphone. Rien n’est supprimé pour autant.';

  @override
  String get autoDownloadPlaylist =>
      'Ajouter les nouveaux épisodes à la playlist';

  @override
  String get autoDownloadPlaylistNone => 'Aucune';

  @override
  String get autoDownloadPlaylistHint =>
      'Sans téléchargement automatique, les nouveaux épisodes sont seulement ajoutés et lus en streaming. Si la playlist a été supprimée, l’application la recrée la fois suivante.';

  @override
  String get episodeCounter => 'Numéro d’épisode sur la pochette';

  @override
  String get episodeCounterHint =>
      'Une fine bande sur le bord gauche des pochettes dans les listes d’épisodes.';

  @override
  String get episodeNumbering => 'Numérotation';

  @override
  String get episodeNumberingFeed => 'Numéros du flux';

  @override
  String get episodeNumberingOwn => 'Comptage propre';

  @override
  String get episodeNumberOffset => 'Décalage du comptage';

  @override
  String get episodeNumberOffsetHint =>
      'Ajouté au comptage depuis l’épisode le plus ancien – p. ex. −1 pour qu’il devienne 0.';

  @override
  String get episodeNumberOffsetFeed =>
      'Le décalage ne s’applique qu’au comptage propre.';

  @override
  String get episodeNumberDecrease => 'Diminuer';

  @override
  String get episodeNumberIncrease => 'Augmenter';

  @override
  String get autoDeletePlayed => 'Supprimer les épisodes écoutés';

  @override
  String get autoDeletePlayedHint =>
      '96 heures après qu’un épisode a été écouté jusqu’au bout';

  @override
  String get settingsSectionDownloads => 'Téléchargements';

  @override
  String get downloadLimit => 'Espace maximal pour les téléchargements';

  @override
  String get downloadLimitHint =>
      'Quand la limite est atteinte, les épisodes écoutés sont supprimés en premier. Les épisodes non écoutés ne sont jamais supprimés automatiquement – dans ce cas, rien de nouveau n’est téléchargé.';

  @override
  String get playlistNew => 'Nouvelle playlist';

  @override
  String get playlistName => 'Nom';

  @override
  String get playlistNameTaken => 'Une playlist portant ce nom existe déjà.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get ratingRemove => 'Supprimer la note';

  @override
  String get subsProvisional => 'Provisoire';

  @override
  String get podcastAdd => 'Ajouter';

  @override
  String get podcastInAbos => 'Déjà dans vos abonnements';

  @override
  String addedProvisionalSnack(String title) {
    return '« $title » ajouté provisoirement';
  }

  @override
  String get podcastRemove => 'Retirer';

  @override
  String get podcastRemoveConfirmTitle => 'Retirer le podcast ?';

  @override
  String playlistActivated(String name) {
    return 'La playlist « $name » est active';
  }

  @override
  String get playlistOpen => 'Ouvrir la playlist';

  @override
  String get finishedRemoval => 'Retirer les épisodes terminés de la playlist';

  @override
  String get finishedRemovalHint =>
      'S’applique aux épisodes écoutés jusqu’au bout et à « Marquer comme écouté » (aussi « Tous » et « jusqu’au … »).';

  @override
  String get finishedRemovalNow => 'Immédiatement';

  @override
  String get finishedRemovalAfter5Minutes => 'Après 5 minutes';

  @override
  String get finishedRemovalNever => 'Jamais';

  @override
  String get autoMarkNewPlayed =>
      'Marquer automatiquement les nouveaux comme écoutés';

  @override
  String chapterProgress(int percent) {
    return '$percent %';
  }

  @override
  String averageEpisodeLength(String duration) {
    return 'Ø $duration par épisode';
  }

  @override
  String get averageEpisodeLengthUnknown => 'Durée moyenne inconnue';

  @override
  String get episodeHot =>
      'Populaire : vous écoutez presque toujours ce podcast';

  @override
  String get playlistColor => 'Couleur…';

  @override
  String get playlistColorNone => 'Sans couleur';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorViolet => 'Violet';

  @override
  String get appColor => 'Couleur de l’application';

  @override
  String get appColorWallpaper => 'Comme le fond d’écran';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorPurple => 'Pourpre';

  @override
  String get colorTeal => 'Bleu canard';

  @override
  String get colorBrown => 'Marron';

  @override
  String get playlistRename => 'Renommer';

  @override
  String get playlistDelete => 'Supprimer la playlist';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Supprimer « $name » ? Les épisodes eux-mêmes sont conservés.';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get create => 'Créer';

  @override
  String get playlistsEmpty => 'Aucune playlist';

  @override
  String get playlistEmpty => 'Cette playlist est vide';

  @override
  String get playlistEmptyHint =>
      'Appui long sur un épisode → « Ajouter à une playlist… »';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes',
      one: '1 épisode',
      zero: 'Vide',
    );
    return '$_temp0$duration';
  }

  @override
  String get addToPlaylist => 'Ajouter à une playlist…';

  @override
  String get playNext => 'Lire ensuite';

  @override
  String playNextHint(String playlist) {
    return 'Juste après l’épisode en cours dans « $playlist »';
  }

  @override
  String playNextDone(String playlist) {
    return 'Sera lu ensuite dans « $playlist ».';
  }

  @override
  String appendToPlaylist(String playlist) {
    return 'Ajouter à la fin de « $playlist »';
  }

  @override
  String appendToPlaylistDone(String playlist) {
    return 'Ajouté à la fin de « $playlist ».';
  }

  @override
  String get episodeDescription => 'Description';

  @override
  String episodeNumberLabel(String number) {
    return 'Épisode $number';
  }

  @override
  String get episodeNoDescription => 'Cet épisode n’a pas de description.';

  @override
  String addedToPlaylist(String name) {
    return 'Ajouté à « $name »';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Déjà dans « $name »';
  }

  @override
  String get removedFromPlaylist => 'Retiré de la playlist';

  @override
  String get removeFromPlaylistTitle => 'Retirer de la playlist ?';

  @override
  String removeFromPlaylistBody(String name) {
    return 'L’épisode est déjà dans « $name ». Voulez-vous l’en retirer ?';
  }

  @override
  String get removeFromPlaylistAction => 'Retirer';

  @override
  String removedFromNamedPlaylist(String name) {
    return 'Retiré de « $name »';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get playerNext => 'Épisode suivant';

  @override
  String get playerPrevious => 'Épisode précédent';

  @override
  String playingFromPlaylist(String name) {
    return 'Depuis la playlist « $name »';
  }

  @override
  String get dragToReorder => 'Faire glisser pour réorganiser';

  @override
  String get autoDownloadThemes =>
      'Thèmes pour le téléchargement auto et la playlist';

  @override
  String get autoDownloadThemesHint =>
      'Seuls les thèmes cochés sont téléchargés ou ajoutés automatiquement à la playlist. Les nouveaux thèmes seulement une fois cochés ici.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes',
      one: '1 épisode',
    );
    return '$_temp0 · dernier le $date';
  }

  @override
  String get selectAll => 'Tous';

  @override
  String get selectNone => 'Aucun';

  @override
  String get chapters => 'Chapitres';

  @override
  String chaptersCount(int count) {
    return 'Chapitres ($count)';
  }

  @override
  String chapterCurrent(int index, int count, String title) {
    return 'Chapitre $index/$count : $title';
  }

  @override
  String get descriptionMore => 'Lire la suite';

  @override
  String get descriptionLess => 'Réduire';

  @override
  String get bookmarkAdd => 'Ajouter un signet';

  @override
  String bookmarkListHint(int count) {
    return 'Appui long : liste des signets ($count)';
  }

  @override
  String get bookmarkNote => 'Note (facultative)';

  @override
  String bookmarkAdded(String time) {
    return 'Signet ajouté à $time';
  }

  @override
  String get bookmarks => 'Signets';

  @override
  String bookmarksCount(int count) {
    return 'Signets ($count)';
  }

  @override
  String get bookmarksEmpty => 'Aucun signet';

  @override
  String get history => 'Historique d’écoute';

  @override
  String get historySubtitle =>
      'Les 100 derniers épisodes écoutés jusqu’au bout';

  @override
  String get historyEmpty =>
      'Aucun épisode écouté jusqu’au bout pour l’instant';

  @override
  String get historyEmptyHint =>
      'Les épisodes apparaissent ici une fois écoutés jusqu’au bout.';

  @override
  String get historyClear => 'Effacer l’historique';

  @override
  String get historyClearConfirm =>
      'Effacer tout l’historique d’écoute ? Les épisodes et les positions d’écoute sont conservés.';

  @override
  String get historyClearAction => 'Effacer';

  @override
  String get historyEpisodeGone =>
      'Cet épisode ne fait plus partie de vos abonnements.';

  @override
  String get bookmarksEmptyHint =>
      'Touchez « Ajouter un signet » dans le lecteur.';

  @override
  String refreshProgress(int current, int total, String title) {
    return '$current sur $total · $title';
  }

  @override
  String get bookmarkDeleted => 'Signet supprimé';

  @override
  String get bookmarkDelete => 'Supprimer le signet ?';

  @override
  String bookmarkDeleteConfirm(String name) {
    return 'Vraiment supprimer « $name » ?';
  }

  @override
  String get bookmarkEditNote => 'Modifier la note';

  @override
  String get settingsSectionListening => 'Écoute';

  @override
  String get markPlayedUntil => 'Marquer comme écouté jusqu’au …';

  @override
  String get markPlayedUntilPick => 'Tous les épisodes jusqu’au (inclus)';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marquer $count épisodes jusqu’au $date inclus comme écoutés ?',
      one: 'Marquer 1 épisode jusqu’au $date inclus comme écouté ?',
    );
    return '$_temp0';
  }

  @override
  String get markPlayedUntilHint =>
      'Ils quittent les playlists (quand : voir « Retirer les épisodes terminés de la playlist » dans les options) ; les épisodes téléchargés sont supprimés après 96 heures.';

  @override
  String markPlayedUntilNone(String date) {
    return 'Il n’y a pas d’épisodes non écoutés jusqu’au $date.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes marqués comme écoutés',
      one: '1 épisode marqué comme écouté',
    );
    return '$_temp0';
  }

  @override
  String get markAction => 'Marquer';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get designTitle => 'Design';

  @override
  String get designSubtitle =>
      'Clair/sombre, couleur de l’application, commandes du lecteur';

  @override
  String get designSectionPanel => 'Commandes du lecteur';

  @override
  String get designPanelHint =>
      'L’arrière-plan derrière la barre de progression et les boutons du lecteur plein écran. Il suit le mode clair/sombre et la couleur de l’application.';

  @override
  String get panelDesignPlain => 'Sobre';

  @override
  String get panelDesignStars => 'Ciel étoilé';

  @override
  String get panelDesignAurora => 'Aurore boréale';

  @override
  String get panelDesignWaves => 'Vagues';

  @override
  String get panelDesignFacets => 'Cristal';

  @override
  String get panelDesignCamouflage => 'Camouflage';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsSectionBackup => 'Sauvegarde';

  @override
  String get opmlExport => 'Exporter les abonnements en OPML';

  @override
  String get opmlExportSubtitle => 'Pour d’autres applications de podcasts';

  @override
  String get opmlExported => 'Abonnements exportés';

  @override
  String get backupCreate => 'Créer une sauvegarde';

  @override
  String get backupCreateSubtitle =>
      'Abonnements, progression, playlists, signets, historique, réglages – sans les fichiers audio';

  @override
  String get backupCreated => 'Sauvegarde enregistrée';

  @override
  String get backupRestore => 'Restaurer une sauvegarde';

  @override
  String get backupRestoreSubtitle => 'Remplace toutes les données actuelles';

  @override
  String get backupInvalid =>
      'Ce fichier n’est pas une sauvegarde valide de cette application.';

  @override
  String get backupTooNew =>
      'La sauvegarde provient d’une version plus récente de l’application.';

  @override
  String get backupConfirmTitle => 'Restaurer la sauvegarde ?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Sauvegarde du $date :\n$podcasts abonnements · $episodes épisodes · $playlists playlists · $bookmarks signets\n\nToutes les données actuelles seront remplacées. Les épisodes téléchargés seront supprimés.';
  }

  @override
  String get backupRestoreAction => 'Restaurer';

  @override
  String get backupRestored => 'Sauvegarde restaurée';

  @override
  String get saveFailed => 'L’enregistrement a échoué';

  @override
  String get feedUrl => 'Adresse du flux';

  @override
  String get feedUrlChange => 'Modifier l’adresse du flux';

  @override
  String get feedUrlChangeHint =>
      'Nécessaire seulement si le podcast a déménagé et que l’ancienne adresse ne fonctionne plus. La progression et les téléchargements sont conservés.';

  @override
  String get feedUrlChangeSubmit => 'Appliquer';

  @override
  String get feedUrlChanged => 'Adresse du flux modifiée.';

  @override
  String get feedUrlTaken =>
      'Cette adresse appartient déjà à un autre abonnement.';

  @override
  String feedsMoved(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count podcasts ont déménagé ($names) – leurs adresses ont été mises à jour.',
      one: 'Le podcast « $names » a déménagé – son adresse a été mise à jour.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Passer';

  @override
  String get chapterSkipHint =>
      'Passer des chapitres pendant la lecture (jusqu’au redémarrage de l’application)';

  @override
  String get backgroundPlayback => 'Lecture en arrière-plan';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Batterie : Non restreinte ✓ – touchez pour les réglages de l’application';

  @override
  String get backgroundPlaybackRestricted =>
      'L’optimisation de la batterie est active : Android peut arrêter la lecture écran éteint. Touchez pour ouvrir les réglages de l’application → Batterie → « Non restreinte ».';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes non écoutés',
      one: '1 épisode non écouté',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'L’épisode n’a pas pu être chargé. Vérifiez votre connexion Internet.';

  @override
  String get playbackStalled =>
      'La lecture s’est bloquée et a été mise en pause. La position est enregistrée – vérifiez votre connexion.';

  @override
  String get sleepTimer => 'Minuteur de mise en veille';

  @override
  String get sleepTimerOff => 'Désactivé';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get sleepTimerEpisodeEnd => 'Jusqu’à la fin de l’épisode';

  @override
  String get sleepTimerEpisodeEndShort => 'Fin de l’épisode';

  @override
  String sleepTimerLeft(String time) {
    return 'Encore $time';
  }

  @override
  String get playbackBrokenDownload =>
      'Le téléchargement était endommagé et a été supprimé. L’épisode est désormais lu en streaming.';

  @override
  String get playbackEpisodeGone =>
      'Cet épisode n’est plus disponible chez l’éditeur.';

  @override
  String get playbackUnsupported =>
      'Cet épisode est dans un format qui ne peut pas être lu.';

  @override
  String get playbackStreamChanged =>
      'L’épisode est arrivé différemment après le rechargement (p. ex. d’autres publicités) – la position peut être décalée. Les épisodes téléchargés ne sont pas concernés.';

  @override
  String get playbackStreamVaries =>
      'Ce podcast insère des publicités variables en streaming – la reprise peut être imprécise. Astuce : téléchargez l’épisode.';

  @override
  String get playNewEpisodes => 'Lire tous les nouveaux épisodes';

  @override
  String playNewEpisodesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes des 96 dernières heures',
      one: '1 épisode des 96 dernières heures',
      zero: 'Aucun nouvel épisode ces 96 dernières heures',
    );
    return '$_temp0';
  }

  @override
  String get playUnplayedEpisodes => 'Lire tous les épisodes non écoutés';

  @override
  String get addNewEpisodesToPlaylist =>
      'Tous les nouveaux épisodes dans une playlist';

  @override
  String get addUnplayedSinceToPlaylist =>
      'Épisodes non écoutés depuis le … dans une playlist';

  @override
  String get addUnplayedEpisodesToPlaylist =>
      'Tous les épisodes non écoutés dans une playlist';

  @override
  String get podcastMenuPlayNew => 'Lire tous les nouveaux épisodes';

  @override
  String get podcastMenuPlaySince =>
      'Lire les épisodes non écoutés depuis le …';

  @override
  String get podcastMenuPlayUnplayed => 'Lire tous les épisodes non écoutés';

  @override
  String get noUnplayedEpisodes => 'Aucun épisode non écouté.';

  @override
  String episodesAddedNoPlay(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes ajoutés à « $playlist ».',
      one: '1 épisode ajouté à « $playlist ».',
      zero: 'Tous les épisodes étaient déjà dans « $playlist ».',
    );
    return '$_temp0';
  }

  @override
  String episodesAddedToPlaylist(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes ajoutés à « $playlist ».',
      one: '1 épisode ajouté à « $playlist ».',
      zero:
          'Tous les épisodes étaient déjà dans « $playlist » – la lecture démarre.',
    );
    return '$_temp0';
  }

  @override
  String get sleepTimerCustom => 'Durée personnalisée…';

  @override
  String sleepTimerCustomSet(int minutes) {
    return 'Durée personnalisée : $minutes minutes';
  }

  @override
  String get sleepTimerCustomLabel => 'Minutes';

  @override
  String sleepTimerCustomRange(int min, int max) {
    return 'De $min à $max minutes';
  }

  @override
  String get sleepTimerStart => 'Démarrer';

  @override
  String get playUnplayedSince => 'Lire les épisodes non écoutés depuis le …';

  @override
  String get playUnplayedSinceHint => 'Choisir une date';

  @override
  String get playUnplayedSincePick => 'Épisodes non écoutés depuis le';

  @override
  String playUnplayedSinceNone(String date) {
    return 'Aucun épisode non écouté depuis le $date.';
  }

  @override
  String get markUnplayedSince => 'Marquer comme non écouté depuis le …';

  @override
  String get markUnplayedSincePick =>
      'Tous les épisodes écoutés depuis le (inclus)';

  @override
  String markUnplayedSinceConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Marquer $count épisodes écoutés depuis le $date inclus comme non écoutés ?',
      one: 'Marquer 1 épisode écouté depuis le $date inclus comme non écouté ?',
    );
    return '$_temp0';
  }

  @override
  String get markUnplayedSinceHint =>
      'Ils reprennent depuis le début et ne sont plus supprimés automatiquement. Les épisodes en cours restent tels quels.';

  @override
  String markUnplayedSinceNone(String date) {
    return 'Il n’y a pas d’épisodes écoutés depuis le $date.';
  }

  @override
  String markUnplayedSinceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes marqués comme non écoutés',
      one: '1 épisode marqué comme non écouté',
    );
    return '$_temp0';
  }

  @override
  String get markAllPlayed => 'Tout marquer comme écouté';

  @override
  String get markAllUnplayed => 'Tout marquer comme non écouté';

  @override
  String markAllPlayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes comme écoutés',
      one: '1 épisode comme écouté',
    );
    return 'Marquer $_temp0 ?';
  }

  @override
  String markAllUnplayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes écoutés comme non écoutés',
      one: '1 épisode écouté comme non écouté',
    );
    return 'Marquer $_temp0 ?';
  }

  @override
  String get playlistSortDateAscending => 'Trier par date, croissant';

  @override
  String get playlistSortDateDescending => 'Trier par date, décroissant';

  @override
  String get playlistSortNameAscending => 'Trier par nom, croissant';

  @override
  String playlistSortedDateAscending(String name) {
    return '« $name » triée par date (plus anciens d’abord).';
  }

  @override
  String playlistSortedDateDescending(String name) {
    return '« $name » triée par date (plus récents d’abord).';
  }

  @override
  String playlistSortedName(String name) {
    return '« $name » triée par nom (A–Z).';
  }

  @override
  String get playlistResume => 'Reprendre';

  @override
  String get playlistDownloadAll => 'Tout télécharger';

  @override
  String playlistDownloadAllConfirm(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes',
      one: '1 épisode',
    );
    return 'Télécharger $_temp0 de « $name » ?';
  }

  @override
  String playlistDownloadAllSize(String size) {
    return '(env. $size)';
  }

  @override
  String get playlistDownloadAllHint =>
      'Les téléchargements démarrent immédiatement, même via les données mobiles. Les épisodes déjà téléchargés sont ignorés.';

  @override
  String get playlistDownloadAllNone =>
      'Tous les épisodes de cette playlist sont déjà téléchargés.';

  @override
  String playlistDownloadAllStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count téléchargements lancés.',
      one: '1 téléchargement lancé.',
    );
    return '$_temp0';
  }

  @override
  String get infoTitle => 'Info';

  @override
  String get infoAbout => 'À propos de l’application';

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
    return 'Développé par $name';
  }

  @override
  String get infoPrivacy => 'Politique de confidentialité';

  @override
  String get infoSourceCode => 'Code source sur GitHub';

  @override
  String get infoLinkFailed => 'Le lien n’a pas pu être ouvert.';

  @override
  String get infoSourceCodeHint =>
      'Code source, versions et possibilité de soutenir l’application librement';

  @override
  String get language => 'Langue';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePickerWelcome =>
      'Bienvenue dans le Podcatcher « AA-AuralListen »';

  @override
  String get languagePickerTitle => 'Choisir la langue';

  @override
  String get languagePickerHint =>
      'Vous pourrez changer la langue plus tard dans les Options.';

  @override
  String get newLanguageTitle => 'Désormais en français';

  @override
  String get newLanguageBody =>
      'AA-AuralListen est désormais disponible dans votre langue. Voulez-vous changer ? Vous pouvez changer de langue à tout moment dans Options → Langue.';

  @override
  String get newLanguageSwitch => 'Changer';

  @override
  String get newLanguageKeep => 'Pas maintenant';

  @override
  String get notificationChannelPlayback => 'Lecture';
}
