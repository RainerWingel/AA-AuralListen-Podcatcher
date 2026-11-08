// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AA-AuralListen Podcatcher';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSubscriptions => 'Suscritos';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navDownloads => 'Descargas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get carNew => 'Nuevos';

  @override
  String carNotFound(String query) {
    return 'No se encontró nada para “$query”';
  }

  @override
  String get carNothingToPlay =>
      'Aún no has escuchado nada – elige un episodio';

  @override
  String get placeholderComingSoon => 'Próximamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get loadError => 'Error al cargar';

  @override
  String get homeEmpty => 'Aún no hay episodios';

  @override
  String get homeEmptyHint =>
      'Suscríbete a podcasts en la pestaña “Suscritos”.';

  @override
  String get subscriptionsEmpty => 'Aún no tienes suscripciones';

  @override
  String get subscriptionsEmptyHint =>
      'Añade tu primer podcast con su dirección RSS.';

  @override
  String get addFeedAction => 'Añadir por dirección RSS';

  @override
  String get addFeedTitle => 'Añadir podcast';

  @override
  String get addFeedLabel => 'Dirección RSS';

  @override
  String get addFeedHint => 'https://example.com/feed.xml';

  @override
  String get addFeedSubmit => 'Añadir';

  @override
  String get subscribeErrorInvalidUrl => 'Esta dirección no es válida.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'Ya estás suscrito a este podcast.';

  @override
  String get subscribeErrorNetwork =>
      'No se pudo cargar el feed. Comprueba la dirección y tu conexión a internet.';

  @override
  String get subscribeErrorNotAFeed =>
      'En esta dirección no hay ningún feed de podcast.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron actualizar $count feeds.',
      one: 'No se pudo actualizar 1 feed.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Podcast no encontrado';

  @override
  String get podcastRefreshError => 'La última actualización falló';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios',
      one: '1 episodio',
      zero: 'Ningún episodio',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'Nuevo';

  @override
  String get episodePlayed => 'Escuchado';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get unsubscribe => 'Cancelar suscripción';

  @override
  String get unsubscribeConfirmTitle => '¿Cancelar suscripción?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '“$title” y todos sus episodios se eliminarán de la app.';
  }

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar podcasts';

  @override
  String get searchStart => 'Busca por título, tema o autor';

  @override
  String get searchStartHint => 'Busca en Apple Podcasts y fyyd.de';

  @override
  String get searchPopular => 'Populares';

  @override
  String get searchNew => 'Novedades';

  @override
  String get subsSearchHint => 'Buscar en suscripciones';

  @override
  String get subsSearchClose => 'Cerrar búsqueda';

  @override
  String get searchClear => 'Borrar';

  @override
  String get subsSearchPodcasts => 'Podcasts';

  @override
  String get subsSearchEpisodes => 'Episodios';

  @override
  String get subsSearchNothing => 'No se encontró nada en tus suscripciones';

  @override
  String get subsSearchNothingHint =>
      'Encuentra podcasts nuevos con la búsqueda de “Inicio”.';

  @override
  String get searchNoResults => 'No se encontraron podcasts';

  @override
  String get searchFailed =>
      'La búsqueda falló. Comprueba tu conexión a internet.';

  @override
  String searchPartialFailure(String names) {
    return '$names no disponible – resultados incompletos';
  }

  @override
  String get subscribed => 'Suscrito';

  @override
  String get subscribeAction => 'Suscribirse';

  @override
  String subscribedSnack(String title) {
    return 'Suscrito a “$title”';
  }

  @override
  String get open => 'Abrir';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Suscripciones';

  @override
  String get opmlImport => 'Importar archivo OPML';

  @override
  String get opmlImportSubtitle => 'Trae tus suscripciones de otra app';

  @override
  String get opmlInvalid => 'El archivo no es un archivo OPML válido.';

  @override
  String get opmlTooLarge => 'El archivo es demasiado grande.';

  @override
  String get opmlEmpty => 'No se encontraron podcasts en el archivo.';

  @override
  String get opmlConfirmTitle => '¿Importar suscripciones?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts encontrados.',
      one: '1 podcast encontrado.',
    );
    return '$_temp0 Las suscripciones existentes se omiten.';
  }

  @override
  String get opmlImportAction => 'Importar';

  @override
  String opmlProgress(int done, int total) {
    return 'Importando $done de $total …';
  }

  @override
  String get opmlResultTitle => 'Importación terminada';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'Nuevos: $added\nYa suscrito: $already\nFallidos: $failed';
  }

  @override
  String get opmlResultFailedList => 'No importados:';

  @override
  String get playerPlay => 'Reproducir';

  @override
  String get playerPause => 'Pausa';

  @override
  String get playerRewind => 'Retroceder 15 segundos';

  @override
  String get playerForward => 'Avanzar 30 segundos';

  @override
  String get playerClose => 'Cerrar reproductor';

  @override
  String get playerOpen => 'Abrir reproductor';

  @override
  String get nowPlaying => 'Reproduciendo';

  @override
  String get boostTitle => 'Amplificación de volumen';

  @override
  String get speedTitle => 'Velocidad de reproducción';

  @override
  String speedOff(String value) {
    return 'Normal ($value)';
  }

  @override
  String speedButton(String value) {
    return 'Velocidad: $value';
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
  String get speedPerPodcast => 'Solo para este podcast';

  @override
  String get speedPerPodcastHint =>
      'Si no, la velocidad se aplica a todos los podcasts sin ajuste propio.';

  @override
  String get boostPerPodcast => 'Solo para este podcast';

  @override
  String get boostPerPodcastHint =>
      'Si no, el valor se aplica a todos los podcasts sin ajuste propio.';

  @override
  String get markPlayed => 'Marcar como escuchado';

  @override
  String get markUnplayed => 'Marcar como no escuchado';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get download => 'Descargar';

  @override
  String get episodeNumberingSeasons =>
      'Podcast con temporadas: se usan los números del feed por temporada (p. ej. “S2·5”). Aquí no es posible un conteo propio.';

  @override
  String get episodeNumberOffsetSeasons =>
      'No es posible en podcasts con temporadas.';

  @override
  String get seasonAll => 'Todas';

  @override
  String seasonLabel(int season) {
    return 'Temporada $season';
  }

  @override
  String get podcastWebsite => 'Sitio web';

  @override
  String get podcastSupport => 'Apoyar';

  @override
  String get playlistContinueOffer =>
      'Toca para seguir al final con el siguiente episodio de esta playlist';

  @override
  String get downloadCancel => 'Cancelar descarga';

  @override
  String get downloadDelete => 'Eliminar descarga';

  @override
  String get downloadRetry => 'Descargar de nuevo';

  @override
  String get downloadDone => 'Descargado';

  @override
  String get episodeInPlaylist => 'En una playlist';

  @override
  String get downloadFailed => 'La descarga falló';

  @override
  String get downloadQueued => 'Esperando …';

  @override
  String get downloadWifiWaiting => 'Esperando wifi …';

  @override
  String get downloadNowMobile => 'Descargar ahora con datos móviles';

  @override
  String downloadDeleteConfirm(String title) {
    return '¿Eliminar “$title” del dispositivo? El episodio sigue en la app y se puede seguir escuchando en streaming.';
  }

  @override
  String get detailsEpisode => 'Episodio';

  @override
  String get detailsAuthor => 'Autor';

  @override
  String get detailsPublished => 'Publicado';

  @override
  String get detailsDuration => 'Duración';

  @override
  String get detailsSize => 'Tamaño';

  @override
  String get detailsDownloadedAt => 'Descargado';

  @override
  String get detailsStatus => 'Descarga';

  @override
  String get detailsListening => 'Estado de escucha';

  @override
  String detailsInProgress(String position) {
    return 'Empezado, en $position';
  }

  @override
  String detailsPlayedAt(String date) {
    return 'Escuchado el $date';
  }

  @override
  String get downloadsEmpty => 'No hay descargas';

  @override
  String get downloadsEmptyHint =>
      'Mantén pulsado un episodio → “Descargar”, o activa la descarga automática en los ajustes del podcast.';

  @override
  String downloadsUsage(String used, String limit) {
    return '$used de $limit usados';
  }

  @override
  String get cleanUpNow => 'Limpiar ahora';

  @override
  String cleanUpResult(String freed) {
    return '$freed liberados';
  }

  @override
  String get cleanUpNothing => 'Todo en orden – nada que eliminar.';

  @override
  String get podcastSettings => 'Ajustes del podcast';

  @override
  String get autoDownload => 'Descargar automáticamente';

  @override
  String get autoDownloadOff => 'Desactivado';

  @override
  String get autoDownloadWifi => 'Solo wifi';

  @override
  String get autoDownloadAlways => 'Siempre';

  @override
  String get autoDownloadMax => 'Número de episodios sin escuchar en el móvil';

  @override
  String get autoDownloadMaxHint =>
      'Se descargan episodios nuevos hasta que haya esta cantidad sin escuchar en el móvil. Esto no elimina nada.';

  @override
  String get autoDownloadPlaylist => 'Añadir episodios nuevos a la playlist';

  @override
  String get autoDownloadPlaylistNone => 'Ninguna';

  @override
  String get autoDownloadPlaylistHint =>
      'Sin descarga automática, los episodios nuevos solo se añaden y se escuchan en streaming. Si la playlist se eliminó, la app la vuelve a crear la próxima vez.';

  @override
  String get episodeCounter => 'Número de episodio en la portada';

  @override
  String get episodeCounterHint =>
      'Una franja estrecha en el borde izquierdo de las portadas en las listas de episodios.';

  @override
  String get episodeNumbering => 'Numeración';

  @override
  String get episodeNumberingFeed => 'Números del feed';

  @override
  String get episodeNumberingOwn => 'Conteo propio';

  @override
  String get episodeNumberOffset => 'Desfase del conteo';

  @override
  String get episodeNumberOffsetHint =>
      'Se suma al conteo desde el episodio más antiguo – p. ej. −1 para que empiece en 0.';

  @override
  String get episodeNumberOffsetFeed =>
      'El desfase solo se aplica al conteo propio.';

  @override
  String get episodeNumberDecrease => 'Reducir';

  @override
  String get episodeNumberIncrease => 'Aumentar';

  @override
  String get autoDeletePlayed => 'Eliminar episodios escuchados';

  @override
  String get autoDeletePlayedHint =>
      '96 horas después de escuchar un episodio hasta el final';

  @override
  String get settingsSectionDownloads => 'Descargas';

  @override
  String get downloadLimit => 'Límite de almacenamiento para descargas';

  @override
  String get downloadLimitHint =>
      'Al alcanzar el límite, primero se eliminan los episodios escuchados. Los episodios sin escuchar nunca se eliminan automáticamente – en ese caso no se descarga nada nuevo.';

  @override
  String get playlistNew => 'Nueva playlist';

  @override
  String get playlistName => 'Nombre';

  @override
  String get playlistNameTaken => 'Ya existe una playlist con este nombre.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String get ratingRemove => 'Quitar valoración';

  @override
  String get subsProvisional => 'Provisional';

  @override
  String get podcastAdd => 'Añadir';

  @override
  String get podcastInAbos => 'Ya está en tus suscripciones';

  @override
  String addedProvisionalSnack(String title) {
    return '“$title” añadido provisionalmente';
  }

  @override
  String get podcastRemove => 'Quitar';

  @override
  String get podcastRemoveConfirmTitle => '¿Quitar podcast?';

  @override
  String playlistActivated(String name) {
    return 'La playlist “$name” está activa';
  }

  @override
  String get playlistOpen => 'Abrir playlist';

  @override
  String get finishedRemoval => 'Quitar episodios terminados de la playlist';

  @override
  String get finishedRemovalHint =>
      'Se aplica a episodios escuchados hasta el final y a “Marcar como escuchado” (también “Todos” y “hasta …”).';

  @override
  String get finishedRemovalNow => 'Inmediatamente';

  @override
  String get finishedRemovalAfter5Minutes => 'Tras 5 minutos';

  @override
  String get finishedRemovalNever => 'Nunca';

  @override
  String get autoMarkNewPlayed =>
      'Marcar los nuevos como escuchados automáticamente';

  @override
  String chapterProgress(int percent) {
    return '$percent %';
  }

  @override
  String averageEpisodeLength(String duration) {
    return 'Ø $duration por episodio';
  }

  @override
  String get averageEpisodeLengthUnknown => 'Duración media desconocida';

  @override
  String get episodeHot => 'Popular: casi siempre escuchas este podcast';

  @override
  String get playlistColor => 'Color…';

  @override
  String get playlistColorNone => 'Sin color';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorViolet => 'Violeta';

  @override
  String get appColor => 'Color de la app';

  @override
  String get appColorWallpaper => 'Como el fondo de pantalla';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorTeal => 'Verde azulado';

  @override
  String get colorBrown => 'Marrón';

  @override
  String get playlistRename => 'Renombrar';

  @override
  String get playlistDelete => 'Eliminar playlist';

  @override
  String playlistDeleteConfirm(String name) {
    return '¿Eliminar “$name”? Los episodios en sí se conservan.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get create => 'Crear';

  @override
  String get playlistsEmpty => 'No hay playlists';

  @override
  String get playlistEmpty => 'Esta playlist está vacía';

  @override
  String get playlistEmptyHint =>
      'Mantén pulsado un episodio → “Añadir a playlist…”';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios',
      one: '1 episodio',
      zero: 'Vacía',
    );
    return '$_temp0$duration';
  }

  @override
  String get addToPlaylist => 'Añadir a playlist…';

  @override
  String get playNext => 'Reproducir a continuación';

  @override
  String playNextHint(String playlist) {
    return 'Justo después del episodio actual en “$playlist”';
  }

  @override
  String playNextDone(String playlist) {
    return 'Se reproducirá a continuación en “$playlist”.';
  }

  @override
  String appendToPlaylist(String playlist) {
    return 'Añadir al final de “$playlist”';
  }

  @override
  String appendToPlaylistDone(String playlist) {
    return 'Añadido al final de “$playlist”.';
  }

  @override
  String get episodeDescription => 'Descripción';

  @override
  String episodeNumberLabel(String number) {
    return 'Episodio $number';
  }

  @override
  String get episodeNoDescription => 'Este episodio no tiene descripción.';

  @override
  String addedToPlaylist(String name) {
    return 'Añadido a “$name”';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Ya está en “$name”';
  }

  @override
  String get removedFromPlaylist => 'Quitado de la playlist';

  @override
  String get removeFromPlaylistTitle => '¿Quitar de la playlist?';

  @override
  String removeFromPlaylistBody(String name) {
    return 'El episodio ya está en “$name”. ¿Quieres quitarlo de ahí?';
  }

  @override
  String get removeFromPlaylistAction => 'Quitar';

  @override
  String removedFromNamedPlaylist(String name) {
    return 'Quitado de “$name”';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String get playerNext => 'Episodio siguiente';

  @override
  String get playerPrevious => 'Episodio anterior';

  @override
  String playingFromPlaylist(String name) {
    return 'De la playlist “$name”';
  }

  @override
  String get dragToReorder => 'Arrastra para reordenar';

  @override
  String get autoDownloadThemes => 'Temas para descarga automática y playlist';

  @override
  String get autoDownloadThemesHint =>
      'Solo los temas marcados se descargan o se añaden a la playlist automáticamente. Los temas nuevos, solo cuando los marques aquí.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios',
      one: '1 episodio',
    );
    return '$_temp0 · último $date';
  }

  @override
  String get selectAll => 'Todos';

  @override
  String get selectNone => 'Ninguno';

  @override
  String get chapters => 'Capítulos';

  @override
  String chaptersCount(int count) {
    return 'Capítulos ($count)';
  }

  @override
  String chapterCurrent(int index, int count, String title) {
    return 'Capítulo $index/$count: $title';
  }

  @override
  String get descriptionMore => 'Leer más';

  @override
  String get descriptionLess => 'Mostrar menos';

  @override
  String get bookmarkAdd => 'Añadir marcador';

  @override
  String bookmarkListHint(int count) {
    return 'Pulsación larga: lista de marcadores ($count)';
  }

  @override
  String get bookmarkNote => 'Nota (opcional)';

  @override
  String bookmarkAdded(String time) {
    return 'Marcador añadido en $time';
  }

  @override
  String get bookmarks => 'Marcadores';

  @override
  String bookmarksCount(int count) {
    return 'Marcadores ($count)';
  }

  @override
  String get bookmarksEmpty => 'No hay marcadores';

  @override
  String get history => 'Historial de escucha';

  @override
  String get historySubtitle =>
      'Los últimos 100 episodios escuchados hasta el final';

  @override
  String get historyEmpty =>
      'Aún no has escuchado ningún episodio hasta el final';

  @override
  String get historyEmptyHint =>
      'Los episodios aparecen aquí cuando se han escuchado hasta el final.';

  @override
  String get historyClear => 'Borrar historial';

  @override
  String get historyClearConfirm =>
      '¿Borrar todo el historial de escucha? Los episodios y las posiciones de escucha se conservan.';

  @override
  String get historyClearAction => 'Borrar';

  @override
  String get historyEpisodeGone =>
      'Este episodio ya no está en tus suscripciones.';

  @override
  String get bookmarksEmptyHint => 'Toca “Añadir marcador” en el reproductor.';

  @override
  String refreshProgress(int current, int total, String title) {
    return '$current de $total · $title';
  }

  @override
  String get bookmarkDeleted => 'Marcador eliminado';

  @override
  String get bookmarkDelete => '¿Eliminar marcador?';

  @override
  String bookmarkDeleteConfirm(String name) {
    return '¿Seguro que quieres eliminar “$name”?';
  }

  @override
  String get bookmarkEditNote => 'Editar nota';

  @override
  String get settingsSectionListening => 'Escucha';

  @override
  String get markPlayedUntil => 'Marcar como escuchado hasta …';

  @override
  String get markPlayedUntilPick => 'Todos los episodios hasta el (incluido)';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Marcar $count episodios hasta el $date (incluido) como escuchados?',
      one: '¿Marcar 1 episodio hasta el $date (incluido) como escuchado?',
    );
    return '$_temp0';
  }

  @override
  String get markPlayedUntilHint =>
      'Salen de las playlists (cuándo: ver “Quitar episodios terminados de la playlist” en los ajustes); los episodios descargados se eliminan tras 96 horas.';

  @override
  String markPlayedUntilNone(String date) {
    return 'No hay episodios sin escuchar hasta el $date.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios marcados como escuchados',
      one: '1 episodio marcado como escuchado',
    );
    return '$_temp0';
  }

  @override
  String get markAction => 'Marcar';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get designTitle => 'Diseño';

  @override
  String get designSubtitle =>
      'Claro/oscuro, color de la app, controles del reproductor';

  @override
  String get designSectionPanel => 'Controles del reproductor';

  @override
  String get designPanelHint =>
      'El fondo detrás de la barra de progreso y los botones del reproductor a pantalla completa. Sigue el modo claro/oscuro y el color de la app.';

  @override
  String get panelDesignPlain => 'Sencillo';

  @override
  String get panelDesignStars => 'Cielo estrellado';

  @override
  String get panelDesignAurora => 'Aurora boreal';

  @override
  String get panelDesignWaves => 'Olas';

  @override
  String get panelDesignFacets => 'Cristal';

  @override
  String get panelDesignCamouflage => 'Camuflaje';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsSectionBackup => 'Copia de seguridad';

  @override
  String get opmlExport => 'Exportar suscripciones como OPML';

  @override
  String get opmlExportSubtitle => 'Para otras apps de podcasts';

  @override
  String get opmlExported => 'Suscripciones exportadas';

  @override
  String get backupCreate => 'Crear copia de seguridad';

  @override
  String get backupCreateSubtitle =>
      'Suscripciones, progreso, playlists, marcadores, historial, ajustes – sin archivos de audio';

  @override
  String get backupCreated => 'Copia de seguridad guardada';

  @override
  String get backupRestore => 'Restaurar copia de seguridad';

  @override
  String get backupRestoreSubtitle => 'Sustituye todos los datos actuales';

  @override
  String get backupInvalid =>
      'El archivo no es una copia de seguridad válida de esta app.';

  @override
  String get backupTooNew =>
      'La copia de seguridad proviene de una versión más reciente de la app.';

  @override
  String get backupConfirmTitle => '¿Restaurar copia de seguridad?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Copia de seguridad del $date:\n$podcasts suscripciones · $episodes episodios · $playlists playlists · $bookmarks marcadores\n\nSe sustituirán todos los datos actuales. Los episodios descargados se eliminarán.';
  }

  @override
  String get backupRestoreAction => 'Restaurar';

  @override
  String get backupRestored => 'Copia de seguridad restaurada';

  @override
  String get saveFailed => 'No se pudo guardar';

  @override
  String get feedUrl => 'Dirección del feed';

  @override
  String get feedUrlChange => 'Cambiar dirección del feed';

  @override
  String get feedUrlChangeHint =>
      'Solo es necesario si el podcast se ha mudado y la dirección antigua ya no funciona. El progreso y las descargas se conservan.';

  @override
  String get feedUrlChangeSubmit => 'Aplicar';

  @override
  String get feedUrlChanged => 'Dirección del feed cambiada.';

  @override
  String get feedUrlTaken => 'Esta dirección ya pertenece a otra suscripción.';

  @override
  String feedsMoved(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count podcasts se han mudado ($names) – sus direcciones se han actualizado.',
      one: 'El podcast “$names” se ha mudado – su dirección se ha actualizado.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Saltar';

  @override
  String get chapterSkipHint =>
      'Saltar capítulos durante la reproducción (hasta reiniciar la app)';

  @override
  String get backgroundPlayback => 'Reproducción en segundo plano';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Batería: Sin restricciones ✓ – toca para los ajustes de la app';

  @override
  String get backgroundPlaybackRestricted =>
      'La optimización de batería está activa: Android puede detener la reproducción con la pantalla apagada. Toca para abrir los ajustes de la app → Batería → “Sin restricciones”.';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios sin escuchar',
      one: '1 episodio sin escuchar',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'No se pudo cargar el episodio. Comprueba tu conexión a internet.';

  @override
  String get playbackStalled =>
      'La reproducción se atascó y se pausó. La posición está guardada – comprueba tu conexión.';

  @override
  String get sleepTimer => 'Temporizador';

  @override
  String get sleepTimerOff => 'Desactivado';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get sleepTimerEpisodeEnd => 'Hasta el final del episodio';

  @override
  String get sleepTimerEpisodeEndShort => 'Fin del episodio';

  @override
  String sleepTimerLeft(String time) {
    return 'Quedan $time';
  }

  @override
  String get playbackBrokenDownload =>
      'La descarga estaba dañada y se eliminó. Ahora el episodio se escucha en streaming.';

  @override
  String get playbackEpisodeGone =>
      'Este episodio ya no está disponible en el proveedor.';

  @override
  String get playbackUnsupported =>
      'Este episodio tiene un formato que no se puede reproducir.';

  @override
  String get playbackStreamChanged =>
      'El episodio llegó distinto al recargarlo (p. ej. otros anuncios) – la posición puede no coincidir. Los episodios descargados no se ven afectados.';

  @override
  String get playbackStreamVaries =>
      'Este podcast inserta anuncios variables en streaming – al continuar puede haber desfases. Consejo: descarga el episodio.';

  @override
  String get playNewEpisodes => 'Reproducir todos los episodios nuevos';

  @override
  String playNewEpisodesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios de las últimas 96 horas',
      one: '1 episodio de las últimas 96 horas',
      zero: 'Ningún episodio nuevo en las últimas 96 horas',
    );
    return '$_temp0';
  }

  @override
  String get playUnplayedEpisodes =>
      'Reproducir todos los episodios sin escuchar';

  @override
  String get addNewEpisodesToPlaylist =>
      'Todos los episodios nuevos a una playlist';

  @override
  String get addUnplayedSinceToPlaylist =>
      'Episodios sin escuchar desde … a una playlist';

  @override
  String get addUnplayedEpisodesToPlaylist =>
      'Todos los episodios sin escuchar a una playlist';

  @override
  String get podcastMenuPlayNew => 'Reproducir todos los episodios nuevos';

  @override
  String get podcastMenuPlaySince =>
      'Reproducir episodios sin escuchar desde …';

  @override
  String get podcastMenuPlayUnplayed =>
      'Reproducir todos los episodios sin escuchar';

  @override
  String get noUnplayedEpisodes => 'No hay episodios sin escuchar.';

  @override
  String episodesAddedNoPlay(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios añadidos a “$playlist”.',
      one: '1 episodio añadido a “$playlist”.',
      zero: 'Todos los episodios ya estaban en “$playlist”.',
    );
    return '$_temp0';
  }

  @override
  String episodesAddedToPlaylist(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios añadidos a “$playlist”.',
      one: '1 episodio añadido a “$playlist”.',
      zero:
          'Todos los episodios ya estaban en “$playlist” – empieza la reproducción.',
    );
    return '$_temp0';
  }

  @override
  String get sleepTimerCustom => 'Tiempo personalizado…';

  @override
  String sleepTimerCustomSet(int minutes) {
    return 'Tiempo personalizado: $minutes minutos';
  }

  @override
  String get sleepTimerCustomLabel => 'Minutos';

  @override
  String sleepTimerCustomRange(int min, int max) {
    return 'De $min a $max minutos';
  }

  @override
  String get sleepTimerStart => 'Iniciar';

  @override
  String get playUnplayedSince => 'Reproducir episodios sin escuchar desde …';

  @override
  String get playUnplayedSinceHint => 'Elige una fecha';

  @override
  String get playUnplayedSincePick => 'Episodios sin escuchar desde el';

  @override
  String playUnplayedSinceNone(String date) {
    return 'No hay episodios sin escuchar desde el $date.';
  }

  @override
  String get markUnplayedSince => 'Marcar como no escuchado desde …';

  @override
  String get markUnplayedSincePick =>
      'Todos los episodios escuchados desde el (incluido)';

  @override
  String markUnplayedSinceConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '¿Marcar $count episodios escuchados desde el $date (incluido) como no escuchados?',
      one:
          '¿Marcar 1 episodio escuchado desde el $date (incluido) como no escuchado?',
    );
    return '$_temp0';
  }

  @override
  String get markUnplayedSinceHint =>
      'Vuelven a empezar desde el principio y ya no se eliminan automáticamente. Los episodios empezados se quedan como están.';

  @override
  String markUnplayedSinceNone(String date) {
    return 'No hay episodios escuchados desde el $date.';
  }

  @override
  String markUnplayedSinceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodios marcados como no escuchados',
      one: '1 episodio marcado como no escuchado',
    );
    return '$_temp0';
  }

  @override
  String get markAllPlayed => 'Marcar todo como escuchado';

  @override
  String get markAllUnplayed => 'Marcar todo como no escuchado';

  @override
  String markAllPlayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Marcar $count episodios como escuchados?',
      one: '¿Marcar 1 episodio como escuchado?',
    );
    return '$_temp0';
  }

  @override
  String markAllUnplayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Marcar $count episodios escuchados como no escuchados?',
      one: '¿Marcar 1 episodio escuchado como no escuchado?',
    );
    return '$_temp0';
  }

  @override
  String get playlistSortDateAscending => 'Ordenar por fecha, ascendente';

  @override
  String get playlistSortDateDescending => 'Ordenar por fecha, descendente';

  @override
  String get playlistSortNameAscending => 'Ordenar por nombre, ascendente';

  @override
  String playlistSortedDateAscending(String name) {
    return '“$name” ordenada por fecha (más antiguos primero).';
  }

  @override
  String playlistSortedDateDescending(String name) {
    return '“$name” ordenada por fecha (más recientes primero).';
  }

  @override
  String playlistSortedName(String name) {
    return '“$name” ordenada por nombre (A–Z).';
  }

  @override
  String get playlistResume => 'Continuar';

  @override
  String get playlistDownloadAll => 'Descargar todo';

  @override
  String playlistDownloadAllConfirm(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Descargar $count episodios de “$name”?',
      one: '¿Descargar 1 episodio de “$name”?',
    );
    return '$_temp0';
  }

  @override
  String playlistDownloadAllSize(String size) {
    return '(aprox. $size)';
  }

  @override
  String get playlistDownloadAllHint =>
      'Las descargas empiezan enseguida, también con datos móviles. Los episodios ya descargados se omiten.';

  @override
  String get playlistDownloadAllNone =>
      'Todos los episodios de esta playlist ya están descargados.';

  @override
  String playlistDownloadAllStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descargas iniciadas.',
      one: '1 descarga iniciada.',
    );
    return '$_temp0';
  }

  @override
  String get infoTitle => 'Info';

  @override
  String get infoAbout => 'Acerca de la app';

  @override
  String infoVersion(String name, int build) {
    return 'Versión $name (build $build)';
  }

  @override
  String infoVersionShort(String name) {
    return 'Versión $name';
  }

  @override
  String infoDeveloper(String name) {
    return 'Desarrollado por $name';
  }

  @override
  String get infoPrivacy => 'Política de privacidad';

  @override
  String get infoSourceCode => 'Código fuente en GitHub';

  @override
  String get infoLinkFailed => 'No se pudo abrir el enlace.';

  @override
  String get infoSourceCodeHint =>
      'Código fuente, versiones y opción de apoyar la app voluntariamente';

  @override
  String get language => 'Idioma';

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
  String get languagePickerWelcome =>
      'Bienvenido al Podcatcher “AA-AuralListen”';

  @override
  String get languagePickerTitle => 'Elige el idioma';

  @override
  String get languagePickerHint =>
      'Puedes cambiar el idioma más tarde en Ajustes.';

  @override
  String get notificationChannelPlayback => 'Reproducción';
}
