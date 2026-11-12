// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'AA-AuralListen Podcatcher';

  @override
  String get navHome => 'Home';

  @override
  String get navSubscriptions => 'Iscrizioni';

  @override
  String get navPlaylists => 'Playlist';

  @override
  String get navDownloads => 'Download';

  @override
  String get navSettings => 'Opzioni';

  @override
  String get carNew => 'Nuovi';

  @override
  String carNotFound(String query) {
    return 'Nessun risultato per “$query”';
  }

  @override
  String get carNothingToPlay =>
      'Non hai ancora ascoltato nulla – scegli un episodio';

  @override
  String get placeholderComingSoon => 'Prossimamente';

  @override
  String get cancel => 'Annulla';

  @override
  String get loadError => 'Errore di caricamento';

  @override
  String get homeEmpty => 'Ancora nessun episodio';

  @override
  String get homeEmptyHint => 'Iscriviti ai podcast nella scheda “Iscrizioni”.';

  @override
  String get subscriptionsEmpty => 'Ancora nessuna iscrizione';

  @override
  String get subscriptionsEmptyHint =>
      'Aggiungi il tuo primo podcast tramite l’indirizzo RSS.';

  @override
  String get addFeedAction => 'Aggiungi tramite indirizzo RSS';

  @override
  String get addFeedTitle => 'Aggiungi podcast';

  @override
  String get addFeedLabel => 'Indirizzo RSS';

  @override
  String get addFeedHint => 'https://example.com/feed.xml';

  @override
  String get addFeedSubmit => 'Aggiungi';

  @override
  String get subscribeErrorInvalidUrl => 'Questo indirizzo non è valido.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'Sei già iscritto a questo podcast.';

  @override
  String get subscribeErrorNetwork =>
      'Impossibile caricare il feed. Controlla l’indirizzo e la connessione a internet.';

  @override
  String get subscribeErrorNotAFeed =>
      'A questo indirizzo non c’è un feed di podcast.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Impossibile aggiornare $count feed.',
      one: 'Impossibile aggiornare 1 feed.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Podcast non trovato';

  @override
  String get podcastRefreshError => 'Ultimo aggiornamento non riuscito';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi',
      one: '1 episodio',
      zero: 'Nessun episodio',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'Nuovo';

  @override
  String get episodePlayed => 'Ascoltato';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get unsubscribe => 'Annulla iscrizione';

  @override
  String get unsubscribeConfirmTitle => 'Annullare l’iscrizione?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '“$title” e tutti i suoi episodi verranno rimossi dall’app.';
  }

  @override
  String get search => 'Cerca';

  @override
  String get searchHint => 'Cerca podcast';

  @override
  String get searchStart => 'Cerca per titolo, argomento o autore';

  @override
  String get searchStartHint => 'Cerca in Apple Podcasts e fyyd.de';

  @override
  String get searchPopular => 'Popolari';

  @override
  String get searchNew => 'Novità';

  @override
  String get subsSearchHint => 'Cerca nelle iscrizioni';

  @override
  String get subsSearchClose => 'Chiudi ricerca';

  @override
  String get searchClear => 'Cancella';

  @override
  String get subsSearchPodcasts => 'Podcast';

  @override
  String get subsSearchEpisodes => 'Episodi';

  @override
  String get subsSearchNothing => 'Nessun risultato nelle tue iscrizioni';

  @override
  String get subsSearchNothingHint =>
      'Trova nuovi podcast con la ricerca in “Home”.';

  @override
  String get searchNoResults => 'Nessun podcast trovato';

  @override
  String get searchFailed =>
      'Ricerca non riuscita. Controlla la connessione a internet.';

  @override
  String searchPartialFailure(String names) {
    return '$names non raggiungibile – risultati incompleti';
  }

  @override
  String get subscribed => 'Iscritto';

  @override
  String get subscribeAction => 'Iscriviti';

  @override
  String subscribedSnack(String title) {
    return 'Iscritto a “$title”';
  }

  @override
  String get open => 'Apri';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Iscrizioni';

  @override
  String get opmlImport => 'Importa file OPML';

  @override
  String get opmlImportSubtitle => 'Porta qui le iscrizioni da un’altra app';

  @override
  String get opmlInvalid => 'Il file non è un file OPML valido.';

  @override
  String get opmlTooLarge => 'Il file è troppo grande.';

  @override
  String get opmlEmpty => 'Nel file non è stato trovato nessun podcast.';

  @override
  String get opmlConfirmTitle => 'Importare le iscrizioni?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcast trovati.',
      one: '1 podcast trovato.',
    );
    return '$_temp0 Le iscrizioni esistenti vengono saltate.';
  }

  @override
  String get opmlImportAction => 'Importa';

  @override
  String opmlProgress(int done, int total) {
    return 'Importazione $done di $total …';
  }

  @override
  String get opmlResultTitle => 'Importazione completata';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'Nuovi: $added\nGià iscritti: $already\nNon riusciti: $failed';
  }

  @override
  String get opmlResultFailedList => 'Non importati:';

  @override
  String get playerPlay => 'Riproduci';

  @override
  String get playerPause => 'Pausa';

  @override
  String get playerRewind => 'Indietro di 15 secondi';

  @override
  String get playerForward => 'Avanti di 30 secondi';

  @override
  String get playerClose => 'Chiudi player';

  @override
  String get playerOpen => 'Apri player';

  @override
  String get nowPlaying => 'In riproduzione';

  @override
  String get boostTitle => 'Amplificazione volume';

  @override
  String get speedTitle => 'Velocità di riproduzione';

  @override
  String speedOff(String value) {
    return 'Normale ($value)';
  }

  @override
  String get speedNormal => 'normale';

  @override
  String speedButton(String value) {
    return 'Velocità: $value';
  }

  @override
  String get boostOff => 'No';

  @override
  String boostValue(int db) {
    return '+$db dB';
  }

  @override
  String boostButton(String value) {
    return 'Boost: $value';
  }

  @override
  String get speedPerPodcast => 'Solo per questo podcast';

  @override
  String get speedPerPodcastHint =>
      'Altrimenti la velocità vale per tutti i podcast senza impostazione propria.';

  @override
  String get boostPerPodcast => 'Solo per questo podcast';

  @override
  String get boostPerPodcastHint =>
      'Altrimenti il valore vale per tutti i podcast senza impostazione propria.';

  @override
  String get markPlayed => 'Segna come ascoltato';

  @override
  String get markUnplayed => 'Segna come non ascoltato';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get download => 'Scarica';

  @override
  String get episodeNumberingSeasons =>
      'Podcast con stagioni: valgono i numeri del feed per stagione (es. “S2·5”). Qui non è possibile un conteggio proprio.';

  @override
  String get episodeNumberOffsetSeasons =>
      'Non possibile per i podcast con stagioni.';

  @override
  String get seasonAll => 'Tutte';

  @override
  String seasonLabel(int season) {
    return 'Stagione $season';
  }

  @override
  String get podcastWebsite => 'Sito web';

  @override
  String get podcastSupport => 'Sostieni';

  @override
  String get playlistContinueOffer =>
      'Tocca per continuare alla fine con il prossimo episodio di questa playlist';

  @override
  String get downloadCancel => 'Annulla download';

  @override
  String get downloadDelete => 'Elimina download';

  @override
  String get downloadRetry => 'Scarica di nuovo';

  @override
  String get downloadDone => 'Scaricato';

  @override
  String get episodeInPlaylist => 'In una playlist';

  @override
  String get episodeVideo => 'Episodio video';

  @override
  String get videoFullscreen => 'Schermo intero';

  @override
  String get videoExitFullscreen => 'Esci da schermo intero';

  @override
  String get videoPicture => 'Immagine negli episodi video';

  @override
  String get videoPictureHint =>
      'Disattivato: solo audio, risparmia batteria. In streaming l’immagine viene comunque scaricata.';

  @override
  String get videoPip => 'Picture-in-picture';

  @override
  String get videoPipHint =>
      'Uscendo dall’app, il video continua in una piccola finestra.';

  @override
  String get videoDownloadTitle => 'Scaricare l’episodio video?';

  @override
  String videoDownloadSize(String size) {
    return 'Gli episodi video sono grandi: questo occupa circa $size.';
  }

  @override
  String get videoDownloadLarge =>
      'Gli episodi video di solito sono molto grandi.';

  @override
  String get videoDownloadNow => 'Scarica ora';

  @override
  String get playlistDownloadAllVideoWifi =>
      'Gli episodi video si scaricano solo via Wi-Fi.';

  @override
  String get downloadFailed => 'Download non riuscito';

  @override
  String get downloadQueued => 'In attesa …';

  @override
  String get downloadWifiWaiting => 'In attesa del Wi-Fi …';

  @override
  String get downloadNowMobile => 'Scarica ora con i dati mobili';

  @override
  String downloadDeleteConfirm(String title) {
    return 'Eliminare “$title” dal dispositivo? L’episodio resta nell’app e si può ancora ascoltare in streaming.';
  }

  @override
  String get detailsEpisode => 'Episodio';

  @override
  String get detailsAuthor => 'Autore';

  @override
  String get detailsPublished => 'Pubblicato';

  @override
  String get detailsDuration => 'Durata';

  @override
  String get detailsSize => 'Dimensione';

  @override
  String get detailsDownloadedAt => 'Scaricato';

  @override
  String get detailsStatus => 'Download';

  @override
  String get detailsListening => 'Stato di ascolto';

  @override
  String detailsInProgress(String position) {
    return 'Iniziato, a $position';
  }

  @override
  String detailsPlayedAt(String date) {
    return 'Ascoltato il $date';
  }

  @override
  String get downloadsEmpty => 'Nessun download';

  @override
  String get downloadsEmptyHint =>
      'Tieni premuto un episodio → “Scarica”, oppure attiva il download automatico nelle impostazioni del podcast.';

  @override
  String downloadsUsage(String used, String limit) {
    return '$used di $limit usati';
  }

  @override
  String get cleanUpNow => 'Fai pulizia ora';

  @override
  String cleanUpResult(String freed) {
    return '$freed liberati';
  }

  @override
  String get cleanUpNothing => 'Tutto in ordine – niente da eliminare.';

  @override
  String get podcastSettings => 'Impostazioni del podcast';

  @override
  String get autoDownload => 'Scarica automaticamente';

  @override
  String get autoDownloadOff => 'Disattivato';

  @override
  String get autoDownloadWifi => 'Solo Wi-Fi';

  @override
  String get autoDownloadAlways => 'Sempre';

  @override
  String get autoDownloadMax => 'Numero di episodi non ascoltati sul telefono';

  @override
  String get autoDownloadMaxHint =>
      'I nuovi episodi vengono scaricati finché sul telefono ce ne sono tanti non ascoltati. Non viene eliminato nulla.';

  @override
  String get autoDownloadPlaylist => 'Aggiungi i nuovi episodi alla playlist';

  @override
  String get autoDownloadPlaylistNone => 'Nessuna';

  @override
  String get autoDownloadPlaylistHint =>
      'Senza download automatico, i nuovi episodi vengono solo aggiunti e ascoltati in streaming. Se la playlist è stata eliminata, l’app la ricrea la volta successiva.';

  @override
  String get episodeCounter => 'Numero dell’episodio sulla copertina';

  @override
  String get episodeCounterHint =>
      'Una striscia sottile sul bordo sinistro delle copertine negli elenchi di episodi.';

  @override
  String get episodeNumbering => 'Numerazione';

  @override
  String get episodeNumberingFeed => 'Numeri del feed';

  @override
  String get episodeNumberingOwn => 'Conteggio proprio';

  @override
  String get episodeNumberOffset => 'Scostamento del conteggio';

  @override
  String get episodeNumberOffsetHint =>
      'Si somma al conteggio dall’episodio più vecchio – es. −1 perché diventi 0.';

  @override
  String get episodeNumberOffsetFeed =>
      'Lo scostamento vale solo per il conteggio proprio.';

  @override
  String get episodeNumberDecrease => 'Diminuisci';

  @override
  String get episodeNumberIncrease => 'Aumenta';

  @override
  String get autoDeletePlayed => 'Elimina gli episodi ascoltati';

  @override
  String get autoDeletePlayedHint =>
      '96 ore dopo che un episodio è stato ascoltato fino alla fine';

  @override
  String get settingsSectionDownloads => 'Download';

  @override
  String get downloadLimit => 'Limite di spazio per i download';

  @override
  String get downloadLimitHint =>
      'Raggiunto il limite, vengono eliminati prima gli episodi ascoltati. Gli episodi non ascoltati non vengono mai eliminati automaticamente – in quel caso non si scarica nulla di nuovo.';

  @override
  String get playlistNew => 'Nuova playlist';

  @override
  String get playlistName => 'Nome';

  @override
  String get playlistNameTaken => 'Esiste già una playlist con questo nome.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stelle',
      one: '1 stella',
    );
    return '$_temp0';
  }

  @override
  String get ratingRemove => 'Rimuovi valutazione';

  @override
  String get subsProvisional => 'Provvisori';

  @override
  String get podcastAdd => 'Aggiungi';

  @override
  String get podcastInAbos => 'Già nelle tue iscrizioni';

  @override
  String addedProvisionalSnack(String title) {
    return '“$title” aggiunto provvisoriamente';
  }

  @override
  String get podcastRemove => 'Rimuovi';

  @override
  String get podcastRemoveConfirmTitle => 'Rimuovere il podcast?';

  @override
  String playlistActivated(String name) {
    return 'La playlist “$name” è attiva';
  }

  @override
  String get playlistOpen => 'Apri playlist';

  @override
  String get finishedRemoval => 'Rimuovi gli episodi finiti dalla playlist';

  @override
  String get finishedRemovalHint =>
      'Vale per gli episodi ascoltati fino alla fine e per “Segna come ascoltato” (anche “Tutti” e “fino al …”).';

  @override
  String get finishedRemovalNow => 'Subito';

  @override
  String get finishedRemovalAfter5Minutes => 'Dopo 5 minuti';

  @override
  String get finishedRemovalNever => 'Mai';

  @override
  String get autoMarkNewPlayed =>
      'Segna automaticamente i nuovi come ascoltati';

  @override
  String chapterProgress(int percent) {
    return '$percent%';
  }

  @override
  String averageEpisodeLength(String duration) {
    return 'Ø $duration per episodio';
  }

  @override
  String get averageEpisodeLengthUnknown => 'Durata media sconosciuta';

  @override
  String get episodeHot => 'Preferito: ascolti quasi sempre questo podcast';

  @override
  String get playlistColor => 'Colore…';

  @override
  String get playlistColorNone => 'Nessun colore';

  @override
  String get colorRed => 'Rosso';

  @override
  String get colorOrange => 'Arancione';

  @override
  String get colorYellow => 'Giallo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Blu';

  @override
  String get colorIndigo => 'Indaco';

  @override
  String get colorViolet => 'Viola';

  @override
  String get appColor => 'Colore dell’app';

  @override
  String get appColorWallpaper => 'Come lo sfondo';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Porpora';

  @override
  String get colorTeal => 'Verde acqua';

  @override
  String get colorBrown => 'Marrone';

  @override
  String get playlistRename => 'Rinomina';

  @override
  String get playlistDelete => 'Elimina playlist';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Eliminare “$name”? Gli episodi in sé restano.';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get create => 'Crea';

  @override
  String get playlistsEmpty => 'Nessuna playlist';

  @override
  String get playlistEmpty => 'Questa playlist è vuota';

  @override
  String get playlistEmptyHint =>
      'Tieni premuto un episodio → “Aggiungi a playlist…”';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi',
      one: '1 episodio',
      zero: 'Vuota',
    );
    return '$_temp0$duration';
  }

  @override
  String get addToPlaylist => 'Aggiungi a playlist…';

  @override
  String get playNext => 'Riproduci dopo';

  @override
  String playNextHint(String playlist) {
    return 'Subito dopo l’episodio attuale in “$playlist”';
  }

  @override
  String playNextDone(String playlist) {
    return 'Sarà il prossimo in “$playlist”.';
  }

  @override
  String appendToPlaylist(String playlist) {
    return 'Aggiungi in fondo a “$playlist”';
  }

  @override
  String appendToPlaylistDone(String playlist) {
    return 'Aggiunto in fondo a “$playlist”.';
  }

  @override
  String get episodeDescription => 'Descrizione';

  @override
  String episodeNumberLabel(String number) {
    return 'Episodio $number';
  }

  @override
  String get episodeNoDescription => 'Questo episodio non ha una descrizione.';

  @override
  String addedToPlaylist(String name) {
    return 'Aggiunto a “$name”';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Già in “$name”';
  }

  @override
  String get removedFromPlaylist => 'Rimosso dalla playlist';

  @override
  String get removeFromPlaylistTitle => 'Rimuovere dalla playlist?';

  @override
  String removeFromPlaylistBody(String name) {
    return 'L’episodio è già in “$name”. Vuoi rimuoverlo da lì?';
  }

  @override
  String get removeFromPlaylistAction => 'Rimuovi';

  @override
  String removedFromNamedPlaylist(String name) {
    return 'Rimosso da “$name”';
  }

  @override
  String get undo => 'Annulla';

  @override
  String get playerNext => 'Episodio successivo';

  @override
  String get playerPrevious => 'Episodio precedente';

  @override
  String playingFromPlaylist(String name) {
    return 'Dalla playlist “$name”';
  }

  @override
  String get dragToReorder => 'Trascina per riordinare';

  @override
  String get autoDownloadThemes =>
      'Argomenti per download automatico e playlist';

  @override
  String get autoDownloadThemesHint =>
      'Solo gli argomenti selezionati vengono scaricati o aggiunti alla playlist automaticamente. I nuovi argomenti solo dopo averli selezionati qui.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi',
      one: '1 episodio',
    );
    return '$_temp0 · ultimo il $date';
  }

  @override
  String get selectAll => 'Tutti';

  @override
  String get selectNone => 'Nessuno';

  @override
  String get chapters => 'Capitoli';

  @override
  String chaptersCount(int count) {
    return 'Capitoli ($count)';
  }

  @override
  String chapterCurrent(int index, int count, String title) {
    return 'Capitolo $index/$count: $title';
  }

  @override
  String get descriptionMore => 'Leggi tutto';

  @override
  String get descriptionLess => 'Mostra meno';

  @override
  String get bookmarkAdd => 'Aggiungi segnalibro';

  @override
  String bookmarkListHint(int count) {
    return 'Pressione lunga: elenco dei segnalibri ($count)';
  }

  @override
  String get bookmarkNote => 'Nota (facoltativa)';

  @override
  String bookmarkAdded(String time) {
    return 'Segnalibro aggiunto a $time';
  }

  @override
  String get bookmarks => 'Segnalibri';

  @override
  String bookmarksCount(int count) {
    return 'Segnalibri ($count)';
  }

  @override
  String get bookmarksEmpty => 'Nessun segnalibro';

  @override
  String get history => 'Cronologia di ascolto';

  @override
  String get historySubtitle =>
      'Gli ultimi 100 episodi ascoltati fino alla fine';

  @override
  String get historyEmpty => 'Ancora nessun episodio ascoltato fino alla fine';

  @override
  String get historyEmptyHint =>
      'Gli episodi compaiono qui dopo essere stati ascoltati fino alla fine.';

  @override
  String get historyClear => 'Cancella cronologia';

  @override
  String get historyClearConfirm =>
      'Cancellare tutta la cronologia di ascolto? Episodi e posizioni di ascolto restano.';

  @override
  String get historyClearAction => 'Cancella';

  @override
  String get historyEpisodeGone =>
      'Questo episodio non è più nelle tue iscrizioni.';

  @override
  String get bookmarksEmptyHint => 'Tocca “Aggiungi segnalibro” nel player.';

  @override
  String refreshProgress(int current, int total, String title) {
    return '$current di $total · $title';
  }

  @override
  String get bookmarkDeleted => 'Segnalibro eliminato';

  @override
  String get bookmarkDelete => 'Eliminare il segnalibro?';

  @override
  String bookmarkDeleteConfirm(String name) {
    return 'Eliminare davvero “$name”?';
  }

  @override
  String get bookmarkEditNote => 'Modifica nota';

  @override
  String get settingsSectionListening => 'Ascolto';

  @override
  String get markPlayedUntil => 'Segna come ascoltati fino al …';

  @override
  String get markPlayedUntilPick => 'Tutti gli episodi fino al (incluso)';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Segnare $count episodi fino al $date (incluso) come ascoltati?',
      one: 'Segnare 1 episodio fino al $date (incluso) come ascoltato?',
    );
    return '$_temp0';
  }

  @override
  String get markPlayedUntilHint =>
      'Escono dalle playlist (quando: vedi “Rimuovi gli episodi finiti dalla playlist” nelle opzioni); gli episodi scaricati vengono eliminati dopo 96 ore.';

  @override
  String markPlayedUntilNone(String date) {
    return 'Non ci sono episodi non ascoltati fino al $date.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi segnati come ascoltati',
      one: '1 episodio segnato come ascoltato',
    );
    return '$_temp0';
  }

  @override
  String get markAction => 'Segna';

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get designTitle => 'Design';

  @override
  String get designSubtitle =>
      'Chiaro/scuro, colore dell’app, comandi del player';

  @override
  String get designSectionPanel => 'Comandi del player';

  @override
  String get designPanelHint =>
      'Lo sfondo dietro la barra di avanzamento e i pulsanti del player a schermo intero. Segue la modalità chiaro/scuro e il colore dell’app.';

  @override
  String get panelDesignPlain => 'Semplice';

  @override
  String get panelDesignStars => 'Cielo stellato';

  @override
  String get panelDesignAurora => 'Aurora boreale';

  @override
  String get panelDesignWaves => 'Onde';

  @override
  String get panelDesignFacets => 'Cristallo';

  @override
  String get panelDesignCamouflage => 'Mimetico';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get opmlExport => 'Esporta iscrizioni come OPML';

  @override
  String get opmlExportSubtitle => 'Per altre app di podcast';

  @override
  String get opmlExported => 'Iscrizioni esportate';

  @override
  String get backupCreate => 'Crea backup';

  @override
  String get backupCreateSubtitle =>
      'Iscrizioni, progressi, playlist, segnalibri, cronologia, impostazioni – senza file audio';

  @override
  String get backupCreated => 'Backup salvato';

  @override
  String get backupRestore => 'Ripristina backup';

  @override
  String get backupRestoreSubtitle => 'Sostituisce tutti i dati attuali';

  @override
  String get backupInvalid => 'Il file non è un backup valido di questa app.';

  @override
  String get backupTooNew =>
      'Il backup proviene da una versione più recente dell’app.';

  @override
  String get backupConfirmTitle => 'Ripristinare il backup?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Backup del $date:\n$podcasts iscrizioni · $episodes episodi · $playlists playlist · $bookmarks segnalibri\n\nTutti i dati attuali verranno sostituiti. Gli episodi scaricati verranno eliminati.';
  }

  @override
  String get backupRestoreAction => 'Ripristina';

  @override
  String get backupRestored => 'Backup ripristinato';

  @override
  String get saveFailed => 'Salvataggio non riuscito';

  @override
  String get feedUrl => 'Indirizzo del feed';

  @override
  String get feedUrlChange => 'Cambia indirizzo del feed';

  @override
  String get feedUrlChangeHint =>
      'Serve solo se il podcast si è trasferito e il vecchio indirizzo non funziona più. Progressi e download restano.';

  @override
  String get feedUrlChangeSubmit => 'Applica';

  @override
  String get feedUrlChanged => 'Indirizzo del feed cambiato.';

  @override
  String get feedUrlTaken =>
      'Questo indirizzo appartiene già a un’altra iscrizione.';

  @override
  String feedsMoved(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count podcast si sono trasferiti ($names) – gli indirizzi sono stati aggiornati.',
      one:
          'Il podcast “$names” si è trasferito – l’indirizzo è stato aggiornato.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Salta';

  @override
  String get chapterSkipHint =>
      'Salta capitoli durante la riproduzione (fino al riavvio dell’app)';

  @override
  String get backgroundPlayback => 'Riproduzione in background';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Batteria: Senza limitazioni ✓ – tocca per le impostazioni dell’app';

  @override
  String get backgroundPlaybackRestricted =>
      'L’ottimizzazione della batteria è attiva: Android può interrompere la riproduzione a schermo spento. Tocca per aprire le impostazioni dell’app → Batteria → “Senza limitazioni”.';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi non ascoltati',
      one: '1 episodio non ascoltato',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'Impossibile caricare l’episodio. Controlla la connessione a internet.';

  @override
  String get playbackStalled =>
      'La riproduzione si è bloccata ed è stata messa in pausa. La posizione è salvata – controlla la connessione.';

  @override
  String get sleepTimer => 'Timer di spegnimento';

  @override
  String get sleepTimerOff => 'Disattivato';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minuti';
  }

  @override
  String get sleepTimerEpisodeEnd => 'Fino alla fine dell’episodio';

  @override
  String get sleepTimerEpisodeEndShort => 'Fine episodio';

  @override
  String sleepTimerLeft(String time) {
    return 'Ancora $time';
  }

  @override
  String get playbackBrokenDownload =>
      'Il download era danneggiato ed è stato eliminato. Ora l’episodio viene riprodotto in streaming.';

  @override
  String get playbackEpisodeGone =>
      'Questo episodio non è più disponibile presso il fornitore.';

  @override
  String get playbackUnsupported =>
      'Questo episodio è in un formato che non si può riprodurre.';

  @override
  String get playbackStreamChanged =>
      'Dopo il ricaricamento l’episodio è arrivato diverso (es. altre pubblicità) – la posizione potrebbe non corrispondere. Gli episodi scaricati non sono interessati.';

  @override
  String get playbackStreamVaries =>
      'Questo podcast inserisce pubblicità variabili in streaming – la ripresa può essere imprecisa. Consiglio: scarica l’episodio.';

  @override
  String get playNewEpisodes => 'Riproduci tutti i nuovi episodi';

  @override
  String playNewEpisodesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi delle ultime 96 ore',
      one: '1 episodio delle ultime 96 ore',
      zero: 'Nessun nuovo episodio nelle ultime 96 ore',
    );
    return '$_temp0';
  }

  @override
  String get playUnplayedEpisodes =>
      'Riproduci tutti gli episodi non ascoltati';

  @override
  String get addNewEpisodesToPlaylist =>
      'Tutti i nuovi episodi in una playlist';

  @override
  String get addUnplayedSinceToPlaylist =>
      'Episodi non ascoltati dal … in una playlist';

  @override
  String get addUnplayedEpisodesToPlaylist =>
      'Tutti gli episodi non ascoltati in una playlist';

  @override
  String get podcastMenuPlayNew => 'Riproduci tutti i nuovi episodi';

  @override
  String get podcastMenuPlaySince => 'Riproduci episodi non ascoltati dal …';

  @override
  String get podcastMenuPlayUnplayed =>
      'Riproduci tutti gli episodi non ascoltati';

  @override
  String get noUnplayedEpisodes => 'Nessun episodio non ascoltato.';

  @override
  String episodesAddedNoPlay(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi aggiunti a “$playlist”.',
      one: '1 episodio aggiunto a “$playlist”.',
      zero: 'Tutti gli episodi erano già in “$playlist”.',
    );
    return '$_temp0';
  }

  @override
  String episodesAddedToPlaylist(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi aggiunti a “$playlist”.',
      one: '1 episodio aggiunto a “$playlist”.',
      zero:
          'Tutti gli episodi erano già in “$playlist” – la riproduzione inizia.',
    );
    return '$_temp0';
  }

  @override
  String get sleepTimerCustom => 'Tempo personalizzato…';

  @override
  String sleepTimerCustomSet(int minutes) {
    return 'Tempo personalizzato: $minutes minuti';
  }

  @override
  String get sleepTimerCustomLabel => 'Minuti';

  @override
  String sleepTimerCustomRange(int min, int max) {
    return 'Da $min a $max minuti';
  }

  @override
  String get sleepTimerStart => 'Avvia';

  @override
  String get playUnplayedSince => 'Riproduci episodi non ascoltati dal …';

  @override
  String get playUnplayedSinceHint => 'Scegli una data';

  @override
  String get playUnplayedSincePick => 'Episodi non ascoltati dal';

  @override
  String playUnplayedSinceNone(String date) {
    return 'Nessun episodio non ascoltato dal $date.';
  }

  @override
  String get markUnplayedSince => 'Segna come non ascoltati dal …';

  @override
  String get markUnplayedSincePick =>
      'Tutti gli episodi ascoltati dal (incluso)';

  @override
  String markUnplayedSinceConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Segnare $count episodi ascoltati dal $date (incluso) come non ascoltati?',
      one:
          'Segnare 1 episodio ascoltato dal $date (incluso) come non ascoltato?',
    );
    return '$_temp0';
  }

  @override
  String get markUnplayedSinceHint =>
      'Ripartono dall’inizio e non vengono più eliminati automaticamente. Gli episodi iniziati restano come sono.';

  @override
  String markUnplayedSinceNone(String date) {
    return 'Non ci sono episodi ascoltati dal $date.';
  }

  @override
  String markUnplayedSinceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodi segnati come non ascoltati',
      one: '1 episodio segnato come non ascoltato',
    );
    return '$_temp0';
  }

  @override
  String get markAllPlayed => 'Segna tutto come ascoltato';

  @override
  String get markAllUnplayed => 'Segna tutto come non ascoltato';

  @override
  String markAllPlayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Segnare $count episodi come ascoltati?',
      one: 'Segnare 1 episodio come ascoltato?',
    );
    return '$_temp0';
  }

  @override
  String markAllUnplayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Segnare $count episodi ascoltati come non ascoltati?',
      one: 'Segnare 1 episodio ascoltato come non ascoltato?',
    );
    return '$_temp0';
  }

  @override
  String get playlistSortDateAscending => 'Ordina per data, crescente';

  @override
  String get playlistSortDateDescending => 'Ordina per data, decrescente';

  @override
  String get playlistSortNameAscending => 'Ordina per nome, crescente';

  @override
  String playlistSortedDateAscending(String name) {
    return '“$name” ordinata per data (prima i più vecchi).';
  }

  @override
  String playlistSortedDateDescending(String name) {
    return '“$name” ordinata per data (prima i più recenti).';
  }

  @override
  String playlistSortedName(String name) {
    return '“$name” ordinata per nome (A–Z).';
  }

  @override
  String get playlistResume => 'Riprendi';

  @override
  String get playlistDownloadAll => 'Scarica tutto';

  @override
  String playlistDownloadAllConfirm(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scaricare $count episodi da “$name”?',
      one: 'Scaricare 1 episodio da “$name”?',
    );
    return '$_temp0';
  }

  @override
  String playlistDownloadAllSize(String size) {
    return '(circa $size)';
  }

  @override
  String get playlistDownloadAllHint =>
      'I download partono subito, anche con i dati mobili. Gli episodi già scaricati vengono saltati.';

  @override
  String get playlistDownloadAllNone =>
      'Tutti gli episodi di questa playlist sono già scaricati.';

  @override
  String playlistDownloadAllStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count download avviati.',
      one: '1 download avviato.',
    );
    return '$_temp0';
  }

  @override
  String get infoTitle => 'Info';

  @override
  String get infoAbout => 'Informazioni sull’app';

  @override
  String infoVersion(String name, int build) {
    return 'Versione $name (build $build)';
  }

  @override
  String infoVersionShort(String name) {
    return 'Versione $name';
  }

  @override
  String infoDeveloper(String name) {
    return 'Sviluppato da $name';
  }

  @override
  String get infoPrivacy => 'Informativa sulla privacy';

  @override
  String get infoSourceCode => 'Codice sorgente su GitHub';

  @override
  String get infoLinkFailed => 'Impossibile aprire il link.';

  @override
  String get infoSourceCodeHint =>
      'Codice sorgente, versioni e possibilità di sostenere l’app volontariamente';

  @override
  String get language => 'Lingua';

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
      'Benvenuto nel Podcatcher “AA-AuralListen”';

  @override
  String get languagePickerTitle => 'Scegli la lingua';

  @override
  String get languagePickerHint =>
      'Potrai cambiare la lingua più tardi nelle Opzioni.';

  @override
  String get newLanguageTitle => 'Ora anche in italiano';

  @override
  String get newLanguageBody =>
      'AA-AuralListen ora è disponibile nella tua lingua. Vuoi passare all’italiano? Puoi cambiare lingua in qualsiasi momento in Opzioni → Lingua.';

  @override
  String get newLanguageSwitch => 'Cambia';

  @override
  String get newLanguageKeep => 'Non ora';

  @override
  String get notificationChannelPlayback => 'Riproduzione';

  @override
  String get autoSleepTitle => 'Timer di spegnimento automatico';

  @override
  String get autoSleepModeOff => 'Disattivato';

  @override
  String get autoSleepModeDaily => 'Attivo';

  @override
  String get autoSleepModeWeekdays => 'Per giorno';

  @override
  String get autoSleepIntro =>
      'Se premi Riproduci nell’app all’interno della fascia oraria, il timer di spegnimento parte automaticamente. Un timer già in corso resta com’è. Non parte mai da Android Auto, dalla notifica, dalla schermata di blocco o dai tasti Bluetooth. Se lo disattivi, quella notte non riparte.';

  @override
  String get autoSleepDuration => 'Durata del timer';

  @override
  String get autoSleepWindow => 'Fascia oraria';

  @override
  String get autoSleepWindowsPerDay => 'Fascia oraria per giorno';

  @override
  String autoSleepFrom(String time) {
    return 'Dalle $time';
  }

  @override
  String autoSleepUntil(String time) {
    return 'Alle $time';
  }

  @override
  String get autoSleepPickStart => 'Inizio';

  @override
  String get autoSleepPickEnd => 'Fine';

  @override
  String get autoSleepSameTimeError =>
      'Inizio e fine non possono coincidere: la fascia oraria durerebbe 0 minuti. La modifica non è stata applicata.';

  @override
  String get autoSleepMidnightHint =>
      'Una fascia oraria oltre la mezzanotte appartiene al giorno in cui inizia: «venerdì dalle 22:00 alle 04:00» vale da venerdì sera fino a sabato mattina alle 04:00.';

  @override
  String get autoSleepCopyToAll => 'Applica a tutti i giorni';

  @override
  String autoSleepCopiedToAll(String day) {
    return 'Orari di $day applicati a tutti i giorni';
  }

  @override
  String get autoSleepAllDaysOff =>
      'Tutti i giorni sono disattivati: il timer automatico non partirà mai.';

  @override
  String autoSleepStarted(String timer) {
    return 'Timer di spegnimento avviato automaticamente: $timer';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String autoSleepSpanSameDay(String length) {
    return 'Durata $length';
  }

  @override
  String autoSleepSpanNextDay(String length) {
    return 'Durata $length, termina il giorno dopo';
  }

  @override
  String autoSleepOverlapError(String day, String window) {
    return 'Si sovrappone a $day ($window). La modifica non è stata applicata.';
  }
}
