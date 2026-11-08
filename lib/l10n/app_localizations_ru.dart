// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AA-AuralListen Podcatcher';

  @override
  String get navHome => 'Главная';

  @override
  String get navSubscriptions => 'Подписки';

  @override
  String get navPlaylists => 'Плейлисты';

  @override
  String get navDownloads => 'Загрузки';

  @override
  String get navSettings => 'Настройки';

  @override
  String get carNew => 'Новые';

  @override
  String carNotFound(String query) {
    return 'Ничего не найдено по запросу «$query»';
  }

  @override
  String get carNothingToPlay => 'Вы ещё ничего не слушали — выберите выпуск';

  @override
  String get placeholderComingSoon => 'Скоро';

  @override
  String get cancel => 'Отмена';

  @override
  String get loadError => 'Ошибка загрузки';

  @override
  String get homeEmpty => 'Выпусков пока нет';

  @override
  String get homeEmptyHint => 'Подпишитесь на подкасты во вкладке «Подписки».';

  @override
  String get subscriptionsEmpty => 'Подписок пока нет';

  @override
  String get subscriptionsEmptyHint => 'Добавьте первый подкаст по RSS-адресу.';

  @override
  String get addFeedAction => 'Добавить по RSS-адресу';

  @override
  String get addFeedTitle => 'Добавить подкаст';

  @override
  String get addFeedLabel => 'RSS-адрес';

  @override
  String get addFeedHint => 'https://example.com/feed.xml';

  @override
  String get addFeedSubmit => 'Добавить';

  @override
  String get subscribeErrorInvalidUrl => 'Это недействительный адрес.';

  @override
  String get subscribeErrorAlreadySubscribed =>
      'Вы уже подписаны на этот подкаст.';

  @override
  String get subscribeErrorNetwork =>
      'Не удалось загрузить ленту. Проверьте адрес и подключение к интернету.';

  @override
  String get subscribeErrorNotAFeed => 'По этому адресу нет ленты подкаста.';

  @override
  String refreshFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не удалось обновить $count ленты.',
      many: 'Не удалось обновить $count лент.',
      few: 'Не удалось обновить $count ленты.',
      one: 'Не удалось обновить $count ленту.',
    );
    return '$_temp0';
  }

  @override
  String get podcastNotFound => 'Подкаст не найден';

  @override
  String get podcastRefreshError => 'Последнее обновление не удалось';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска',
      many: '$count выпусков',
      few: '$count выпуска',
      one: '$count выпуск',
      zero: 'Нет выпусков',
    );
    return '$_temp0';
  }

  @override
  String get episodeNew => 'Новый';

  @override
  String get episodePlayed => 'Прослушан';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get unsubscribe => 'Отписаться';

  @override
  String get unsubscribeConfirmTitle => 'Отписаться?';

  @override
  String unsubscribeConfirmBody(String title) {
    return '«$title» и все его выпуски будут удалены из приложения.';
  }

  @override
  String get search => 'Поиск';

  @override
  String get searchHint => 'Поиск подкастов';

  @override
  String get searchStart => 'Ищите по названию, теме или автору';

  @override
  String get searchStartHint => 'Поиск в Apple Podcasts и fyyd.de';

  @override
  String get searchPopular => 'Популярное';

  @override
  String get searchNew => 'Новинки';

  @override
  String get subsSearchHint => 'Поиск в подписках';

  @override
  String get subsSearchClose => 'Закрыть поиск';

  @override
  String get searchClear => 'Очистить';

  @override
  String get subsSearchPodcasts => 'Подкасты';

  @override
  String get subsSearchEpisodes => 'Выпуски';

  @override
  String get subsSearchNothing => 'В ваших подписках ничего не найдено';

  @override
  String get subsSearchNothingHint =>
      'Новые подкасты можно найти через поиск на «Главной».';

  @override
  String get searchNoResults => 'Подкасты не найдены';

  @override
  String get searchFailed =>
      'Поиск не удался. Проверьте подключение к интернету.';

  @override
  String searchPartialFailure(String names) {
    return '$names недоступен — результаты неполные';
  }

  @override
  String get subscribed => 'В подписках';

  @override
  String get subscribeAction => 'Подписаться';

  @override
  String subscribedSnack(String title) {
    return 'Вы подписались на «$title»';
  }

  @override
  String get open => 'Открыть';

  @override
  String get ok => 'OK';

  @override
  String get settingsSectionSubscriptions => 'Подписки';

  @override
  String get opmlImport => 'Импорт OPML-файла';

  @override
  String get opmlImportSubtitle => 'Перенесите подписки из другого приложения';

  @override
  String get opmlInvalid => 'Файл не является корректным OPML-файлом.';

  @override
  String get opmlTooLarge => 'Файл слишком большой.';

  @override
  String get opmlEmpty => 'В файле не найдено подкастов.';

  @override
  String get opmlConfirmTitle => 'Импортировать подписки?';

  @override
  String opmlConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count подкаста.',
      many: 'Найдено $count подкастов.',
      few: 'Найдено $count подкаста.',
      one: 'Найден $count подкаст.',
    );
    return '$_temp0 Существующие подписки пропускаются.';
  }

  @override
  String get opmlImportAction => 'Импортировать';

  @override
  String opmlProgress(int done, int total) {
    return 'Импорт $done из $total …';
  }

  @override
  String get opmlResultTitle => 'Импорт завершён';

  @override
  String opmlResultBody(int added, int already, int failed) {
    return 'Новых: $added\nУже в подписках: $already\nС ошибкой: $failed';
  }

  @override
  String get opmlResultFailedList => 'Не импортированы:';

  @override
  String get playerPlay => 'Воспроизвести';

  @override
  String get playerPause => 'Пауза';

  @override
  String get playerRewind => 'Назад на 15 секунд';

  @override
  String get playerForward => 'Вперёд на 30 секунд';

  @override
  String get playerClose => 'Закрыть плеер';

  @override
  String get playerOpen => 'Открыть плеер';

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String get boostTitle => 'Усиление громкости';

  @override
  String get speedTitle => 'Скорость воспроизведения';

  @override
  String speedOff(String value) {
    return 'Обычная ($value)';
  }

  @override
  String speedButton(String value) {
    return 'Скорость: $value';
  }

  @override
  String get boostOff => 'Нет';

  @override
  String boostValue(int db) {
    return '+$db дБ';
  }

  @override
  String boostButton(String value) {
    return 'Усиление: $value';
  }

  @override
  String get speedPerPodcast => 'Только для этого подкаста';

  @override
  String get speedPerPodcastHint =>
      'Иначе скорость действует для всех подкастов без собственной настройки.';

  @override
  String get boostPerPodcast => 'Только для этого подкаста';

  @override
  String get boostPerPodcastHint =>
      'Иначе значение действует для всех подкастов без собственной настройки.';

  @override
  String get markPlayed => 'Отметить как прослушанный';

  @override
  String get markUnplayed => 'Отметить как непрослушанный';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get download => 'Скачать';

  @override
  String get episodeNumberingSeasons =>
      'Подкаст с сезонами: действуют номера из ленты по сезонам (напр. «S2·5»). Собственная нумерация здесь невозможна.';

  @override
  String get episodeNumberOffsetSeasons =>
      'Невозможно для подкастов с сезонами.';

  @override
  String get seasonAll => 'Все';

  @override
  String seasonLabel(int season) {
    return 'Сезон $season';
  }

  @override
  String get podcastWebsite => 'Сайт';

  @override
  String get podcastSupport => 'Поддержать';

  @override
  String get playlistContinueOffer =>
      'Нажмите, чтобы в конце продолжить следующим выпуском этого плейлиста';

  @override
  String get downloadCancel => 'Отменить загрузку';

  @override
  String get downloadDelete => 'Удалить загрузку';

  @override
  String get downloadRetry => 'Скачать заново';

  @override
  String get downloadDone => 'Скачано';

  @override
  String get episodeInPlaylist => 'В плейлисте';

  @override
  String get downloadFailed => 'Ошибка загрузки';

  @override
  String get downloadQueued => 'Ожидание …';

  @override
  String get downloadWifiWaiting => 'Ожидание Wi-Fi …';

  @override
  String get downloadNowMobile => 'Скачать сейчас через мобильный интернет';

  @override
  String downloadDeleteConfirm(String title) {
    return 'Удалить «$title» с устройства? Выпуск останется в приложении, его можно будет слушать онлайн.';
  }

  @override
  String get detailsEpisode => 'Выпуск';

  @override
  String get detailsAuthor => 'Автор';

  @override
  String get detailsPublished => 'Опубликован';

  @override
  String get detailsDuration => 'Длительность';

  @override
  String get detailsSize => 'Размер';

  @override
  String get detailsDownloadedAt => 'Скачан';

  @override
  String get detailsStatus => 'Загрузка';

  @override
  String get detailsListening => 'Прослушивание';

  @override
  String detailsInProgress(String position) {
    return 'Начат, на $position';
  }

  @override
  String detailsPlayedAt(String date) {
    return 'Прослушан $date';
  }

  @override
  String get downloadsEmpty => 'Загрузок нет';

  @override
  String get downloadsEmptyHint =>
      'Удерживайте выпуск → «Скачать» или включите автозагрузку в настройках подкаста.';

  @override
  String downloadsUsage(String used, String limit) {
    return 'Занято $used из $limit';
  }

  @override
  String get cleanUpNow => 'Очистить сейчас';

  @override
  String cleanUpResult(String freed) {
    return 'Освобождено $freed';
  }

  @override
  String get cleanUpNothing => 'Всё в порядке — удалять нечего.';

  @override
  String get podcastSettings => 'Настройки подкаста';

  @override
  String get autoDownload => 'Скачивать автоматически';

  @override
  String get autoDownloadOff => 'Выкл.';

  @override
  String get autoDownloadWifi => 'По Wi-Fi';

  @override
  String get autoDownloadAlways => 'Всегда';

  @override
  String get autoDownloadMax =>
      'Сколько непрослушанных выпусков держать на телефоне';

  @override
  String get autoDownloadMaxHint =>
      'Новые выпуски скачиваются, пока на телефоне не наберётся столько непрослушанных. Ничего при этом не удаляется.';

  @override
  String get autoDownloadPlaylist => 'Добавлять новые выпуски в плейлист';

  @override
  String get autoDownloadPlaylistNone => 'Нет';

  @override
  String get autoDownloadPlaylistHint =>
      'Без автозагрузки новые выпуски только добавляются в плейлист и воспроизводятся онлайн. Если плейлист был удалён, приложение в следующий раз создаст его заново.';

  @override
  String get episodeCounter => 'Номер выпуска на обложке';

  @override
  String get episodeCounterHint =>
      'Узкая полоска у левого края обложек в списках выпусков.';

  @override
  String get episodeNumbering => 'Нумерация';

  @override
  String get episodeNumberingFeed => 'Из ленты';

  @override
  String get episodeNumberingOwn => 'Своя';

  @override
  String get episodeNumberOffset => 'Смещение нумерации';

  @override
  String get episodeNumberOffsetHint =>
      'Прибавляется к счёту от самого старого выпуска — напр. −1, чтобы он стал нулевым.';

  @override
  String get episodeNumberOffsetFeed =>
      'Смещение действует только для своей нумерации.';

  @override
  String get episodeNumberDecrease => 'Уменьшить';

  @override
  String get episodeNumberIncrease => 'Увеличить';

  @override
  String get autoDeletePlayed => 'Удалять прослушанные выпуски';

  @override
  String get autoDeletePlayedHint =>
      'Через 96 часов после того, как выпуск прослушан до конца';

  @override
  String get settingsSectionDownloads => 'Загрузки';

  @override
  String get downloadLimit => 'Лимит памяти для загрузок';

  @override
  String get downloadLimitHint =>
      'При достижении лимита сначала удаляются прослушанные выпуски. Непрослушанные никогда не удаляются автоматически — вместо этого новое просто не скачивается.';

  @override
  String get playlistNew => 'Новый плейлист';

  @override
  String get playlistName => 'Название';

  @override
  String get playlistNameTaken => 'Плейлист с таким названием уже есть.';

  @override
  String ratingStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count звезды',
      many: '$count звёзд',
      few: '$count звезды',
      one: '$count звезда',
    );
    return '$_temp0';
  }

  @override
  String get ratingRemove => 'Убрать оценку';

  @override
  String get subsProvisional => 'Временные';

  @override
  String get podcastAdd => 'Добавить';

  @override
  String get podcastInAbos => 'Уже в ваших подписках';

  @override
  String addedProvisionalSnack(String title) {
    return '«$title» добавлен временно';
  }

  @override
  String get podcastRemove => 'Убрать';

  @override
  String get podcastRemoveConfirmTitle => 'Убрать подкаст?';

  @override
  String playlistActivated(String name) {
    return 'Плейлист «$name» активен';
  }

  @override
  String get playlistOpen => 'Открыть плейлист';

  @override
  String get finishedRemoval => 'Убирать прослушанные выпуски из плейлиста';

  @override
  String get finishedRemovalHint =>
      'Касается выпусков, прослушанных до конца, и «Отметить как прослушанный» (также «Все» и «до …»).';

  @override
  String get finishedRemovalNow => 'Сразу';

  @override
  String get finishedRemovalAfter5Minutes => 'Через 5 минут';

  @override
  String get finishedRemovalNever => 'Никогда';

  @override
  String get autoMarkNewPlayed =>
      'Автоматически отмечать новые как прослушанные';

  @override
  String chapterProgress(int percent) {
    return '$percent %';
  }

  @override
  String averageEpisodeLength(String duration) {
    return 'Ø $duration на выпуск';
  }

  @override
  String get averageEpisodeLengthUnknown => 'Средняя длительность неизвестна';

  @override
  String get episodeHot => 'Популярное: этот подкаст вы слушаете почти всегда';

  @override
  String get playlistColor => 'Цвет…';

  @override
  String get playlistColorNone => 'Без цвета';

  @override
  String get colorRed => 'Красный';

  @override
  String get colorOrange => 'Оранжевый';

  @override
  String get colorYellow => 'Жёлтый';

  @override
  String get colorGreen => 'Зелёный';

  @override
  String get colorBlue => 'Синий';

  @override
  String get colorIndigo => 'Индиго';

  @override
  String get colorViolet => 'Фиолетовый';

  @override
  String get appColor => 'Цвет приложения';

  @override
  String get appColorWallpaper => 'Как у обоев';

  @override
  String get colorPink => 'Розовый';

  @override
  String get colorPurple => 'Пурпурный';

  @override
  String get colorTeal => 'Бирюзовый';

  @override
  String get colorBrown => 'Коричневый';

  @override
  String get playlistRename => 'Переименовать';

  @override
  String get playlistDelete => 'Удалить плейлист';

  @override
  String playlistDeleteConfirm(String name) {
    return 'Удалить «$name»? Сами выпуски сохранятся.';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get create => 'Создать';

  @override
  String get playlistsEmpty => 'Плейлистов нет';

  @override
  String get playlistEmpty => 'Этот плейлист пуст';

  @override
  String get playlistEmptyHint => 'Удерживайте выпуск → «Добавить в плейлист…»';

  @override
  String playlistSummary(int count, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска',
      many: '$count выпусков',
      few: '$count выпуска',
      one: '$count выпуск',
      zero: 'Пусто',
    );
    return '$_temp0$duration';
  }

  @override
  String get addToPlaylist => 'Добавить в плейлист…';

  @override
  String get playNext => 'Воспроизвести следующим';

  @override
  String playNextHint(String playlist) {
    return 'Сразу после текущего выпуска в «$playlist»';
  }

  @override
  String playNextDone(String playlist) {
    return 'Будет следующим в «$playlist».';
  }

  @override
  String appendToPlaylist(String playlist) {
    return 'Добавить в конец «$playlist»';
  }

  @override
  String appendToPlaylistDone(String playlist) {
    return 'Добавлено в конец «$playlist».';
  }

  @override
  String get episodeDescription => 'Описание';

  @override
  String episodeNumberLabel(String number) {
    return 'Выпуск $number';
  }

  @override
  String get episodeNoDescription => 'У этого выпуска нет описания.';

  @override
  String addedToPlaylist(String name) {
    return 'Добавлено в «$name»';
  }

  @override
  String alreadyInPlaylist(String name) {
    return 'Уже в «$name»';
  }

  @override
  String get removedFromPlaylist => 'Убрано из плейлиста';

  @override
  String get removeFromPlaylistTitle => 'Убрать из плейлиста?';

  @override
  String removeFromPlaylistBody(String name) {
    return 'Выпуск уже есть в «$name». Убрать его оттуда?';
  }

  @override
  String get removeFromPlaylistAction => 'Убрать';

  @override
  String removedFromNamedPlaylist(String name) {
    return 'Убрано из «$name»';
  }

  @override
  String get undo => 'Отменить';

  @override
  String get playerNext => 'Следующий выпуск';

  @override
  String get playerPrevious => 'Предыдущий выпуск';

  @override
  String playingFromPlaylist(String name) {
    return 'Из плейлиста «$name»';
  }

  @override
  String get dragToReorder => 'Перетащите, чтобы изменить порядок';

  @override
  String get autoDownloadThemes => 'Темы для автозагрузки и плейлиста';

  @override
  String get autoDownloadThemesHint =>
      'Автоматически скачиваются или попадают в плейлист только отмеченные темы. Новые темы — только после того, как вы отметите их здесь.';

  @override
  String themeSubtitle(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска',
      many: '$count выпусков',
      few: '$count выпуска',
      one: '$count выпуск',
    );
    return '$_temp0 · последний $date';
  }

  @override
  String get selectAll => 'Все';

  @override
  String get selectNone => 'Ничего';

  @override
  String get chapters => 'Главы';

  @override
  String chaptersCount(int count) {
    return 'Главы ($count)';
  }

  @override
  String chapterCurrent(int index, int count, String title) {
    return 'Глава $index/$count: $title';
  }

  @override
  String get descriptionMore => 'Читать дальше';

  @override
  String get descriptionLess => 'Свернуть';

  @override
  String get bookmarkAdd => 'Добавить закладку';

  @override
  String bookmarkListHint(int count) {
    return 'Долгое нажатие: список закладок ($count)';
  }

  @override
  String get bookmarkNote => 'Заметка (необязательно)';

  @override
  String bookmarkAdded(String time) {
    return 'Закладка добавлена на $time';
  }

  @override
  String get bookmarks => 'Закладки';

  @override
  String bookmarksCount(int count) {
    return 'Закладки ($count)';
  }

  @override
  String get bookmarksEmpty => 'Закладок нет';

  @override
  String get history => 'История прослушивания';

  @override
  String get historySubtitle => 'Последние 100 выпусков, прослушанных до конца';

  @override
  String get historyEmpty => 'Пока ни один выпуск не прослушан до конца';

  @override
  String get historyEmptyHint =>
      'Выпуски появляются здесь, когда прослушаны до конца.';

  @override
  String get historyClear => 'Очистить историю';

  @override
  String get historyClearConfirm =>
      'Очистить всю историю прослушивания? Выпуски и позиции прослушивания сохранятся.';

  @override
  String get historyClearAction => 'Очистить';

  @override
  String get historyEpisodeGone =>
      'Этого выпуска больше нет в ваших подписках.';

  @override
  String get bookmarksEmptyHint => 'Нажмите «Добавить закладку» в плеере.';

  @override
  String refreshProgress(int current, int total, String title) {
    return '$current из $total · $title';
  }

  @override
  String get bookmarkDeleted => 'Закладка удалена';

  @override
  String get bookmarkDelete => 'Удалить закладку?';

  @override
  String bookmarkDeleteConfirm(String name) {
    return 'Точно удалить «$name»?';
  }

  @override
  String get bookmarkEditNote => 'Изменить заметку';

  @override
  String get settingsSectionListening => 'Прослушивание';

  @override
  String get markPlayedUntil => 'Отметить как прослушанные до …';

  @override
  String get markPlayedUntilPick => 'Все выпуски до (включительно)';

  @override
  String markPlayedUntilConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отметить $count выпуска до $date включительно как прослушанные?',
      many: 'Отметить $count выпусков до $date включительно как прослушанные?',
      few: 'Отметить $count выпуска до $date включительно как прослушанные?',
      one: 'Отметить $count выпуск до $date включительно как прослушанный?',
    );
    return '$_temp0';
  }

  @override
  String get markPlayedUntilHint =>
      'Они уходят из плейлистов (когда — см. «Убирать прослушанные выпуски из плейлиста» в настройках); скачанные выпуски удаляются через 96 часов.';

  @override
  String markPlayedUntilNone(String date) {
    return 'Нет непрослушанных выпусков до $date.';
  }

  @override
  String markPlayedUntilDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска отмечены как прослушанные',
      many: '$count выпусков отмечены как прослушанные',
      few: '$count выпуска отмечены как прослушанные',
      one: '$count выпуск отмечен как прослушанный',
    );
    return '$_temp0';
  }

  @override
  String get markAction => 'Отметить';

  @override
  String get settingsSectionAppearance => 'Оформление';

  @override
  String get designTitle => 'Дизайн';

  @override
  String get designSubtitle =>
      'Светлая/тёмная тема, цвет приложения, панель плеера';

  @override
  String get designSectionPanel => 'Панель плеера';

  @override
  String get designPanelHint =>
      'Фон за полосой прокрутки и кнопками в полноэкранном плеере. Он следует светлой/тёмной теме и цвету приложения.';

  @override
  String get panelDesignPlain => 'Простой';

  @override
  String get panelDesignStars => 'Звёздное небо';

  @override
  String get panelDesignAurora => 'Северное сияние';

  @override
  String get panelDesignWaves => 'Волны';

  @override
  String get panelDesignFacets => 'Кристалл';

  @override
  String get panelDesignCamouflage => 'Камуфляж';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get settingsSectionBackup => 'Резервная копия';

  @override
  String get opmlExport => 'Экспорт подписок в OPML';

  @override
  String get opmlExportSubtitle => 'Для других приложений подкастов';

  @override
  String get opmlExported => 'Подписки экспортированы';

  @override
  String get backupCreate => 'Создать резервную копию';

  @override
  String get backupCreateSubtitle =>
      'Подписки, прогресс, плейлисты, закладки, история, настройки — без аудиофайлов';

  @override
  String get backupCreated => 'Резервная копия сохранена';

  @override
  String get backupRestore => 'Восстановить из копии';

  @override
  String get backupRestoreSubtitle => 'Заменяет все текущие данные';

  @override
  String get backupInvalid =>
      'Файл не является резервной копией этого приложения.';

  @override
  String get backupTooNew =>
      'Резервная копия сделана более новой версией приложения.';

  @override
  String get backupConfirmTitle => 'Восстановить из копии?';

  @override
  String backupConfirmBody(
    String date,
    int podcasts,
    int episodes,
    int playlists,
    int bookmarks,
  ) {
    return 'Копия от $date:\nподписок: $podcasts · выпусков: $episodes · плейлистов: $playlists · закладок: $bookmarks\n\nВсе текущие данные будут заменены. Скачанные выпуски будут удалены.';
  }

  @override
  String get backupRestoreAction => 'Восстановить';

  @override
  String get backupRestored => 'Данные восстановлены';

  @override
  String get saveFailed => 'Не удалось сохранить';

  @override
  String get feedUrl => 'Адрес ленты';

  @override
  String get feedUrlChange => 'Изменить адрес ленты';

  @override
  String get feedUrlChangeHint =>
      'Нужно, только если подкаст переехал, а старый адрес больше не работает. Прогресс и загрузки сохранятся.';

  @override
  String get feedUrlChangeSubmit => 'Применить';

  @override
  String get feedUrlChanged => 'Адрес ленты изменён.';

  @override
  String get feedUrlTaken => 'Этот адрес уже принадлежит другой подписке.';

  @override
  String feedsMoved(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подкаста переехали ($names) — адреса обновлены.',
      many: '$count подкастов переехали ($names) — адреса обновлены.',
      few: '$count подкаста переехали ($names) — адреса обновлены.',
      one: '$count подкаст переехал ($names) — адрес обновлён.',
    );
    return '$_temp0';
  }

  @override
  String get chapterSkip => 'Пропустить';

  @override
  String get chapterSkipHint =>
      'Пропускать главы при воспроизведении (до перезапуска приложения)';

  @override
  String get backgroundPlayback => 'Фоновое воспроизведение';

  @override
  String get backgroundPlaybackUnrestricted =>
      'Батарея: без ограничений ✓ — нажмите, чтобы открыть настройки приложения';

  @override
  String get backgroundPlaybackRestricted =>
      'Включена оптимизация батареи: Android может остановить воспроизведение при выключенном экране. Нажмите, чтобы открыть настройки приложения → Батарея → «Без ограничений».';

  @override
  String unplayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрослушанного выпуска',
      many: '$count непрослушанных выпусков',
      few: '$count непрослушанных выпуска',
      one: '$count непрослушанный выпуск',
    );
    return '$_temp0';
  }

  @override
  String get playbackLoadFailed =>
      'Не удалось загрузить выпуск. Проверьте подключение к интернету.';

  @override
  String get playbackStalled =>
      'Воспроизведение зависло и поставлено на паузу. Позиция сохранена — проверьте подключение.';

  @override
  String get sleepTimer => 'Таймер сна';

  @override
  String get sleepTimerOff => 'Выключен';

  @override
  String sleepTimerMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get sleepTimerEpisodeEnd => 'До конца выпуска';

  @override
  String get sleepTimerEpisodeEndShort => 'До конца выпуска';

  @override
  String sleepTimerLeft(String time) {
    return 'Осталось $time';
  }

  @override
  String get playbackBrokenDownload =>
      'Загрузка была повреждена и удалена. Теперь выпуск воспроизводится онлайн.';

  @override
  String get playbackEpisodeGone => 'Этот выпуск больше недоступен у автора.';

  @override
  String get playbackUnsupported =>
      'Этот выпуск в формате, который невозможно воспроизвести.';

  @override
  String get playbackStreamChanged =>
      'После перезагрузки выпуск пришёл в другом виде (напр. с другой рекламой) — позиция может сместиться. Скачанных выпусков это не касается.';

  @override
  String get playbackStreamVaries =>
      'Этот подкаст вставляет меняющуюся рекламу при онлайн-прослушивании — продолжение может быть неточным. Совет: скачайте выпуск.';

  @override
  String get playNewEpisodes => 'Воспроизвести все новые выпуски';

  @override
  String playNewEpisodesHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска за последние 96 часов',
      many: '$count выпусков за последние 96 часов',
      few: '$count выпуска за последние 96 часов',
      one: '$count выпуск за последние 96 часов',
      zero: 'Нет новых выпусков за последние 96 часов',
    );
    return '$_temp0';
  }

  @override
  String get playUnplayedEpisodes => 'Воспроизвести все непрослушанные';

  @override
  String get addNewEpisodesToPlaylist => 'Все новые выпуски в плейлист';

  @override
  String get addUnplayedSinceToPlaylist => 'Непрослушанные с … в плейлист';

  @override
  String get addUnplayedEpisodesToPlaylist => 'Все непрослушанные в плейлист';

  @override
  String get podcastMenuPlayNew => 'Воспроизвести все новые выпуски';

  @override
  String get podcastMenuPlaySince => 'Воспроизвести непрослушанные с …';

  @override
  String get podcastMenuPlayUnplayed => 'Воспроизвести все непрослушанные';

  @override
  String get noUnplayedEpisodes => 'Непрослушанных выпусков нет.';

  @override
  String episodesAddedNoPlay(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска добавлены в «$playlist».',
      many: '$count выпусков добавлены в «$playlist».',
      few: '$count выпуска добавлены в «$playlist».',
      one: '$count выпуск добавлен в «$playlist».',
      zero: 'Все выпуски уже были в «$playlist».',
    );
    return '$_temp0';
  }

  @override
  String episodesAddedToPlaylist(int count, String playlist) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска добавлены в «$playlist».',
      many: '$count выпусков добавлены в «$playlist».',
      few: '$count выпуска добавлены в «$playlist».',
      one: '$count выпуск добавлен в «$playlist».',
      zero: 'Все выпуски уже были в «$playlist» — воспроизведение начинается.',
    );
    return '$_temp0';
  }

  @override
  String get sleepTimerCustom => 'Своё время…';

  @override
  String sleepTimerCustomSet(int minutes) {
    return 'Своё время: $minutes мин';
  }

  @override
  String get sleepTimerCustomLabel => 'Минуты';

  @override
  String sleepTimerCustomRange(int min, int max) {
    return 'От $min до $max минут';
  }

  @override
  String get sleepTimerStart => 'Запустить';

  @override
  String get playUnplayedSince => 'Воспроизвести непрослушанные с …';

  @override
  String get playUnplayedSinceHint => 'Выберите дату';

  @override
  String get playUnplayedSincePick => 'Непрослушанные выпуски с';

  @override
  String playUnplayedSinceNone(String date) {
    return 'Нет непрослушанных выпусков с $date.';
  }

  @override
  String get markUnplayedSince => 'Отметить как непрослушанные с …';

  @override
  String get markUnplayedSincePick =>
      'Все прослушанные выпуски с (включительно)';

  @override
  String markUnplayedSinceConfirm(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Отметить $count прослушанного выпуска с $date включительно как непрослушанные?',
      many:
          'Отметить $count прослушанных выпусков с $date включительно как непрослушанные?',
      few:
          'Отметить $count прослушанных выпуска с $date включительно как непрослушанные?',
      one:
          'Отметить $count прослушанный выпуск с $date включительно как непрослушанный?',
    );
    return '$_temp0';
  }

  @override
  String get markUnplayedSinceHint =>
      'Они начнутся сначала и больше не будут удаляться автоматически. Начатые выпуски остаются как есть.';

  @override
  String markUnplayedSinceNone(String date) {
    return 'Нет прослушанных выпусков с $date.';
  }

  @override
  String markUnplayedSinceDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выпуска отмечены как непрослушанные',
      many: '$count выпусков отмечены как непрослушанные',
      few: '$count выпуска отмечены как непрослушанные',
      one: '$count выпуск отмечен как непрослушанный',
    );
    return '$_temp0';
  }

  @override
  String get markAllPlayed => 'Отметить все как прослушанные';

  @override
  String get markAllUnplayed => 'Отметить все как непрослушанные';

  @override
  String markAllPlayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отметить $count выпуска как прослушанные?',
      many: 'Отметить $count выпусков как прослушанные?',
      few: 'Отметить $count выпуска как прослушанные?',
      one: 'Отметить $count выпуск как прослушанный?',
    );
    return '$_temp0';
  }

  @override
  String markAllUnplayedConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отметить $count прослушанного выпуска как непрослушанные?',
      many: 'Отметить $count прослушанных выпусков как непрослушанные?',
      few: 'Отметить $count прослушанных выпуска как непрослушанные?',
      one: 'Отметить $count прослушанный выпуск как непрослушанный?',
    );
    return '$_temp0';
  }

  @override
  String get playlistSortDateAscending => 'По дате, по возрастанию';

  @override
  String get playlistSortDateDescending => 'По дате, по убыванию';

  @override
  String get playlistSortNameAscending => 'По названию, по возрастанию';

  @override
  String playlistSortedDateAscending(String name) {
    return '«$name» отсортирован по дате (сначала старые).';
  }

  @override
  String playlistSortedDateDescending(String name) {
    return '«$name» отсортирован по дате (сначала новые).';
  }

  @override
  String playlistSortedName(String name) {
    return '«$name» отсортирован по названию (А–Я).';
  }

  @override
  String get playlistResume => 'Продолжить';

  @override
  String get playlistDownloadAll => 'Скачать все';

  @override
  String playlistDownloadAllConfirm(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скачать $count выпуска из «$name»?',
      many: 'Скачать $count выпусков из «$name»?',
      few: 'Скачать $count выпуска из «$name»?',
      one: 'Скачать $count выпуск из «$name»?',
    );
    return '$_temp0';
  }

  @override
  String playlistDownloadAllSize(String size) {
    return '(около $size)';
  }

  @override
  String get playlistDownloadAllHint =>
      'Загрузка начнётся сразу, в том числе через мобильный интернет. Уже скачанные выпуски пропускаются.';

  @override
  String get playlistDownloadAllNone =>
      'Все выпуски этого плейлиста уже скачаны.';

  @override
  String playlistDownloadAllStarted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Запущено $count загрузки.',
      many: 'Запущено $count загрузок.',
      few: 'Запущено $count загрузки.',
      one: 'Запущена $count загрузка.',
    );
    return '$_temp0';
  }

  @override
  String get infoTitle => 'Инфо';

  @override
  String get infoAbout => 'О приложении';

  @override
  String infoVersion(String name, int build) {
    return 'Версия $name (сборка $build)';
  }

  @override
  String infoVersionShort(String name) {
    return 'Версия $name';
  }

  @override
  String infoDeveloper(String name) {
    return 'Разработчик: $name';
  }

  @override
  String get infoPrivacy => 'Политика конфиденциальности';

  @override
  String get infoSourceCode => 'Исходный код на GitHub';

  @override
  String get infoLinkFailed => 'Не удалось открыть ссылку.';

  @override
  String get infoSourceCodeHint =>
      'Исходный код, релизы и возможность добровольно поддержать приложение';

  @override
  String get language => 'Язык';

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
  String get languagePickerWelcome =>
      'Добро пожаловать в подкаст-плеер «AA-AuralListen»';

  @override
  String get languagePickerTitle => 'Выберите язык';

  @override
  String get languagePickerHint =>
      'Язык можно будет изменить позже в настройках.';

  @override
  String get notificationChannelPlayback => 'Воспроизведение';
}
