// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AA-AuralListen Podcatcher';

  @override
  String get navHome => 'Início';

  @override
  String get navSubscriptions => 'Inscrições';

  @override
  String get navPlaylists => 'Playlists';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get carNew => 'Novos';

  @override
  String carNotFound(String query) {
    return 'Nada encontrado para “$query”';
  }

  @override
  String get carNothingToPlay => 'Nada ouvido ainda – escolha um episódio';

  @override
  String get placeholderComingSoon => 'Em breve';

  @override
  String get cancel => 'Cancelar';

  @override
  String get loadError => 'Erro ao carregar';

  @override
  String get homeEmpty => 'Ainda não há episódios';

  @override
  String get homeEmptyHint => 'Inscreva-se em podcasts na aba “Inscrições”.';

  @override
  String get subscriptionsEmpty => 'Ainda não há inscrições';

  @override
  String get subscriptionsEmptyHint =>
      'Adicione seu primeiro podcast pelo endereço RSS.';

  @override
  String get addFeedAction => 'Adicionar por endereço RSS';

  @override
  String get addFeedTitle => 'Adicionar podcast';

  @override
  String get addFeedLabel => 'Endereço RSS';

  @override
  String get addFeedHint => 'https://example.com/feed.xml';

  @override
  String get addFeedSubmit => 'Adicionar';

  @override
  String get subscribeErrorInvalidUrl => 'Este endereço não é válido.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'Você já está inscrito neste podcast.';

  @override
  String get subscribeErrorNetwork =>
      'Não foi possível carregar o feed. Verifique o endereço e sua conexão com a internet.';

  @override
  String get subscribeErrorNotAFeed =>
      'Não há nenhum feed de podcast neste endereço.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível atualizar $count feeds.',
      one: 'Não foi possível atualizar 1 feed.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Podcast não encontrado';

  @override
  String get podcastRefreshError => 'A última atualização falhou';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios',
      one: '1 episódio',
      zero: 'Nenhum episódio',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'Novo';

  @override
  String get episodePlayed => 'Ouvido';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get unsubscribe => 'Cancelar inscrição';

  @override
  String get unsubscribeConfirmTitle => 'Cancelar inscrição?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '“$title” e todos os seus episódios serão removidos do app.';
  }

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar podcasts';

  @override
  String get searchStart => 'Busque por título, tema ou autor';

  @override
  String get searchStartHint => 'Busca no Apple Podcasts e no fyyd.de';

  @override
  String get searchPopular => 'Populares';

  @override
  String get searchNew => 'Novidades';

  @override
  String get subsSearchHint => 'Buscar nas inscrições';

  @override
  String get subsSearchClose => 'Fechar busca';

  @override
  String get searchClear => 'Limpar';

  @override
  String get subsSearchPodcasts => 'Podcasts';

  @override
  String get subsSearchEpisodes => 'Episódios';

  @override
  String get subsSearchNothing => 'Nada encontrado nas suas inscrições';

  @override
  String get subsSearchNothingHint =>
      'Encontre novos podcasts com a busca em “Início”.';

  @override
  String get searchNoResults => 'Nenhum podcast encontrado';

  @override
  String get searchFailed =>
      'A busca falhou. Verifique sua conexão com a internet.';

  @override
  String searchPartialFailure(String names) {
    return '$names indisponível – resultados incompletos';
  }

  @override
  String get subscribed => 'Inscrito';

  @override
  String get subscribeAction => 'Inscrever-se';

  @override
  String subscribedSnack(String title) {
    return 'Inscrito em “$title”';
  }

  @override
  String get open => 'Abrir';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Inscrições';

  @override
  String get opmlImport => 'Importar arquivo OPML';

  @override
  String get opmlImportSubtitle => 'Traga suas inscrições de outro app';

  @override
  String get opmlInvalid => 'O arquivo não é um arquivo OPML válido.';

  @override
  String get opmlTooLarge => 'O arquivo é grande demais.';

  @override
  String get opmlEmpty => 'Nenhum podcast foi encontrado no arquivo.';

  @override
  String get opmlConfirmTitle => 'Importar inscrições?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts encontrados.',
      one: '1 podcast encontrado.',
    );
    return '$_temp0 Inscrições existentes são ignoradas.';
  }

  @override
  String get opmlImportAction => 'Importar';

  @override
  String opmlProgress(int done, int total) {
    return 'Importando $done de $total …';
  }

  @override
  String get opmlResultTitle => 'Importação concluída';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'Novos: $added\nJá inscrito: $already\nFalharam: $failed';
  }

  @override
  String get opmlResultFailedList => 'Não importados:';

  @override
  String get playerPlay => 'Reproduzir';

  @override
  String get playerPause => 'Pausar';

  @override
  String get playerRewind => 'Voltar 15 segundos';

  @override
  String get playerForward => 'Avançar 30 segundos';

  @override
  String get playerClose => 'Fechar player';

  @override
  String get playerOpen => 'Abrir player';

  @override
  String get nowPlaying => 'Tocando agora';

  @override
  String get boostTitle => 'Reforço de volume';

  @override
  String get speedTitle => 'Velocidade de reprodução';

  @override
  String speedOff(String value) {
    return 'Normal ($value)';
  }

  @override
  String get speedNormal => 'normal';

  @override
  String speedButton(String value) {
    return 'Velocidade: $value';
  }

  @override
  String get boostOff => 'Não';

  @override
  String boostValue(int db) {
    return '+$db dB';
  }

  @override
  String boostButton(String value) {
    return 'Boost: $value';
  }

  @override
  String get speedPerPodcast => 'Só para este podcast';

  @override
  String get speedPerPodcastHint =>
      'Senão, a velocidade vale para todos os podcasts sem ajuste próprio.';

  @override
  String get boostPerPodcast => 'Só para este podcast';

  @override
  String get boostPerPodcastHint =>
      'Senão, o valor vale para todos os podcasts sem ajuste próprio.';

  @override
  String get markPlayed => 'Marcar como ouvido';

  @override
  String get markUnplayed => 'Marcar como não ouvido';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get download => 'Baixar';

  @override
  String get episodeNumberingSeasons =>
      'Podcast com temporadas: valem os números do feed por temporada (ex.: “S2·5”). Aqui não é possível uma contagem própria.';

  @override
  String get episodeNumberOffsetSeasons =>
      'Não é possível em podcasts com temporadas.';

  @override
  String get seasonAll => 'Todas';

  @override
  String seasonLabel(int season) {
    return 'Temporada $season';
  }

  @override
  String get podcastWebsite => 'Site';

  @override
  String get podcastSupport => 'Apoiar';

  @override
  String get playlistContinueOffer =>
      'Toque para continuar no fim com o próximo episódio desta playlist';

  @override
  String get downloadCancel => 'Cancelar download';

  @override
  String get downloadDelete => 'Excluir download';

  @override
  String get downloadRetry => 'Baixar de novo';

  @override
  String get downloadDone => 'Baixado';

  @override
  String get episodeInPlaylist => 'Em uma playlist';

  @override
  String get downloadFailed => 'O download falhou';

  @override
  String get downloadQueued => 'Aguardando …';

  @override
  String get downloadWifiWaiting => 'Aguardando Wi-Fi …';

  @override
  String get downloadNowMobile => 'Baixar agora pelos dados móveis';

  @override
  String downloadDeleteConfirm(String title) {
    return 'Excluir “$title” do aparelho? O episódio continua no app e ainda pode ser ouvido por streaming.';
  }

  @override
  String get detailsEpisode => 'Episódio';

  @override
  String get detailsAuthor => 'Autor';

  @override
  String get detailsPublished => 'Publicado';

  @override
  String get detailsDuration => 'Duração';

  @override
  String get detailsSize => 'Tamanho';

  @override
  String get detailsDownloadedAt => 'Baixado';

  @override
  String get detailsStatus => 'Download';

  @override
  String get detailsListening => 'Estado de escuta';

  @override
  String detailsInProgress(String position) {
    return 'Iniciado, em $position';
  }

  @override
  String detailsPlayedAt(String date) {
    return 'Ouvido em $date';
  }

  @override
  String get downloadsEmpty => 'Nenhum download';

  @override
  String get downloadsEmptyHint =>
      'Toque e segure um episódio → “Baixar”, ou ative o download automático nos ajustes do podcast.';

  @override
  String downloadsUsage(String used, String limit) {
    return '$used de $limit usados';
  }

  @override
  String get cleanUpNow => 'Limpar agora';

  @override
  String cleanUpResult(String freed) {
    return '$freed liberados';
  }

  @override
  String get cleanUpNothing => 'Tudo em ordem – nada para excluir.';

  @override
  String get podcastSettings => 'Ajustes do podcast';

  @override
  String get autoDownload => 'Baixar automaticamente';

  @override
  String get autoDownloadOff => 'Desativado';

  @override
  String get autoDownloadWifi => 'Só Wi-Fi';

  @override
  String get autoDownloadAlways => 'Sempre';

  @override
  String get autoDownloadMax => 'Número de episódios não ouvidos no celular';

  @override
  String get autoDownloadMaxHint =>
      'Novos episódios são baixados até haver esta quantidade de não ouvidos no celular. Nada é excluído por isso.';

  @override
  String get autoDownloadPlaylist => 'Adicionar novos episódios à playlist';

  @override
  String get autoDownloadPlaylistNone => 'Nenhuma';

  @override
  String get autoDownloadPlaylistHint =>
      'Sem download automático, os novos episódios só são adicionados e ouvidos por streaming. Se a playlist foi excluída, o app a cria de novo na próxima vez.';

  @override
  String get episodeCounter => 'Número do episódio na capa';

  @override
  String get episodeCounterHint =>
      'Uma faixa estreita na borda esquerda das capas nas listas de episódios.';

  @override
  String get episodeNumbering => 'Numeração';

  @override
  String get episodeNumberingFeed => 'Números do feed';

  @override
  String get episodeNumberingOwn => 'Contagem própria';

  @override
  String get episodeNumberOffset => 'Deslocamento da contagem';

  @override
  String get episodeNumberOffsetHint =>
      'Somado à contagem a partir do episódio mais antigo – ex.: −1 para que ele vire 0.';

  @override
  String get episodeNumberOffsetFeed =>
      'O deslocamento só vale para a contagem própria.';

  @override
  String get episodeNumberDecrease => 'Diminuir';

  @override
  String get episodeNumberIncrease => 'Aumentar';

  @override
  String get autoDeletePlayed => 'Excluir episódios ouvidos';

  @override
  String get autoDeletePlayedHint =>
      '96 horas depois de um episódio ser ouvido até o fim';

  @override
  String get settingsSectionDownloads => 'Downloads';

  @override
  String get downloadLimit => 'Limite de armazenamento para downloads';

  @override
  String get downloadLimitHint =>
      'Ao atingir o limite, os episódios ouvidos são excluídos primeiro. Episódios não ouvidos nunca são excluídos automaticamente – nesse caso, nada novo é baixado.';

  @override
  String get playlistNew => 'Nova playlist';

  @override
  String get playlistName => 'Nome';

  @override
  String get playlistNameTaken => 'Já existe uma playlist com este nome.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas',
      one: '1 estrela',
    );
    return '$_temp0';
  }

  @override
  String get ratingRemove => 'Remover avaliação';

  @override
  String get subsProvisional => 'Provisório';

  @override
  String get podcastAdd => 'Adicionar';

  @override
  String get podcastInAbos => 'Já está nas suas inscrições';

  @override
  String addedProvisionalSnack(String title) {
    return '“$title” adicionado provisoriamente';
  }

  @override
  String get podcastRemove => 'Remover';

  @override
  String get podcastRemoveConfirmTitle => 'Remover podcast?';

  @override
  String playlistActivated(String name) {
    return 'A playlist “$name” está ativa';
  }

  @override
  String get playlistOpen => 'Abrir playlist';

  @override
  String get finishedRemoval => 'Remover episódios concluídos da playlist';

  @override
  String get finishedRemovalHint =>
      'Vale para episódios ouvidos até o fim e para “Marcar como ouvido” (também “Todos” e “até …”).';

  @override
  String get finishedRemovalNow => 'Imediatamente';

  @override
  String get finishedRemovalAfter5Minutes => 'Após 5 minutos';

  @override
  String get finishedRemovalNever => 'Nunca';

  @override
  String get autoMarkNewPlayed => 'Marcar novos como ouvidos automaticamente';

  @override
  String chapterProgress(int percent) {
    return '$percent%';
  }

  @override
  String averageEpisodeLength(String duration) {
    return 'Ø $duration por episódio';
  }

  @override
  String get averageEpisodeLengthUnknown => 'Duração média desconhecida';

  @override
  String get episodeHot => 'Popular: você quase sempre ouve este podcast';

  @override
  String get playlistColor => 'Cor…';

  @override
  String get playlistColorNone => 'Sem cor';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorViolet => 'Violeta';

  @override
  String get appColor => 'Cor do app';

  @override
  String get appColorWallpaper => 'Como o papel de parede';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorTeal => 'Verde-azulado';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get playlistRename => 'Renomear';

  @override
  String get playlistDelete => 'Excluir playlist';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Excluir “$name”? Os episódios em si são mantidos.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get create => 'Criar';

  @override
  String get playlistsEmpty => 'Nenhuma playlist';

  @override
  String get playlistEmpty => 'Esta playlist está vazia';

  @override
  String get playlistEmptyHint =>
      'Toque e segure um episódio → “Adicionar à playlist…”';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios',
      one: '1 episódio',
      zero: 'Vazia',
    );
    return '$_temp0$duration';
  }

  @override
  String get addToPlaylist => 'Adicionar à playlist…';

  @override
  String get playNext => 'Tocar a seguir';

  @override
  String playNextHint(String playlist) {
    return 'Logo após o episódio atual em “$playlist”';
  }

  @override
  String playNextDone(String playlist) {
    return 'Toca a seguir em “$playlist”.';
  }

  @override
  String appendToPlaylist(String playlist) {
    return 'Adicionar ao fim de “$playlist”';
  }

  @override
  String appendToPlaylistDone(String playlist) {
    return 'Adicionado ao fim de “$playlist”.';
  }

  @override
  String get episodeDescription => 'Descrição';

  @override
  String episodeNumberLabel(String number) {
    return 'Episódio $number';
  }

  @override
  String get episodeNoDescription => 'Este episódio não tem descrição.';

  @override
  String addedToPlaylist(String name) {
    return 'Adicionado a “$name”';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Já está em “$name”';
  }

  @override
  String get removedFromPlaylist => 'Removido da playlist';

  @override
  String get removeFromPlaylistTitle => 'Remover da playlist?';

  @override
  String removeFromPlaylistBody(String name) {
    return 'O episódio já está em “$name”. Quer removê-lo de lá?';
  }

  @override
  String get removeFromPlaylistAction => 'Remover';

  @override
  String removedFromNamedPlaylist(String name) {
    return 'Removido de “$name”';
  }

  @override
  String get undo => 'Desfazer';

  @override
  String get playerNext => 'Próximo episódio';

  @override
  String get playerPrevious => 'Episódio anterior';

  @override
  String playingFromPlaylist(String name) {
    return 'Da playlist “$name”';
  }

  @override
  String get dragToReorder => 'Arraste para reordenar';

  @override
  String get autoDownloadThemes => 'Temas para download automático e playlist';

  @override
  String get autoDownloadThemesHint =>
      'Só os temas marcados são baixados ou adicionados à playlist automaticamente. Temas novos, só depois de marcados aqui.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios',
      one: '1 episódio',
    );
    return '$_temp0 · último em $date';
  }

  @override
  String get selectAll => 'Todos';

  @override
  String get selectNone => 'Nenhum';

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
  String get descriptionMore => 'Ler mais';

  @override
  String get descriptionLess => 'Mostrar menos';

  @override
  String get bookmarkAdd => 'Adicionar marcador';

  @override
  String bookmarkListHint(int count) {
    return 'Toque longo: lista de marcadores ($count)';
  }

  @override
  String get bookmarkNote => 'Nota (opcional)';

  @override
  String bookmarkAdded(String time) {
    return 'Marcador adicionado em $time';
  }

  @override
  String get bookmarks => 'Marcadores';

  @override
  String bookmarksCount(int count) {
    return 'Marcadores ($count)';
  }

  @override
  String get bookmarksEmpty => 'Nenhum marcador';

  @override
  String get history => 'Histórico de reprodução';

  @override
  String get historySubtitle => 'Os últimos 100 episódios ouvidos até o fim';

  @override
  String get historyEmpty => 'Nenhum episódio ouvido até o fim ainda';

  @override
  String get historyEmptyHint =>
      'Os episódios aparecem aqui depois de ouvidos até o fim.';

  @override
  String get historyClear => 'Limpar histórico';

  @override
  String get historyClearConfirm =>
      'Limpar todo o histórico de reprodução? Episódios e posições de escuta são mantidos.';

  @override
  String get historyClearAction => 'Limpar';

  @override
  String get historyEpisodeGone =>
      'Este episódio não está mais nas suas inscrições.';

  @override
  String get bookmarksEmptyHint => 'Toque em “Adicionar marcador” no player.';

  @override
  String refreshProgress(int current, int total, String title) {
    return '$current de $total · $title';
  }

  @override
  String get bookmarkDeleted => 'Marcador excluído';

  @override
  String get bookmarkDelete => 'Excluir marcador?';

  @override
  String bookmarkDeleteConfirm(String name) {
    return 'Excluir mesmo “$name”?';
  }

  @override
  String get bookmarkEditNote => 'Editar nota';

  @override
  String get settingsSectionListening => 'Escuta';

  @override
  String get markPlayedUntil => 'Marcar como ouvido até …';

  @override
  String get markPlayedUntilPick => 'Todos os episódios até (inclusive)';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marcar $count episódios até $date (inclusive) como ouvidos?',
      one: 'Marcar 1 episódio até $date (inclusive) como ouvido?',
    );
    return '$_temp0';
  }

  @override
  String get markPlayedUntilHint =>
      'Eles saem das playlists (quando: veja “Remover episódios concluídos da playlist” nos ajustes); episódios baixados são excluídos após 96 horas.';

  @override
  String markPlayedUntilNone(String date) {
    return 'Não há episódios não ouvidos até $date.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios marcados como ouvidos',
      one: '1 episódio marcado como ouvido',
    );
    return '$_temp0';
  }

  @override
  String get markAction => 'Marcar';

  @override
  String get settingsSectionAppearance => 'Aparência';

  @override
  String get designTitle => 'Design';

  @override
  String get designSubtitle => 'Claro/escuro, cor do app, controles do player';

  @override
  String get designSectionPanel => 'Controles do player';

  @override
  String get designPanelHint =>
      'O fundo atrás da barra de progresso e dos botões no player em tela cheia. Ele segue o modo claro/escuro e a cor do app.';

  @override
  String get panelDesignPlain => 'Simples';

  @override
  String get panelDesignStars => 'Céu estrelado';

  @override
  String get panelDesignAurora => 'Aurora boreal';

  @override
  String get panelDesignWaves => 'Ondas';

  @override
  String get panelDesignFacets => 'Cristal';

  @override
  String get panelDesignCamouflage => 'Camuflagem';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get opmlExport => 'Exportar inscrições como OPML';

  @override
  String get opmlExportSubtitle => 'Para outros apps de podcast';

  @override
  String get opmlExported => 'Inscrições exportadas';

  @override
  String get backupCreate => 'Criar backup';

  @override
  String get backupCreateSubtitle =>
      'Inscrições, progresso, playlists, marcadores, histórico, ajustes – sem arquivos de áudio';

  @override
  String get backupCreated => 'Backup salvo';

  @override
  String get backupRestore => 'Restaurar backup';

  @override
  String get backupRestoreSubtitle => 'Substitui todos os dados atuais';

  @override
  String get backupInvalid => 'O arquivo não é um backup válido deste app.';

  @override
  String get backupTooNew => 'O backup vem de uma versão mais nova do app.';

  @override
  String get backupConfirmTitle => 'Restaurar backup?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Backup de $date:\n$podcasts inscrições · $episodes episódios · $playlists playlists · $bookmarks marcadores\n\nTodos os dados atuais serão substituídos. Episódios baixados serão excluídos.';
  }

  @override
  String get backupRestoreAction => 'Restaurar';

  @override
  String get backupRestored => 'Backup restaurado';

  @override
  String get saveFailed => 'Não foi possível salvar';

  @override
  String get feedUrl => 'Endereço do feed';

  @override
  String get feedUrlChange => 'Alterar endereço do feed';

  @override
  String get feedUrlChangeHint =>
      'Só é necessário se o podcast mudou de endereço e o antigo não funciona mais. Progresso e downloads são mantidos.';

  @override
  String get feedUrlChangeSubmit => 'Aplicar';

  @override
  String get feedUrlChanged => 'Endereço do feed alterado.';

  @override
  String get feedUrlTaken => 'Este endereço já pertence a outra inscrição.';

  @override
  String feedsMoved(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count podcasts mudaram de endereço ($names) – os endereços foram atualizados.',
      one: 'O podcast “$names” mudou de endereço – o endereço foi atualizado.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Pular';

  @override
  String get chapterSkipHint =>
      'Pular capítulos durante a reprodução (até reiniciar o app)';

  @override
  String get backgroundPlayback => 'Reprodução em segundo plano';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Bateria: Sem restrições ✓ – toque para os ajustes do app';

  @override
  String get backgroundPlaybackRestricted =>
      'A otimização de bateria está ativa: o Android pode parar a reprodução com a tela desligada. Toque para abrir os ajustes do app → Bateria → “Sem restrições”.';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios não ouvidos',
      one: '1 episódio não ouvido',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'Não foi possível carregar o episódio. Verifique sua conexão com a internet.';

  @override
  String get playbackStalled =>
      'A reprodução travou e foi pausada. A posição está salva – verifique sua conexão.';

  @override
  String get sleepTimer => 'Timer de desligamento';

  @override
  String get sleepTimerOff => 'Desativado';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes minutos';
  }

  @override
  String get sleepTimerEpisodeEnd => 'Até o fim do episódio';

  @override
  String get sleepTimerEpisodeEndShort => 'Fim do episódio';

  @override
  String sleepTimerLeft(String time) {
    return 'Faltam $time';
  }

  @override
  String get playbackBrokenDownload =>
      'O download estava corrompido e foi excluído. Agora o episódio é ouvido por streaming.';

  @override
  String get playbackEpisodeGone =>
      'Este episódio não está mais disponível no provedor.';

  @override
  String get playbackUnsupported =>
      'Este episódio está em um formato que não pode ser reproduzido.';

  @override
  String get playbackStreamChanged =>
      'O episódio veio diferente ao recarregar (ex.: outros anúncios) – a posição pode estar deslocada. Episódios baixados não são afetados.';

  @override
  String get playbackStreamVaries =>
      'Este podcast insere anúncios variáveis no streaming – retomar pode ser impreciso. Dica: baixe o episódio.';

  @override
  String get playNewEpisodes => 'Tocar todos os episódios novos';

  @override
  String playNewEpisodesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios das últimas 96 horas',
      one: '1 episódio das últimas 96 horas',
      zero: 'Nenhum episódio novo nas últimas 96 horas',
    );
    return '$_temp0';
  }

  @override
  String get playUnplayedEpisodes => 'Tocar todos os episódios não ouvidos';

  @override
  String get addNewEpisodesToPlaylist =>
      'Todos os episódios novos para uma playlist';

  @override
  String get addUnplayedSinceToPlaylist =>
      'Episódios não ouvidos desde … para uma playlist';

  @override
  String get addUnplayedEpisodesToPlaylist =>
      'Todos os episódios não ouvidos para uma playlist';

  @override
  String get podcastMenuPlayNew => 'Tocar todos os episódios novos';

  @override
  String get podcastMenuPlaySince => 'Tocar episódios não ouvidos desde …';

  @override
  String get podcastMenuPlayUnplayed => 'Tocar todos os episódios não ouvidos';

  @override
  String get noUnplayedEpisodes => 'Nenhum episódio não ouvido.';

  @override
  String episodesAddedNoPlay(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios adicionados a “$playlist”.',
      one: '1 episódio adicionado a “$playlist”.',
      zero: 'Todos os episódios já estavam em “$playlist”.',
    );
    return '$_temp0';
  }

  @override
  String episodesAddedToPlaylist(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios adicionados a “$playlist”.',
      one: '1 episódio adicionado a “$playlist”.',
      zero:
          'Todos os episódios já estavam em “$playlist” – a reprodução começa.',
    );
    return '$_temp0';
  }

  @override
  String get sleepTimerCustom => 'Tempo personalizado…';

  @override
  String sleepTimerCustomSet(int minutes) {
    return 'Tempo personalizado: $minutes minutos';
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
  String get playUnplayedSince => 'Tocar episódios não ouvidos desde …';

  @override
  String get playUnplayedSinceHint => 'Escolha uma data';

  @override
  String get playUnplayedSincePick => 'Episódios não ouvidos desde';

  @override
  String playUnplayedSinceNone(String date) {
    return 'Nenhum episódio não ouvido desde $date.';
  }

  @override
  String get markUnplayedSince => 'Marcar como não ouvido desde …';

  @override
  String get markUnplayedSincePick =>
      'Todos os episódios ouvidos desde (inclusive)';

  @override
  String markUnplayedSinceConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Marcar $count episódios ouvidos desde $date (inclusive) como não ouvidos?',
      one: 'Marcar 1 episódio ouvido desde $date (inclusive) como não ouvido?',
    );
    return '$_temp0';
  }

  @override
  String get markUnplayedSinceHint =>
      'Eles recomeçam do início e não são mais excluídos automaticamente. Episódios em andamento ficam como estão.';

  @override
  String markUnplayedSinceNone(String date) {
    return 'Não há episódios ouvidos desde $date.';
  }

  @override
  String markUnplayedSinceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episódios marcados como não ouvidos',
      one: '1 episódio marcado como não ouvido',
    );
    return '$_temp0';
  }

  @override
  String get markAllPlayed => 'Marcar tudo como ouvido';

  @override
  String get markAllUnplayed => 'Marcar tudo como não ouvido';

  @override
  String markAllPlayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marcar $count episódios como ouvidos?',
      one: 'Marcar 1 episódio como ouvido?',
    );
    return '$_temp0';
  }

  @override
  String markAllUnplayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Marcar $count episódios ouvidos como não ouvidos?',
      one: 'Marcar 1 episódio ouvido como não ouvido?',
    );
    return '$_temp0';
  }

  @override
  String get playlistSortDateAscending => 'Ordenar por data, crescente';

  @override
  String get playlistSortDateDescending => 'Ordenar por data, decrescente';

  @override
  String get playlistSortNameAscending => 'Ordenar por nome, crescente';

  @override
  String playlistSortedDateAscending(String name) {
    return '“$name” ordenada por data (mais antigos primeiro).';
  }

  @override
  String playlistSortedDateDescending(String name) {
    return '“$name” ordenada por data (mais recentes primeiro).';
  }

  @override
  String playlistSortedName(String name) {
    return '“$name” ordenada por nome (A–Z).';
  }

  @override
  String get playlistResume => 'Continuar';

  @override
  String get playlistDownloadAll => 'Baixar tudo';

  @override
  String playlistDownloadAllConfirm(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Baixar $count episódios de “$name”?',
      one: 'Baixar 1 episódio de “$name”?',
    );
    return '$_temp0';
  }

  @override
  String playlistDownloadAllSize(String size) {
    return '(aprox. $size)';
  }

  @override
  String get playlistDownloadAllHint =>
      'Os downloads começam na hora, também pelos dados móveis. Episódios já baixados são ignorados.';

  @override
  String get playlistDownloadAllNone =>
      'Todos os episódios desta playlist já estão baixados.';

  @override
  String playlistDownloadAllStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloads iniciados.',
      one: '1 download iniciado.',
    );
    return '$_temp0';
  }

  @override
  String get infoTitle => 'Info';

  @override
  String get infoAbout => 'Sobre o app';

  @override
  String infoVersion(String name, int build) {
    return 'Versão $name (build $build)';
  }

  @override
  String infoVersionShort(String name) {
    return 'Versão $name';
  }

  @override
  String infoDeveloper(String name) {
    return 'Desenvolvido por $name';
  }

  @override
  String get infoPrivacy => 'Política de privacidade';

  @override
  String get infoSourceCode => 'Código-fonte no GitHub';

  @override
  String get infoLinkFailed => 'Não foi possível abrir o link.';

  @override
  String get infoSourceCodeHint =>
      'Código-fonte, versões e opção de apoiar o app voluntariamente';

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
  String get languageRussian => 'Русский';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePickerWelcome =>
      'Bem-vindo ao Podcatcher “AA-AuralListen”';

  @override
  String get languagePickerTitle => 'Escolha o idioma';

  @override
  String get languagePickerHint =>
      'Você pode mudar o idioma depois em Ajustes.';

  @override
  String get newLanguageTitle => 'Agora também em português';

  @override
  String get newLanguageBody =>
      'O AA-AuralListen agora está disponível no seu idioma. Quer mudar? Você pode mudar o idioma a qualquer momento em Ajustes → Idioma.';

  @override
  String get newLanguageSwitch => 'Mudar';

  @override
  String get newLanguageKeep => 'Agora não';

  @override
  String get notificationChannelPlayback => 'Reprodução';

  @override
  String get autoSleepTitle => 'Timer de desligamento automático';

  @override
  String get autoSleepModeOff => 'Desativado';

  @override
  String get autoSleepModeDaily => 'Ativado';

  @override
  String get autoSleepModeWeekdays => 'Por dia';

  @override
  String get autoSleepIntro =>
      'Se você tocar em Reproduzir no app dentro do intervalo de horário, o timer de desligamento começa automaticamente. Um timer que já está ativo continua como está. Ele nunca começa pelo Android Auto, pela notificação, pela tela de bloqueio ou pelos botões Bluetooth. Se você desativá-lo, ele não começa de novo naquela noite.';

  @override
  String get autoSleepDuration => 'Duração do timer';

  @override
  String get autoSleepWindow => 'Intervalo de horário';

  @override
  String get autoSleepWindowsPerDay => 'Intervalo de horário por dia';

  @override
  String autoSleepFrom(String time) {
    return 'Das $time';
  }

  @override
  String autoSleepUntil(String time) {
    return 'Até $time';
  }

  @override
  String get autoSleepPickStart => 'Início';

  @override
  String get autoSleepPickEnd => 'Fim';

  @override
  String get autoSleepSameTimeError =>
      'O início e o fim não podem ser iguais – o intervalo teria 0 minutos. A alteração não foi aplicada.';

  @override
  String get autoSleepMidnightHint =>
      'Um intervalo que passa da meia-noite pertence ao dia em que começa: “sexta-feira das 22:00 às 04:00” vale de sexta à noite até sábado às 04:00.';

  @override
  String get autoSleepCopyToAll => 'Aplicar a todos os dias';

  @override
  String autoSleepCopiedToAll(String day) {
    return 'Horários de $day aplicados a todos os dias';
  }

  @override
  String get autoSleepAllDaysOff =>
      'Todos os dias estão desativados – o timer automático nunca vai começar.';

  @override
  String autoSleepStarted(String timer) {
    return 'Timer de desligamento iniciado automaticamente: $timer';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String autoSleepSpanSameDay(String length) {
    return 'Duração $length';
  }

  @override
  String autoSleepSpanNextDay(String length) {
    return 'Duração $length, termina no dia seguinte';
  }

  @override
  String autoSleepOverlapError(String day, String window) {
    return 'Se sobrepõe a $day ($window). A alteração não foi aplicada.';
  }
}
