// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PodcastsTable extends Podcasts with TableInfo<$PodcastsTable, Podcast> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _websiteUrlMeta = const VerificationMeta(
    'websiteUrl',
  );
  @override
  late final GeneratedColumn<String> websiteUrl = GeneratedColumn<String>(
    'website_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serialMeta = const VerificationMeta('serial');
  @override
  late final GeneratedColumn<bool> serial = GeneratedColumn<bool>(
    'serial',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("serial" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fundingUrlMeta = const VerificationMeta(
    'fundingUrl',
  );
  @override
  late final GeneratedColumn<String> fundingUrl = GeneratedColumn<String>(
    'funding_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fundingLabelMeta = const VerificationMeta(
    'fundingLabel',
  );
  @override
  late final GeneratedColumn<String> fundingLabel = GeneratedColumn<String>(
    'funding_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _provisionalMeta = const VerificationMeta(
    'provisional',
  );
  @override
  late final GeneratedColumn<bool> provisional = GeneratedColumn<bool>(
    'provisional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("provisional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastRefreshAtMeta = const VerificationMeta(
    'lastRefreshAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRefreshAt =
      GeneratedColumn<DateTime>(
        'last_refresh_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subscribedAtMeta = const VerificationMeta(
    'subscribedAt',
  );
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
    'subscribed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AutoDownloadMode, String>
  autoDownloadMode = GeneratedColumn<String>(
    'auto_download_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(AutoDownloadMode.off.name),
  ).withConverter<AutoDownloadMode>($PodcastsTable.$converterautoDownloadMode);
  static const VerificationMeta _autoDownloadThemesMeta =
      const VerificationMeta('autoDownloadThemes');
  @override
  late final GeneratedColumn<String> autoDownloadThemes =
      GeneratedColumn<String>(
        'auto_download_themes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _autoPlayedThemesMeta = const VerificationMeta(
    'autoPlayedThemes',
  );
  @override
  late final GeneratedColumn<String> autoPlayedThemes = GeneratedColumn<String>(
    'auto_played_themes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoDownloadMaxEpisodesMeta =
      const VerificationMeta('autoDownloadMaxEpisodes');
  @override
  late final GeneratedColumn<int> autoDownloadMaxEpisodes =
      GeneratedColumn<int>(
        'auto_download_max_episodes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(3),
      );
  static const VerificationMeta _autoDeletePlayedMeta = const VerificationMeta(
    'autoDeletePlayed',
  );
  @override
  late final GeneratedColumn<bool> autoDeletePlayed = GeneratedColumn<bool>(
    'auto_delete_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_delete_played" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _boostDbMeta = const VerificationMeta(
    'boostDb',
  );
  @override
  late final GeneratedColumn<double> boostDb = GeneratedColumn<double>(
    'boost_db',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoPlaylistIdMeta = const VerificationMeta(
    'autoPlaylistId',
  );
  @override
  late final GeneratedColumn<int> autoPlaylistId = GeneratedColumn<int>(
    'auto_playlist_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoPlaylistNameMeta = const VerificationMeta(
    'autoPlaylistName',
  );
  @override
  late final GeneratedColumn<String> autoPlaylistName = GeneratedColumn<String>(
    'auto_playlist_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeCounterMeta = const VerificationMeta(
    'episodeCounter',
  );
  @override
  late final GeneratedColumn<bool> episodeCounter = GeneratedColumn<bool>(
    'episode_counter',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("episode_counter" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _episodeNumberOffsetMeta =
      const VerificationMeta('episodeNumberOffset');
  @override
  late final GeneratedColumn<int> episodeNumberOffset = GeneratedColumn<int>(
    'episode_number_offset',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _episodeOwnCountMeta = const VerificationMeta(
    'episodeOwnCount',
  );
  @override
  late final GeneratedColumn<bool> episodeOwnCount = GeneratedColumn<bool>(
    'episode_own_count',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("episode_own_count" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _streamVariesMeta = const VerificationMeta(
    'streamVaries',
  );
  @override
  late final GeneratedColumn<bool> streamVaries = GeneratedColumn<bool>(
    'stream_varies',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("stream_varies" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedUrl,
    title,
    author,
    description,
    imageUrl,
    websiteUrl,
    serial,
    fundingUrl,
    fundingLabel,
    rating,
    provisional,
    etag,
    lastModified,
    lastRefreshAt,
    lastError,
    subscribedAt,
    autoDownloadMode,
    autoDownloadThemes,
    autoPlayedThemes,
    autoDownloadMaxEpisodes,
    autoDeletePlayed,
    boostDb,
    autoPlaylistId,
    autoPlaylistName,
    episodeCounter,
    episodeNumberOffset,
    episodeOwnCount,
    streamVaries,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcasts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Podcast> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('website_url')) {
      context.handle(
        _websiteUrlMeta,
        websiteUrl.isAcceptableOrUnknown(data['website_url']!, _websiteUrlMeta),
      );
    }
    if (data.containsKey('serial')) {
      context.handle(
        _serialMeta,
        serial.isAcceptableOrUnknown(data['serial']!, _serialMeta),
      );
    }
    if (data.containsKey('funding_url')) {
      context.handle(
        _fundingUrlMeta,
        fundingUrl.isAcceptableOrUnknown(data['funding_url']!, _fundingUrlMeta),
      );
    }
    if (data.containsKey('funding_label')) {
      context.handle(
        _fundingLabelMeta,
        fundingLabel.isAcceptableOrUnknown(
          data['funding_label']!,
          _fundingLabelMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('provisional')) {
      context.handle(
        _provisionalMeta,
        provisional.isAcceptableOrUnknown(
          data['provisional']!,
          _provisionalMeta,
        ),
      );
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('last_refresh_at')) {
      context.handle(
        _lastRefreshAtMeta,
        lastRefreshAt.isAcceptableOrUnknown(
          data['last_refresh_at']!,
          _lastRefreshAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
        _subscribedAtMeta,
        subscribedAt.isAcceptableOrUnknown(
          data['subscribed_at']!,
          _subscribedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribedAtMeta);
    }
    if (data.containsKey('auto_download_themes')) {
      context.handle(
        _autoDownloadThemesMeta,
        autoDownloadThemes.isAcceptableOrUnknown(
          data['auto_download_themes']!,
          _autoDownloadThemesMeta,
        ),
      );
    }
    if (data.containsKey('auto_played_themes')) {
      context.handle(
        _autoPlayedThemesMeta,
        autoPlayedThemes.isAcceptableOrUnknown(
          data['auto_played_themes']!,
          _autoPlayedThemesMeta,
        ),
      );
    }
    if (data.containsKey('auto_download_max_episodes')) {
      context.handle(
        _autoDownloadMaxEpisodesMeta,
        autoDownloadMaxEpisodes.isAcceptableOrUnknown(
          data['auto_download_max_episodes']!,
          _autoDownloadMaxEpisodesMeta,
        ),
      );
    }
    if (data.containsKey('auto_delete_played')) {
      context.handle(
        _autoDeletePlayedMeta,
        autoDeletePlayed.isAcceptableOrUnknown(
          data['auto_delete_played']!,
          _autoDeletePlayedMeta,
        ),
      );
    }
    if (data.containsKey('boost_db')) {
      context.handle(
        _boostDbMeta,
        boostDb.isAcceptableOrUnknown(data['boost_db']!, _boostDbMeta),
      );
    }
    if (data.containsKey('auto_playlist_id')) {
      context.handle(
        _autoPlaylistIdMeta,
        autoPlaylistId.isAcceptableOrUnknown(
          data['auto_playlist_id']!,
          _autoPlaylistIdMeta,
        ),
      );
    }
    if (data.containsKey('auto_playlist_name')) {
      context.handle(
        _autoPlaylistNameMeta,
        autoPlaylistName.isAcceptableOrUnknown(
          data['auto_playlist_name']!,
          _autoPlaylistNameMeta,
        ),
      );
    }
    if (data.containsKey('episode_counter')) {
      context.handle(
        _episodeCounterMeta,
        episodeCounter.isAcceptableOrUnknown(
          data['episode_counter']!,
          _episodeCounterMeta,
        ),
      );
    }
    if (data.containsKey('episode_number_offset')) {
      context.handle(
        _episodeNumberOffsetMeta,
        episodeNumberOffset.isAcceptableOrUnknown(
          data['episode_number_offset']!,
          _episodeNumberOffsetMeta,
        ),
      );
    }
    if (data.containsKey('episode_own_count')) {
      context.handle(
        _episodeOwnCountMeta,
        episodeOwnCount.isAcceptableOrUnknown(
          data['episode_own_count']!,
          _episodeOwnCountMeta,
        ),
      );
    }
    if (data.containsKey('stream_varies')) {
      context.handle(
        _streamVariesMeta,
        streamVaries.isAcceptableOrUnknown(
          data['stream_varies']!,
          _streamVariesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Podcast map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Podcast(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      websiteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website_url'],
      ),
      serial: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}serial'],
      )!,
      fundingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}funding_url'],
      ),
      fundingLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}funding_label'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      provisional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}provisional'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified'],
      ),
      lastRefreshAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_refresh_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      subscribedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}subscribed_at'],
      )!,
      autoDownloadMode: $PodcastsTable.$converterautoDownloadMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}auto_download_mode'],
        )!,
      ),
      autoDownloadThemes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_download_themes'],
      ),
      autoPlayedThemes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_played_themes'],
      ),
      autoDownloadMaxEpisodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_download_max_episodes'],
      )!,
      autoDeletePlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_delete_played'],
      )!,
      boostDb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}boost_db'],
      ),
      autoPlaylistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_playlist_id'],
      ),
      autoPlaylistName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_playlist_name'],
      ),
      episodeCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}episode_counter'],
      )!,
      episodeNumberOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_number_offset'],
      )!,
      episodeOwnCount: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}episode_own_count'],
      )!,
      streamVaries: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}stream_varies'],
      )!,
    );
  }

  @override
  $PodcastsTable createAlias(String alias) {
    return $PodcastsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AutoDownloadMode, String, String>
  $converterautoDownloadMode = const EnumNameConverter<AutoDownloadMode>(
    AutoDownloadMode.values,
  );
}

class Podcast extends DataClass implements Insertable<Podcast> {
  final int id;
  final String feedUrl;
  final String title;
  final String? author;
  final String? description;
  final String? imageUrl;
  final String? websiteUrl;

  /// `itunes:type` is `serial` (v18): told in order, so lists, "play all"
  /// and auto-download go oldest first (by season and episode).
  final bool serial;

  /// "Support" link from `podcast:funding` and its text (v17).
  final String? fundingUrl;
  final String? fundingLabel;

  /// The user's rating, 1–5 stars; 0 = not rated (v22). The Abos list is
  /// sorted by it, then by title.
  final int rating;

  /// Added via "+" or the directory but not subscribed yet (v23): can be
  /// streamed, but no downloads, playlists or settings; shown greyed out
  /// above the subscriptions until "Abonnieren" (docs/ui-ux.md).
  final bool provisional;
  final String? etag;
  final String? lastModified;
  final DateTime? lastRefreshAt;

  /// Last refresh error as a short technical message; null when the last refresh succeeded.
  final String? lastError;
  final DateTime subscribedAt;
  final AutoDownloadMode autoDownloadMode;

  /// Themes that are auto-downloaded (JSON list of theme keys, v5);
  /// null = all episodes regardless of theme.
  final String? autoDownloadThemes;

  /// Themes whose new episodes are marked as played when fetched (JSON list
  /// of theme keys, v25; null = none). Set per topic in its long-press menu.
  final String? autoPlayedThemes;
  final int autoDownloadMaxEpisodes;
  final bool autoDeletePlayed;

  /// Loudness boost in dB; null = use the global default.
  final double? boostDb;

  /// Auto-downloaded episodes are also added to this playlist – schema v10.
  /// Null = none. No foreign key on purpose: if the playlist was deleted,
  /// the next auto-download creates it again under [autoPlaylistName].
  final int? autoPlaylistId;
  final String? autoPlaylistName;

  /// Episode number on the covers (v11, docs/ui-ux.md): on/off and the
  /// offset added to the app's own count (not to the feed's numbers).
  final bool episodeCounter;
  final int episodeNumberOffset;

  /// Count by date even if the feed numbers its episodes (v12); only then the
  /// offset applies to such feeds.
  final bool episodeOwnCount;

  /// The server delivered a streamed episode differently on a reload (e.g.
  /// newly inserted ads), so resuming a stream can land elsewhere (v16).
  /// Set by the player; the app then recommends downloading (playback.md).
  final bool streamVaries;
  const Podcast({
    required this.id,
    required this.feedUrl,
    required this.title,
    this.author,
    this.description,
    this.imageUrl,
    this.websiteUrl,
    required this.serial,
    this.fundingUrl,
    this.fundingLabel,
    required this.rating,
    required this.provisional,
    this.etag,
    this.lastModified,
    this.lastRefreshAt,
    this.lastError,
    required this.subscribedAt,
    required this.autoDownloadMode,
    this.autoDownloadThemes,
    this.autoPlayedThemes,
    required this.autoDownloadMaxEpisodes,
    required this.autoDeletePlayed,
    this.boostDb,
    this.autoPlaylistId,
    this.autoPlaylistName,
    required this.episodeCounter,
    required this.episodeNumberOffset,
    required this.episodeOwnCount,
    required this.streamVaries,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feed_url'] = Variable<String>(feedUrl);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || websiteUrl != null) {
      map['website_url'] = Variable<String>(websiteUrl);
    }
    map['serial'] = Variable<bool>(serial);
    if (!nullToAbsent || fundingUrl != null) {
      map['funding_url'] = Variable<String>(fundingUrl);
    }
    if (!nullToAbsent || fundingLabel != null) {
      map['funding_label'] = Variable<String>(fundingLabel);
    }
    map['rating'] = Variable<int>(rating);
    map['provisional'] = Variable<bool>(provisional);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    if (!nullToAbsent || lastRefreshAt != null) {
      map['last_refresh_at'] = Variable<DateTime>(lastRefreshAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    {
      map['auto_download_mode'] = Variable<String>(
        $PodcastsTable.$converterautoDownloadMode.toSql(autoDownloadMode),
      );
    }
    if (!nullToAbsent || autoDownloadThemes != null) {
      map['auto_download_themes'] = Variable<String>(autoDownloadThemes);
    }
    if (!nullToAbsent || autoPlayedThemes != null) {
      map['auto_played_themes'] = Variable<String>(autoPlayedThemes);
    }
    map['auto_download_max_episodes'] = Variable<int>(autoDownloadMaxEpisodes);
    map['auto_delete_played'] = Variable<bool>(autoDeletePlayed);
    if (!nullToAbsent || boostDb != null) {
      map['boost_db'] = Variable<double>(boostDb);
    }
    if (!nullToAbsent || autoPlaylistId != null) {
      map['auto_playlist_id'] = Variable<int>(autoPlaylistId);
    }
    if (!nullToAbsent || autoPlaylistName != null) {
      map['auto_playlist_name'] = Variable<String>(autoPlaylistName);
    }
    map['episode_counter'] = Variable<bool>(episodeCounter);
    map['episode_number_offset'] = Variable<int>(episodeNumberOffset);
    map['episode_own_count'] = Variable<bool>(episodeOwnCount);
    map['stream_varies'] = Variable<bool>(streamVaries);
    return map;
  }

  PodcastsCompanion toCompanion(bool nullToAbsent) {
    return PodcastsCompanion(
      id: Value(id),
      feedUrl: Value(feedUrl),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      websiteUrl: websiteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(websiteUrl),
      serial: Value(serial),
      fundingUrl: fundingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(fundingUrl),
      fundingLabel: fundingLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(fundingLabel),
      rating: Value(rating),
      provisional: Value(provisional),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastRefreshAt: lastRefreshAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRefreshAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      subscribedAt: Value(subscribedAt),
      autoDownloadMode: Value(autoDownloadMode),
      autoDownloadThemes: autoDownloadThemes == null && nullToAbsent
          ? const Value.absent()
          : Value(autoDownloadThemes),
      autoPlayedThemes: autoPlayedThemes == null && nullToAbsent
          ? const Value.absent()
          : Value(autoPlayedThemes),
      autoDownloadMaxEpisodes: Value(autoDownloadMaxEpisodes),
      autoDeletePlayed: Value(autoDeletePlayed),
      boostDb: boostDb == null && nullToAbsent
          ? const Value.absent()
          : Value(boostDb),
      autoPlaylistId: autoPlaylistId == null && nullToAbsent
          ? const Value.absent()
          : Value(autoPlaylistId),
      autoPlaylistName: autoPlaylistName == null && nullToAbsent
          ? const Value.absent()
          : Value(autoPlaylistName),
      episodeCounter: Value(episodeCounter),
      episodeNumberOffset: Value(episodeNumberOffset),
      episodeOwnCount: Value(episodeOwnCount),
      streamVaries: Value(streamVaries),
    );
  }

  factory Podcast.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Podcast(
      id: serializer.fromJson<int>(json['id']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      websiteUrl: serializer.fromJson<String?>(json['websiteUrl']),
      serial: serializer.fromJson<bool>(json['serial']),
      fundingUrl: serializer.fromJson<String?>(json['fundingUrl']),
      fundingLabel: serializer.fromJson<String?>(json['fundingLabel']),
      rating: serializer.fromJson<int>(json['rating']),
      provisional: serializer.fromJson<bool>(json['provisional']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      lastRefreshAt: serializer.fromJson<DateTime?>(json['lastRefreshAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
      autoDownloadMode: $PodcastsTable.$converterautoDownloadMode.fromJson(
        serializer.fromJson<String>(json['autoDownloadMode']),
      ),
      autoDownloadThemes: serializer.fromJson<String?>(
        json['autoDownloadThemes'],
      ),
      autoPlayedThemes: serializer.fromJson<String?>(json['autoPlayedThemes']),
      autoDownloadMaxEpisodes: serializer.fromJson<int>(
        json['autoDownloadMaxEpisodes'],
      ),
      autoDeletePlayed: serializer.fromJson<bool>(json['autoDeletePlayed']),
      boostDb: serializer.fromJson<double?>(json['boostDb']),
      autoPlaylistId: serializer.fromJson<int?>(json['autoPlaylistId']),
      autoPlaylistName: serializer.fromJson<String?>(json['autoPlaylistName']),
      episodeCounter: serializer.fromJson<bool>(json['episodeCounter']),
      episodeNumberOffset: serializer.fromJson<int>(
        json['episodeNumberOffset'],
      ),
      episodeOwnCount: serializer.fromJson<bool>(json['episodeOwnCount']),
      streamVaries: serializer.fromJson<bool>(json['streamVaries']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'websiteUrl': serializer.toJson<String?>(websiteUrl),
      'serial': serializer.toJson<bool>(serial),
      'fundingUrl': serializer.toJson<String?>(fundingUrl),
      'fundingLabel': serializer.toJson<String?>(fundingLabel),
      'rating': serializer.toJson<int>(rating),
      'provisional': serializer.toJson<bool>(provisional),
      'etag': serializer.toJson<String?>(etag),
      'lastModified': serializer.toJson<String?>(lastModified),
      'lastRefreshAt': serializer.toJson<DateTime?>(lastRefreshAt),
      'lastError': serializer.toJson<String?>(lastError),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
      'autoDownloadMode': serializer.toJson<String>(
        $PodcastsTable.$converterautoDownloadMode.toJson(autoDownloadMode),
      ),
      'autoDownloadThemes': serializer.toJson<String?>(autoDownloadThemes),
      'autoPlayedThemes': serializer.toJson<String?>(autoPlayedThemes),
      'autoDownloadMaxEpisodes': serializer.toJson<int>(
        autoDownloadMaxEpisodes,
      ),
      'autoDeletePlayed': serializer.toJson<bool>(autoDeletePlayed),
      'boostDb': serializer.toJson<double?>(boostDb),
      'autoPlaylistId': serializer.toJson<int?>(autoPlaylistId),
      'autoPlaylistName': serializer.toJson<String?>(autoPlaylistName),
      'episodeCounter': serializer.toJson<bool>(episodeCounter),
      'episodeNumberOffset': serializer.toJson<int>(episodeNumberOffset),
      'episodeOwnCount': serializer.toJson<bool>(episodeOwnCount),
      'streamVaries': serializer.toJson<bool>(streamVaries),
    };
  }

  Podcast copyWith({
    int? id,
    String? feedUrl,
    String? title,
    Value<String?> author = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> websiteUrl = const Value.absent(),
    bool? serial,
    Value<String?> fundingUrl = const Value.absent(),
    Value<String?> fundingLabel = const Value.absent(),
    int? rating,
    bool? provisional,
    Value<String?> etag = const Value.absent(),
    Value<String?> lastModified = const Value.absent(),
    Value<DateTime?> lastRefreshAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    DateTime? subscribedAt,
    AutoDownloadMode? autoDownloadMode,
    Value<String?> autoDownloadThemes = const Value.absent(),
    Value<String?> autoPlayedThemes = const Value.absent(),
    int? autoDownloadMaxEpisodes,
    bool? autoDeletePlayed,
    Value<double?> boostDb = const Value.absent(),
    Value<int?> autoPlaylistId = const Value.absent(),
    Value<String?> autoPlaylistName = const Value.absent(),
    bool? episodeCounter,
    int? episodeNumberOffset,
    bool? episodeOwnCount,
    bool? streamVaries,
  }) => Podcast(
    id: id ?? this.id,
    feedUrl: feedUrl ?? this.feedUrl,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    websiteUrl: websiteUrl.present ? websiteUrl.value : this.websiteUrl,
    serial: serial ?? this.serial,
    fundingUrl: fundingUrl.present ? fundingUrl.value : this.fundingUrl,
    fundingLabel: fundingLabel.present ? fundingLabel.value : this.fundingLabel,
    rating: rating ?? this.rating,
    provisional: provisional ?? this.provisional,
    etag: etag.present ? etag.value : this.etag,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    lastRefreshAt: lastRefreshAt.present
        ? lastRefreshAt.value
        : this.lastRefreshAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    autoDownloadMode: autoDownloadMode ?? this.autoDownloadMode,
    autoDownloadThemes: autoDownloadThemes.present
        ? autoDownloadThemes.value
        : this.autoDownloadThemes,
    autoPlayedThemes: autoPlayedThemes.present
        ? autoPlayedThemes.value
        : this.autoPlayedThemes,
    autoDownloadMaxEpisodes:
        autoDownloadMaxEpisodes ?? this.autoDownloadMaxEpisodes,
    autoDeletePlayed: autoDeletePlayed ?? this.autoDeletePlayed,
    boostDb: boostDb.present ? boostDb.value : this.boostDb,
    autoPlaylistId: autoPlaylistId.present
        ? autoPlaylistId.value
        : this.autoPlaylistId,
    autoPlaylistName: autoPlaylistName.present
        ? autoPlaylistName.value
        : this.autoPlaylistName,
    episodeCounter: episodeCounter ?? this.episodeCounter,
    episodeNumberOffset: episodeNumberOffset ?? this.episodeNumberOffset,
    episodeOwnCount: episodeOwnCount ?? this.episodeOwnCount,
    streamVaries: streamVaries ?? this.streamVaries,
  );
  Podcast copyWithCompanion(PodcastsCompanion data) {
    return Podcast(
      id: data.id.present ? data.id.value : this.id,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      websiteUrl: data.websiteUrl.present
          ? data.websiteUrl.value
          : this.websiteUrl,
      serial: data.serial.present ? data.serial.value : this.serial,
      fundingUrl: data.fundingUrl.present
          ? data.fundingUrl.value
          : this.fundingUrl,
      fundingLabel: data.fundingLabel.present
          ? data.fundingLabel.value
          : this.fundingLabel,
      rating: data.rating.present ? data.rating.value : this.rating,
      provisional: data.provisional.present
          ? data.provisional.value
          : this.provisional,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastRefreshAt: data.lastRefreshAt.present
          ? data.lastRefreshAt.value
          : this.lastRefreshAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
      autoDownloadMode: data.autoDownloadMode.present
          ? data.autoDownloadMode.value
          : this.autoDownloadMode,
      autoDownloadThemes: data.autoDownloadThemes.present
          ? data.autoDownloadThemes.value
          : this.autoDownloadThemes,
      autoPlayedThemes: data.autoPlayedThemes.present
          ? data.autoPlayedThemes.value
          : this.autoPlayedThemes,
      autoDownloadMaxEpisodes: data.autoDownloadMaxEpisodes.present
          ? data.autoDownloadMaxEpisodes.value
          : this.autoDownloadMaxEpisodes,
      autoDeletePlayed: data.autoDeletePlayed.present
          ? data.autoDeletePlayed.value
          : this.autoDeletePlayed,
      boostDb: data.boostDb.present ? data.boostDb.value : this.boostDb,
      autoPlaylistId: data.autoPlaylistId.present
          ? data.autoPlaylistId.value
          : this.autoPlaylistId,
      autoPlaylistName: data.autoPlaylistName.present
          ? data.autoPlaylistName.value
          : this.autoPlaylistName,
      episodeCounter: data.episodeCounter.present
          ? data.episodeCounter.value
          : this.episodeCounter,
      episodeNumberOffset: data.episodeNumberOffset.present
          ? data.episodeNumberOffset.value
          : this.episodeNumberOffset,
      episodeOwnCount: data.episodeOwnCount.present
          ? data.episodeOwnCount.value
          : this.episodeOwnCount,
      streamVaries: data.streamVaries.present
          ? data.streamVaries.value
          : this.streamVaries,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Podcast(')
          ..write('id: $id, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('serial: $serial, ')
          ..write('fundingUrl: $fundingUrl, ')
          ..write('fundingLabel: $fundingLabel, ')
          ..write('rating: $rating, ')
          ..write('provisional: $provisional, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastRefreshAt: $lastRefreshAt, ')
          ..write('lastError: $lastError, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('autoDownloadMode: $autoDownloadMode, ')
          ..write('autoDownloadThemes: $autoDownloadThemes, ')
          ..write('autoPlayedThemes: $autoPlayedThemes, ')
          ..write('autoDownloadMaxEpisodes: $autoDownloadMaxEpisodes, ')
          ..write('autoDeletePlayed: $autoDeletePlayed, ')
          ..write('boostDb: $boostDb, ')
          ..write('autoPlaylistId: $autoPlaylistId, ')
          ..write('autoPlaylistName: $autoPlaylistName, ')
          ..write('episodeCounter: $episodeCounter, ')
          ..write('episodeNumberOffset: $episodeNumberOffset, ')
          ..write('episodeOwnCount: $episodeOwnCount, ')
          ..write('streamVaries: $streamVaries')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    feedUrl,
    title,
    author,
    description,
    imageUrl,
    websiteUrl,
    serial,
    fundingUrl,
    fundingLabel,
    rating,
    provisional,
    etag,
    lastModified,
    lastRefreshAt,
    lastError,
    subscribedAt,
    autoDownloadMode,
    autoDownloadThemes,
    autoPlayedThemes,
    autoDownloadMaxEpisodes,
    autoDeletePlayed,
    boostDb,
    autoPlaylistId,
    autoPlaylistName,
    episodeCounter,
    episodeNumberOffset,
    episodeOwnCount,
    streamVaries,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Podcast &&
          other.id == this.id &&
          other.feedUrl == this.feedUrl &&
          other.title == this.title &&
          other.author == this.author &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.websiteUrl == this.websiteUrl &&
          other.serial == this.serial &&
          other.fundingUrl == this.fundingUrl &&
          other.fundingLabel == this.fundingLabel &&
          other.rating == this.rating &&
          other.provisional == this.provisional &&
          other.etag == this.etag &&
          other.lastModified == this.lastModified &&
          other.lastRefreshAt == this.lastRefreshAt &&
          other.lastError == this.lastError &&
          other.subscribedAt == this.subscribedAt &&
          other.autoDownloadMode == this.autoDownloadMode &&
          other.autoDownloadThemes == this.autoDownloadThemes &&
          other.autoPlayedThemes == this.autoPlayedThemes &&
          other.autoDownloadMaxEpisodes == this.autoDownloadMaxEpisodes &&
          other.autoDeletePlayed == this.autoDeletePlayed &&
          other.boostDb == this.boostDb &&
          other.autoPlaylistId == this.autoPlaylistId &&
          other.autoPlaylistName == this.autoPlaylistName &&
          other.episodeCounter == this.episodeCounter &&
          other.episodeNumberOffset == this.episodeNumberOffset &&
          other.episodeOwnCount == this.episodeOwnCount &&
          other.streamVaries == this.streamVaries);
}

class PodcastsCompanion extends UpdateCompanion<Podcast> {
  final Value<int> id;
  final Value<String> feedUrl;
  final Value<String> title;
  final Value<String?> author;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<String?> websiteUrl;
  final Value<bool> serial;
  final Value<String?> fundingUrl;
  final Value<String?> fundingLabel;
  final Value<int> rating;
  final Value<bool> provisional;
  final Value<String?> etag;
  final Value<String?> lastModified;
  final Value<DateTime?> lastRefreshAt;
  final Value<String?> lastError;
  final Value<DateTime> subscribedAt;
  final Value<AutoDownloadMode> autoDownloadMode;
  final Value<String?> autoDownloadThemes;
  final Value<String?> autoPlayedThemes;
  final Value<int> autoDownloadMaxEpisodes;
  final Value<bool> autoDeletePlayed;
  final Value<double?> boostDb;
  final Value<int?> autoPlaylistId;
  final Value<String?> autoPlaylistName;
  final Value<bool> episodeCounter;
  final Value<int> episodeNumberOffset;
  final Value<bool> episodeOwnCount;
  final Value<bool> streamVaries;
  const PodcastsCompanion({
    this.id = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.serial = const Value.absent(),
    this.fundingUrl = const Value.absent(),
    this.fundingLabel = const Value.absent(),
    this.rating = const Value.absent(),
    this.provisional = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastRefreshAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.autoDownloadMode = const Value.absent(),
    this.autoDownloadThemes = const Value.absent(),
    this.autoPlayedThemes = const Value.absent(),
    this.autoDownloadMaxEpisodes = const Value.absent(),
    this.autoDeletePlayed = const Value.absent(),
    this.boostDb = const Value.absent(),
    this.autoPlaylistId = const Value.absent(),
    this.autoPlaylistName = const Value.absent(),
    this.episodeCounter = const Value.absent(),
    this.episodeNumberOffset = const Value.absent(),
    this.episodeOwnCount = const Value.absent(),
    this.streamVaries = const Value.absent(),
  });
  PodcastsCompanion.insert({
    this.id = const Value.absent(),
    required String feedUrl,
    required String title,
    this.author = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.serial = const Value.absent(),
    this.fundingUrl = const Value.absent(),
    this.fundingLabel = const Value.absent(),
    this.rating = const Value.absent(),
    this.provisional = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastRefreshAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime subscribedAt,
    this.autoDownloadMode = const Value.absent(),
    this.autoDownloadThemes = const Value.absent(),
    this.autoPlayedThemes = const Value.absent(),
    this.autoDownloadMaxEpisodes = const Value.absent(),
    this.autoDeletePlayed = const Value.absent(),
    this.boostDb = const Value.absent(),
    this.autoPlaylistId = const Value.absent(),
    this.autoPlaylistName = const Value.absent(),
    this.episodeCounter = const Value.absent(),
    this.episodeNumberOffset = const Value.absent(),
    this.episodeOwnCount = const Value.absent(),
    this.streamVaries = const Value.absent(),
  }) : feedUrl = Value(feedUrl),
       title = Value(title),
       subscribedAt = Value(subscribedAt);
  static Insertable<Podcast> custom({
    Expression<int>? id,
    Expression<String>? feedUrl,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? websiteUrl,
    Expression<bool>? serial,
    Expression<String>? fundingUrl,
    Expression<String>? fundingLabel,
    Expression<int>? rating,
    Expression<bool>? provisional,
    Expression<String>? etag,
    Expression<String>? lastModified,
    Expression<DateTime>? lastRefreshAt,
    Expression<String>? lastError,
    Expression<DateTime>? subscribedAt,
    Expression<String>? autoDownloadMode,
    Expression<String>? autoDownloadThemes,
    Expression<String>? autoPlayedThemes,
    Expression<int>? autoDownloadMaxEpisodes,
    Expression<bool>? autoDeletePlayed,
    Expression<double>? boostDb,
    Expression<int>? autoPlaylistId,
    Expression<String>? autoPlaylistName,
    Expression<bool>? episodeCounter,
    Expression<int>? episodeNumberOffset,
    Expression<bool>? episodeOwnCount,
    Expression<bool>? streamVaries,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (websiteUrl != null) 'website_url': websiteUrl,
      if (serial != null) 'serial': serial,
      if (fundingUrl != null) 'funding_url': fundingUrl,
      if (fundingLabel != null) 'funding_label': fundingLabel,
      if (rating != null) 'rating': rating,
      if (provisional != null) 'provisional': provisional,
      if (etag != null) 'etag': etag,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastRefreshAt != null) 'last_refresh_at': lastRefreshAt,
      if (lastError != null) 'last_error': lastError,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (autoDownloadMode != null) 'auto_download_mode': autoDownloadMode,
      if (autoDownloadThemes != null)
        'auto_download_themes': autoDownloadThemes,
      if (autoPlayedThemes != null) 'auto_played_themes': autoPlayedThemes,
      if (autoDownloadMaxEpisodes != null)
        'auto_download_max_episodes': autoDownloadMaxEpisodes,
      if (autoDeletePlayed != null) 'auto_delete_played': autoDeletePlayed,
      if (boostDb != null) 'boost_db': boostDb,
      if (autoPlaylistId != null) 'auto_playlist_id': autoPlaylistId,
      if (autoPlaylistName != null) 'auto_playlist_name': autoPlaylistName,
      if (episodeCounter != null) 'episode_counter': episodeCounter,
      if (episodeNumberOffset != null)
        'episode_number_offset': episodeNumberOffset,
      if (episodeOwnCount != null) 'episode_own_count': episodeOwnCount,
      if (streamVaries != null) 'stream_varies': streamVaries,
    });
  }

  PodcastsCompanion copyWith({
    Value<int>? id,
    Value<String>? feedUrl,
    Value<String>? title,
    Value<String?>? author,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<String?>? websiteUrl,
    Value<bool>? serial,
    Value<String?>? fundingUrl,
    Value<String?>? fundingLabel,
    Value<int>? rating,
    Value<bool>? provisional,
    Value<String?>? etag,
    Value<String?>? lastModified,
    Value<DateTime?>? lastRefreshAt,
    Value<String?>? lastError,
    Value<DateTime>? subscribedAt,
    Value<AutoDownloadMode>? autoDownloadMode,
    Value<String?>? autoDownloadThemes,
    Value<String?>? autoPlayedThemes,
    Value<int>? autoDownloadMaxEpisodes,
    Value<bool>? autoDeletePlayed,
    Value<double?>? boostDb,
    Value<int?>? autoPlaylistId,
    Value<String?>? autoPlaylistName,
    Value<bool>? episodeCounter,
    Value<int>? episodeNumberOffset,
    Value<bool>? episodeOwnCount,
    Value<bool>? streamVaries,
  }) {
    return PodcastsCompanion(
      id: id ?? this.id,
      feedUrl: feedUrl ?? this.feedUrl,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      serial: serial ?? this.serial,
      fundingUrl: fundingUrl ?? this.fundingUrl,
      fundingLabel: fundingLabel ?? this.fundingLabel,
      rating: rating ?? this.rating,
      provisional: provisional ?? this.provisional,
      etag: etag ?? this.etag,
      lastModified: lastModified ?? this.lastModified,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
      lastError: lastError ?? this.lastError,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      autoDownloadMode: autoDownloadMode ?? this.autoDownloadMode,
      autoDownloadThemes: autoDownloadThemes ?? this.autoDownloadThemes,
      autoPlayedThemes: autoPlayedThemes ?? this.autoPlayedThemes,
      autoDownloadMaxEpisodes:
          autoDownloadMaxEpisodes ?? this.autoDownloadMaxEpisodes,
      autoDeletePlayed: autoDeletePlayed ?? this.autoDeletePlayed,
      boostDb: boostDb ?? this.boostDb,
      autoPlaylistId: autoPlaylistId ?? this.autoPlaylistId,
      autoPlaylistName: autoPlaylistName ?? this.autoPlaylistName,
      episodeCounter: episodeCounter ?? this.episodeCounter,
      episodeNumberOffset: episodeNumberOffset ?? this.episodeNumberOffset,
      episodeOwnCount: episodeOwnCount ?? this.episodeOwnCount,
      streamVaries: streamVaries ?? this.streamVaries,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (websiteUrl.present) {
      map['website_url'] = Variable<String>(websiteUrl.value);
    }
    if (serial.present) {
      map['serial'] = Variable<bool>(serial.value);
    }
    if (fundingUrl.present) {
      map['funding_url'] = Variable<String>(fundingUrl.value);
    }
    if (fundingLabel.present) {
      map['funding_label'] = Variable<String>(fundingLabel.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (provisional.present) {
      map['provisional'] = Variable<bool>(provisional.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (lastRefreshAt.present) {
      map['last_refresh_at'] = Variable<DateTime>(lastRefreshAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    if (autoDownloadMode.present) {
      map['auto_download_mode'] = Variable<String>(
        $PodcastsTable.$converterautoDownloadMode.toSql(autoDownloadMode.value),
      );
    }
    if (autoDownloadThemes.present) {
      map['auto_download_themes'] = Variable<String>(autoDownloadThemes.value);
    }
    if (autoPlayedThemes.present) {
      map['auto_played_themes'] = Variable<String>(autoPlayedThemes.value);
    }
    if (autoDownloadMaxEpisodes.present) {
      map['auto_download_max_episodes'] = Variable<int>(
        autoDownloadMaxEpisodes.value,
      );
    }
    if (autoDeletePlayed.present) {
      map['auto_delete_played'] = Variable<bool>(autoDeletePlayed.value);
    }
    if (boostDb.present) {
      map['boost_db'] = Variable<double>(boostDb.value);
    }
    if (autoPlaylistId.present) {
      map['auto_playlist_id'] = Variable<int>(autoPlaylistId.value);
    }
    if (autoPlaylistName.present) {
      map['auto_playlist_name'] = Variable<String>(autoPlaylistName.value);
    }
    if (episodeCounter.present) {
      map['episode_counter'] = Variable<bool>(episodeCounter.value);
    }
    if (episodeNumberOffset.present) {
      map['episode_number_offset'] = Variable<int>(episodeNumberOffset.value);
    }
    if (episodeOwnCount.present) {
      map['episode_own_count'] = Variable<bool>(episodeOwnCount.value);
    }
    if (streamVaries.present) {
      map['stream_varies'] = Variable<bool>(streamVaries.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastsCompanion(')
          ..write('id: $id, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('serial: $serial, ')
          ..write('fundingUrl: $fundingUrl, ')
          ..write('fundingLabel: $fundingLabel, ')
          ..write('rating: $rating, ')
          ..write('provisional: $provisional, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastRefreshAt: $lastRefreshAt, ')
          ..write('lastError: $lastError, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('autoDownloadMode: $autoDownloadMode, ')
          ..write('autoDownloadThemes: $autoDownloadThemes, ')
          ..write('autoPlayedThemes: $autoPlayedThemes, ')
          ..write('autoDownloadMaxEpisodes: $autoDownloadMaxEpisodes, ')
          ..write('autoDeletePlayed: $autoDeletePlayed, ')
          ..write('boostDb: $boostDb, ')
          ..write('autoPlaylistId: $autoPlaylistId, ')
          ..write('autoPlaylistName: $autoPlaylistName, ')
          ..write('episodeCounter: $episodeCounter, ')
          ..write('episodeNumberOffset: $episodeNumberOffset, ')
          ..write('episodeOwnCount: $episodeOwnCount, ')
          ..write('streamVaries: $streamVaries')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcasts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _audioMimeTypeMeta = const VerificationMeta(
    'audioMimeType',
  );
  @override
  late final GeneratedColumn<String> audioMimeType = GeneratedColumn<String>(
    'audio_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioSizeBytesMeta = const VerificationMeta(
    'audioSizeBytes',
  );
  @override
  late final GeneratedColumn<int> audioSizeBytes = GeneratedColumn<int>(
    'audio_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pubDateMeta = const VerificationMeta(
    'pubDate',
  );
  @override
  late final GeneratedColumn<DateTime> pubDate = GeneratedColumn<DateTime>(
    'pub_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chaptersUrlMeta = const VerificationMeta(
    'chaptersUrl',
  );
  @override
  late final GeneratedColumn<String> chaptersUrl = GeneratedColumn<String>(
    'chapters_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeNumberMeta = const VerificationMeta(
    'episodeNumber',
  );
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
    'episode_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<int> season = GeneratedColumn<int>(
    'season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EpisodeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(EpisodeStatus.newEpisode.name),
      ).withConverter<EpisodeStatus>($EpisodesTable.$converterstatus);
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    podcastId,
    guid,
    title,
    description,
    audioUrl,
    audioMimeType,
    audioSizeBytes,
    durationMs,
    pubDate,
    imageUrl,
    chaptersUrl,
    theme,
    episodeNumber,
    season,
    status,
    positionMs,
    playedAt,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    } else if (isInserting) {
      context.missing(_podcastIdMeta);
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('audio_mime_type')) {
      context.handle(
        _audioMimeTypeMeta,
        audioMimeType.isAcceptableOrUnknown(
          data['audio_mime_type']!,
          _audioMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('audio_size_bytes')) {
      context.handle(
        _audioSizeBytesMeta,
        audioSizeBytes.isAcceptableOrUnknown(
          data['audio_size_bytes']!,
          _audioSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('pub_date')) {
      context.handle(
        _pubDateMeta,
        pubDate.isAcceptableOrUnknown(data['pub_date']!, _pubDateMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('chapters_url')) {
      context.handle(
        _chaptersUrlMeta,
        chaptersUrl.isAcceptableOrUnknown(
          data['chapters_url']!,
          _chaptersUrlMeta,
        ),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('episode_number')) {
      context.handle(
        _episodeNumberMeta,
        episodeNumber.isAcceptableOrUnknown(
          data['episode_number']!,
          _episodeNumberMeta,
        ),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {podcastId, guid},
  ];
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      audioMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_mime_type'],
      ),
      audioSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_size_bytes'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      pubDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pub_date'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      chaptersUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapters_url'],
      ),
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      ),
      episodeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_number'],
      ),
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season'],
      ),
      status: $EpisodesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EpisodeStatus, String, String> $converterstatus =
      const EnumNameConverter<EpisodeStatus>(EpisodeStatus.values);
}

class Episode extends DataClass implements Insertable<Episode> {
  final int id;
  final int podcastId;

  /// Feed guid, falling back to the enclosure URL. Unique per podcast.
  final String guid;
  final String title;

  /// Unused since v13 (always NULL): show notes live in [EpisodeNotes], so
  /// episode lists do not load them into memory. Kept because dropping a
  /// column would rebuild the table (foreign keys of downloads, playlists …).
  final String? description;
  final String audioUrl;
  final String? audioMimeType;
  final int? audioSizeBytes;
  final int? durationMs;
  final DateTime? pubDate;
  final String? imageUrl;
  final String? chaptersUrl;

  /// Sub-series of a network feed, e.g. `zum-thema` (v5). See feeds-and-directories.md.
  final String? theme;

  /// The feed's own episode number (`itunes:episode`), v11.
  final int? episodeNumber;

  /// `itunes:season` (v18): seasons are shown ("S2·5"), filtered and – for
  /// serial podcasts – ordered by (docs/ui-ux.md "Staffeln").
  final int? season;
  final EpisodeStatus status;
  final int positionMs;
  final DateTime? playedAt;
  final DateTime addedAt;
  const Episode({
    required this.id,
    required this.podcastId,
    required this.guid,
    required this.title,
    this.description,
    required this.audioUrl,
    this.audioMimeType,
    this.audioSizeBytes,
    this.durationMs,
    this.pubDate,
    this.imageUrl,
    this.chaptersUrl,
    this.theme,
    this.episodeNumber,
    this.season,
    required this.status,
    required this.positionMs,
    this.playedAt,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['podcast_id'] = Variable<int>(podcastId);
    map['guid'] = Variable<String>(guid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['audio_url'] = Variable<String>(audioUrl);
    if (!nullToAbsent || audioMimeType != null) {
      map['audio_mime_type'] = Variable<String>(audioMimeType);
    }
    if (!nullToAbsent || audioSizeBytes != null) {
      map['audio_size_bytes'] = Variable<int>(audioSizeBytes);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || pubDate != null) {
      map['pub_date'] = Variable<DateTime>(pubDate);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || chaptersUrl != null) {
      map['chapters_url'] = Variable<String>(chaptersUrl);
    }
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || episodeNumber != null) {
      map['episode_number'] = Variable<int>(episodeNumber);
    }
    if (!nullToAbsent || season != null) {
      map['season'] = Variable<int>(season);
    }
    {
      map['status'] = Variable<String>(
        $EpisodesTable.$converterstatus.toSql(status),
      );
    }
    map['position_ms'] = Variable<int>(positionMs);
    if (!nullToAbsent || playedAt != null) {
      map['played_at'] = Variable<DateTime>(playedAt);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      podcastId: Value(podcastId),
      guid: Value(guid),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      audioUrl: Value(audioUrl),
      audioMimeType: audioMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(audioMimeType),
      audioSizeBytes: audioSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(audioSizeBytes),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      pubDate: pubDate == null && nullToAbsent
          ? const Value.absent()
          : Value(pubDate),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      chaptersUrl: chaptersUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(chaptersUrl),
      theme: theme == null && nullToAbsent
          ? const Value.absent()
          : Value(theme),
      episodeNumber: episodeNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeNumber),
      season: season == null && nullToAbsent
          ? const Value.absent()
          : Value(season),
      status: Value(status),
      positionMs: Value(positionMs),
      playedAt: playedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(playedAt),
      addedAt: Value(addedAt),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<int>(json['id']),
      podcastId: serializer.fromJson<int>(json['podcastId']),
      guid: serializer.fromJson<String>(json['guid']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      audioMimeType: serializer.fromJson<String?>(json['audioMimeType']),
      audioSizeBytes: serializer.fromJson<int?>(json['audioSizeBytes']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      pubDate: serializer.fromJson<DateTime?>(json['pubDate']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      chaptersUrl: serializer.fromJson<String?>(json['chaptersUrl']),
      theme: serializer.fromJson<String?>(json['theme']),
      episodeNumber: serializer.fromJson<int?>(json['episodeNumber']),
      season: serializer.fromJson<int?>(json['season']),
      status: $EpisodesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      playedAt: serializer.fromJson<DateTime?>(json['playedAt']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'podcastId': serializer.toJson<int>(podcastId),
      'guid': serializer.toJson<String>(guid),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'audioMimeType': serializer.toJson<String?>(audioMimeType),
      'audioSizeBytes': serializer.toJson<int?>(audioSizeBytes),
      'durationMs': serializer.toJson<int?>(durationMs),
      'pubDate': serializer.toJson<DateTime?>(pubDate),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'chaptersUrl': serializer.toJson<String?>(chaptersUrl),
      'theme': serializer.toJson<String?>(theme),
      'episodeNumber': serializer.toJson<int?>(episodeNumber),
      'season': serializer.toJson<int?>(season),
      'status': serializer.toJson<String>(
        $EpisodesTable.$converterstatus.toJson(status),
      ),
      'positionMs': serializer.toJson<int>(positionMs),
      'playedAt': serializer.toJson<DateTime?>(playedAt),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Episode copyWith({
    int? id,
    int? podcastId,
    String? guid,
    String? title,
    Value<String?> description = const Value.absent(),
    String? audioUrl,
    Value<String?> audioMimeType = const Value.absent(),
    Value<int?> audioSizeBytes = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<DateTime?> pubDate = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> chaptersUrl = const Value.absent(),
    Value<String?> theme = const Value.absent(),
    Value<int?> episodeNumber = const Value.absent(),
    Value<int?> season = const Value.absent(),
    EpisodeStatus? status,
    int? positionMs,
    Value<DateTime?> playedAt = const Value.absent(),
    DateTime? addedAt,
  }) => Episode(
    id: id ?? this.id,
    podcastId: podcastId ?? this.podcastId,
    guid: guid ?? this.guid,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    audioUrl: audioUrl ?? this.audioUrl,
    audioMimeType: audioMimeType.present
        ? audioMimeType.value
        : this.audioMimeType,
    audioSizeBytes: audioSizeBytes.present
        ? audioSizeBytes.value
        : this.audioSizeBytes,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    pubDate: pubDate.present ? pubDate.value : this.pubDate,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    chaptersUrl: chaptersUrl.present ? chaptersUrl.value : this.chaptersUrl,
    theme: theme.present ? theme.value : this.theme,
    episodeNumber: episodeNumber.present
        ? episodeNumber.value
        : this.episodeNumber,
    season: season.present ? season.value : this.season,
    status: status ?? this.status,
    positionMs: positionMs ?? this.positionMs,
    playedAt: playedAt.present ? playedAt.value : this.playedAt,
    addedAt: addedAt ?? this.addedAt,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      guid: data.guid.present ? data.guid.value : this.guid,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      audioMimeType: data.audioMimeType.present
          ? data.audioMimeType.value
          : this.audioMimeType,
      audioSizeBytes: data.audioSizeBytes.present
          ? data.audioSizeBytes.value
          : this.audioSizeBytes,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      pubDate: data.pubDate.present ? data.pubDate.value : this.pubDate,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      chaptersUrl: data.chaptersUrl.present
          ? data.chaptersUrl.value
          : this.chaptersUrl,
      theme: data.theme.present ? data.theme.value : this.theme,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      season: data.season.present ? data.season.value : this.season,
      status: data.status.present ? data.status.value : this.status,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('audioMimeType: $audioMimeType, ')
          ..write('audioSizeBytes: $audioSizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('pubDate: $pubDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('chaptersUrl: $chaptersUrl, ')
          ..write('theme: $theme, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('season: $season, ')
          ..write('status: $status, ')
          ..write('positionMs: $positionMs, ')
          ..write('playedAt: $playedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    podcastId,
    guid,
    title,
    description,
    audioUrl,
    audioMimeType,
    audioSizeBytes,
    durationMs,
    pubDate,
    imageUrl,
    chaptersUrl,
    theme,
    episodeNumber,
    season,
    status,
    positionMs,
    playedAt,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.podcastId == this.podcastId &&
          other.guid == this.guid &&
          other.title == this.title &&
          other.description == this.description &&
          other.audioUrl == this.audioUrl &&
          other.audioMimeType == this.audioMimeType &&
          other.audioSizeBytes == this.audioSizeBytes &&
          other.durationMs == this.durationMs &&
          other.pubDate == this.pubDate &&
          other.imageUrl == this.imageUrl &&
          other.chaptersUrl == this.chaptersUrl &&
          other.theme == this.theme &&
          other.episodeNumber == this.episodeNumber &&
          other.season == this.season &&
          other.status == this.status &&
          other.positionMs == this.positionMs &&
          other.playedAt == this.playedAt &&
          other.addedAt == this.addedAt);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<int> id;
  final Value<int> podcastId;
  final Value<String> guid;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> audioUrl;
  final Value<String?> audioMimeType;
  final Value<int?> audioSizeBytes;
  final Value<int?> durationMs;
  final Value<DateTime?> pubDate;
  final Value<String?> imageUrl;
  final Value<String?> chaptersUrl;
  final Value<String?> theme;
  final Value<int?> episodeNumber;
  final Value<int?> season;
  final Value<EpisodeStatus> status;
  final Value<int> positionMs;
  final Value<DateTime?> playedAt;
  final Value<DateTime> addedAt;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.podcastId = const Value.absent(),
    this.guid = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.audioMimeType = const Value.absent(),
    this.audioSizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.chaptersUrl = const Value.absent(),
    this.theme = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.season = const Value.absent(),
    this.status = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  EpisodesCompanion.insert({
    this.id = const Value.absent(),
    required int podcastId,
    required String guid,
    required String title,
    this.description = const Value.absent(),
    required String audioUrl,
    this.audioMimeType = const Value.absent(),
    this.audioSizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.pubDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.chaptersUrl = const Value.absent(),
    this.theme = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.season = const Value.absent(),
    this.status = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.playedAt = const Value.absent(),
    required DateTime addedAt,
  }) : podcastId = Value(podcastId),
       guid = Value(guid),
       title = Value(title),
       audioUrl = Value(audioUrl),
       addedAt = Value(addedAt);
  static Insertable<Episode> custom({
    Expression<int>? id,
    Expression<int>? podcastId,
    Expression<String>? guid,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? audioUrl,
    Expression<String>? audioMimeType,
    Expression<int>? audioSizeBytes,
    Expression<int>? durationMs,
    Expression<DateTime>? pubDate,
    Expression<String>? imageUrl,
    Expression<String>? chaptersUrl,
    Expression<String>? theme,
    Expression<int>? episodeNumber,
    Expression<int>? season,
    Expression<String>? status,
    Expression<int>? positionMs,
    Expression<DateTime>? playedAt,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastId != null) 'podcast_id': podcastId,
      if (guid != null) 'guid': guid,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (audioMimeType != null) 'audio_mime_type': audioMimeType,
      if (audioSizeBytes != null) 'audio_size_bytes': audioSizeBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (pubDate != null) 'pub_date': pubDate,
      if (imageUrl != null) 'image_url': imageUrl,
      if (chaptersUrl != null) 'chapters_url': chaptersUrl,
      if (theme != null) 'theme': theme,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (season != null) 'season': season,
      if (status != null) 'status': status,
      if (positionMs != null) 'position_ms': positionMs,
      if (playedAt != null) 'played_at': playedAt,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  EpisodesCompanion copyWith({
    Value<int>? id,
    Value<int>? podcastId,
    Value<String>? guid,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? audioUrl,
    Value<String?>? audioMimeType,
    Value<int?>? audioSizeBytes,
    Value<int?>? durationMs,
    Value<DateTime?>? pubDate,
    Value<String?>? imageUrl,
    Value<String?>? chaptersUrl,
    Value<String?>? theme,
    Value<int?>? episodeNumber,
    Value<int?>? season,
    Value<EpisodeStatus>? status,
    Value<int>? positionMs,
    Value<DateTime?>? playedAt,
    Value<DateTime>? addedAt,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      guid: guid ?? this.guid,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      audioMimeType: audioMimeType ?? this.audioMimeType,
      audioSizeBytes: audioSizeBytes ?? this.audioSizeBytes,
      durationMs: durationMs ?? this.durationMs,
      pubDate: pubDate ?? this.pubDate,
      imageUrl: imageUrl ?? this.imageUrl,
      chaptersUrl: chaptersUrl ?? this.chaptersUrl,
      theme: theme ?? this.theme,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      season: season ?? this.season,
      status: status ?? this.status,
      positionMs: positionMs ?? this.positionMs,
      playedAt: playedAt ?? this.playedAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (audioMimeType.present) {
      map['audio_mime_type'] = Variable<String>(audioMimeType.value);
    }
    if (audioSizeBytes.present) {
      map['audio_size_bytes'] = Variable<int>(audioSizeBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (pubDate.present) {
      map['pub_date'] = Variable<DateTime>(pubDate.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (chaptersUrl.present) {
      map['chapters_url'] = Variable<String>(chaptersUrl.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (season.present) {
      map['season'] = Variable<int>(season.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $EpisodesTable.$converterstatus.toSql(status.value),
      );
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('guid: $guid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('audioMimeType: $audioMimeType, ')
          ..write('audioSizeBytes: $audioSizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('pubDate: $pubDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('chaptersUrl: $chaptersUrl, ')
          ..write('theme: $theme, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('season: $season, ')
          ..write('status: $status, ')
          ..write('positionMs: $positionMs, ')
          ..write('playedAt: $playedAt, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) =>
      Setting(key: key ?? this.key, value: value ?? this.value);
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DownloadState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DownloadState>($DownloadsTable.$converterstate);
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wifiOnlyMeta = const VerificationMeta(
    'wifiOnly',
  );
  @override
  late final GeneratedColumn<bool> wifiOnly = GeneratedColumn<bool>(
    'wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    episodeId,
    relativePath,
    state,
    sizeBytes,
    wifiOnly,
    failedAttempts,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('wifi_only')) {
      context.handle(
        _wifiOnlyMeta,
        wifiOnly.isAcceptableOrUnknown(data['wifi_only']!, _wifiOnlyMeta),
      );
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      state: $DownloadsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      wifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only'],
      )!,
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DownloadState, String, String> $converterstate =
      const EnumNameConverter<DownloadState>(DownloadState.values);
}

class Download extends DataClass implements Insertable<Download> {
  final int episodeId;

  /// File name inside the episodes directory, e.g. `42.mp3`.
  final String relativePath;
  final DownloadState state;
  final int? sizeBytes;

  /// Auto-downloads are queued with "Wi-Fi only" when the podcast says so.
  final bool wifiOnly;

  /// How often this download ended as failed (schema v21). Auto-download
  /// retries failed episodes up to `DownloadService.maxAutoAttempts`.
  final int failedAttempts;
  final DateTime createdAt;
  final DateTime? completedAt;
  const Download({
    required this.episodeId,
    required this.relativePath,
    required this.state,
    this.sizeBytes,
    required this.wifiOnly,
    required this.failedAttempts,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['relative_path'] = Variable<String>(relativePath);
    {
      map['state'] = Variable<String>(
        $DownloadsTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    map['wifi_only'] = Variable<bool>(wifiOnly);
    map['failed_attempts'] = Variable<int>(failedAttempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      episodeId: Value(episodeId),
      relativePath: Value(relativePath),
      state: Value(state),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      wifiOnly: Value(wifiOnly),
      failedAttempts: Value(failedAttempts),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      state: $DownloadsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      wifiOnly: serializer.fromJson<bool>(json['wifiOnly']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'relativePath': serializer.toJson<String>(relativePath),
      'state': serializer.toJson<String>(
        $DownloadsTable.$converterstate.toJson(state),
      ),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'wifiOnly': serializer.toJson<bool>(wifiOnly),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Download copyWith({
    int? episodeId,
    String? relativePath,
    DownloadState? state,
    Value<int?> sizeBytes = const Value.absent(),
    bool? wifiOnly,
    int? failedAttempts,
    DateTime? createdAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Download(
    episodeId: episodeId ?? this.episodeId,
    relativePath: relativePath ?? this.relativePath,
    state: state ?? this.state,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      state: data.state.present ? data.state.value : this.state,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      wifiOnly: data.wifiOnly.present ? data.wifiOnly.value : this.wifiOnly,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('episodeId: $episodeId, ')
          ..write('relativePath: $relativePath, ')
          ..write('state: $state, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    episodeId,
    relativePath,
    state,
    sizeBytes,
    wifiOnly,
    failedAttempts,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.episodeId == this.episodeId &&
          other.relativePath == this.relativePath &&
          other.state == this.state &&
          other.sizeBytes == this.sizeBytes &&
          other.wifiOnly == this.wifiOnly &&
          other.failedAttempts == this.failedAttempts &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<int> episodeId;
  final Value<String> relativePath;
  final Value<DownloadState> state;
  final Value<int?> sizeBytes;
  final Value<bool> wifiOnly;
  final Value<int> failedAttempts;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  const DownloadsCompanion({
    this.episodeId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.state = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.episodeId = const Value.absent(),
    required String relativePath,
    required DownloadState state,
    this.sizeBytes = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
  }) : relativePath = Value(relativePath),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<Download> custom({
    Expression<int>? episodeId,
    Expression<String>? relativePath,
    Expression<String>? state,
    Expression<int>? sizeBytes,
    Expression<bool>? wifiOnly,
    Expression<int>? failedAttempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (relativePath != null) 'relative_path': relativePath,
      if (state != null) 'state': state,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (wifiOnly != null) 'wifi_only': wifiOnly,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  DownloadsCompanion copyWith({
    Value<int>? episodeId,
    Value<String>? relativePath,
    Value<DownloadState>? state,
    Value<int?>? sizeBytes,
    Value<bool>? wifiOnly,
    Value<int>? failedAttempts,
    Value<DateTime>? createdAt,
    Value<DateTime?>? completedAt,
  }) {
    return DownloadsCompanion(
      episodeId: episodeId ?? this.episodeId,
      relativePath: relativePath ?? this.relativePath,
      state: state ?? this.state,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $DownloadsTable.$converterstate.toSql(state.value),
      );
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (wifiOnly.present) {
      map['wifi_only'] = Variable<bool>(wifiOnly.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('relativePath: $relativePath, ')
          ..write('state: $state, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, Playlist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastEpisodeIdMeta = const VerificationMeta(
    'lastEpisodeId',
  );
  @override
  late final GeneratedColumn<int> lastEpisodeId = GeneratedColumn<int>(
    'last_episode_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlaylistColor?, String> color =
      GeneratedColumn<String>(
        'color',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PlaylistColor?>($PlaylistsTable.$convertercolorn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortOrder,
    createdAt,
    lastEpisodeId,
    color,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<Playlist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_episode_id')) {
      context.handle(
        _lastEpisodeIdMeta,
        lastEpisodeId.isAcceptableOrUnknown(
          data['last_episode_id']!,
          _lastEpisodeIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Playlist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Playlist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastEpisodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_episode_id'],
      ),
      color: $PlaylistsTable.$convertercolorn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}color'],
        ),
      ),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlaylistColor, String, String> $convertercolor =
      const EnumNameConverter<PlaylistColor>(PlaylistColor.values);
  static JsonTypeConverter2<PlaylistColor?, String?, String?> $convertercolorn =
      JsonTypeConverter2.asNullable($convertercolor);
}

class Playlist extends DataClass implements Insertable<Playlist> {
  final int id;
  final String name;

  /// Order in the Playlists tab (ascending).
  final int sortOrder;
  final DateTime createdAt;

  /// Episode last played from this playlist ("Resume") – schema v7. No
  /// foreign key: it may point to an episode that has left the playlist
  /// meanwhile; resuming then starts at the top (docs/playlists.md).
  final int? lastEpisodeId;

  /// Category color (background in the lists) – schema v9. Null = none.
  final PlaylistColor? color;
  const Playlist({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
    this.lastEpisodeId,
    this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastEpisodeId != null) {
      map['last_episode_id'] = Variable<int>(lastEpisodeId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(
        $PlaylistsTable.$convertercolorn.toSql(color),
      );
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      lastEpisodeId: lastEpisodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEpisodeId),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Playlist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Playlist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastEpisodeId: serializer.fromJson<int?>(json['lastEpisodeId']),
      color: $PlaylistsTable.$convertercolorn.fromJson(
        serializer.fromJson<String?>(json['color']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastEpisodeId': serializer.toJson<int?>(lastEpisodeId),
      'color': serializer.toJson<String?>(
        $PlaylistsTable.$convertercolorn.toJson(color),
      ),
    };
  }

  Playlist copyWith({
    int? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
    Value<int?> lastEpisodeId = const Value.absent(),
    Value<PlaylistColor?> color = const Value.absent(),
  }) => Playlist(
    id: id ?? this.id,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    lastEpisodeId: lastEpisodeId.present
        ? lastEpisodeId.value
        : this.lastEpisodeId,
    color: color.present ? color.value : this.color,
  );
  Playlist copyWithCompanion(PlaylistsCompanion data) {
    return Playlist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastEpisodeId: data.lastEpisodeId.present
          ? data.lastEpisodeId.value
          : this.lastEpisodeId,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Playlist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastEpisodeId: $lastEpisodeId, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, sortOrder, createdAt, lastEpisodeId, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Playlist &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.lastEpisodeId == this.lastEpisodeId &&
          other.color == this.color);
}

class PlaylistsCompanion extends UpdateCompanion<Playlist> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int?> lastEpisodeId;
  final Value<PlaylistColor?> color;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastEpisodeId = const Value.absent(),
    this.color = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.lastEpisodeId = const Value.absent(),
    this.color = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Playlist> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? lastEpisodeId,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (lastEpisodeId != null) 'last_episode_id': lastEpisodeId,
      if (color != null) 'color': color,
    });
  }

  PlaylistsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int?>? lastEpisodeId,
    Value<PlaylistColor?>? color,
  }) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastEpisodeId: lastEpisodeId ?? this.lastEpisodeId,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastEpisodeId.present) {
      map['last_episode_id'] = Variable<int>(lastEpisodeId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(
        $PlaylistsTable.$convertercolorn.toSql(color.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastEpisodeId: $lastEpisodeId, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $PlaylistItemsTable extends PlaylistItems
    with TableInfo<$PlaylistItemsTable, PlaylistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    episodeId,
    position,
    addedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, episodeId};
  @override
  PlaylistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistItem(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $PlaylistItemsTable createAlias(String alias) {
    return $PlaylistItemsTable(attachedDatabase, alias);
  }
}

class PlaylistItem extends DataClass implements Insertable<PlaylistItem> {
  final int playlistId;
  final int episodeId;

  /// Order inside the playlist (ascending). New items get max + 1.
  final int position;
  final DateTime addedAt;

  /// Played to the end from this playlist but kept in it (setting "Fertige
  /// Folgen aus Playlist entfernen": after 10 minutes / never; v24). Counts
  /// only while the episode is still played (docs/playlists.md).
  final DateTime? finishedAt;
  const PlaylistItem({
    required this.playlistId,
    required this.episodeId,
    required this.position,
    required this.addedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<int>(playlistId);
    map['episode_id'] = Variable<int>(episodeId);
    map['position'] = Variable<int>(position);
    map['added_at'] = Variable<DateTime>(addedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  PlaylistItemsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistItemsCompanion(
      playlistId: Value(playlistId),
      episodeId: Value(episodeId),
      position: Value(position),
      addedAt: Value(addedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory PlaylistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistItem(
      playlistId: serializer.fromJson<int>(json['playlistId']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      position: serializer.fromJson<int>(json['position']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<int>(playlistId),
      'episodeId': serializer.toJson<int>(episodeId),
      'position': serializer.toJson<int>(position),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  PlaylistItem copyWith({
    int? playlistId,
    int? episodeId,
    int? position,
    DateTime? addedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => PlaylistItem(
    playlistId: playlistId ?? this.playlistId,
    episodeId: episodeId ?? this.episodeId,
    position: position ?? this.position,
    addedAt: addedAt ?? this.addedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  PlaylistItem copyWithCompanion(PlaylistItemsCompanion data) {
    return PlaylistItem(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      position: data.position.present ? data.position.value : this.position,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItem(')
          ..write('playlistId: $playlistId, ')
          ..write('episodeId: $episodeId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(playlistId, episodeId, position, addedAt, finishedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistItem &&
          other.playlistId == this.playlistId &&
          other.episodeId == this.episodeId &&
          other.position == this.position &&
          other.addedAt == this.addedAt &&
          other.finishedAt == this.finishedAt);
}

class PlaylistItemsCompanion extends UpdateCompanion<PlaylistItem> {
  final Value<int> playlistId;
  final Value<int> episodeId;
  final Value<int> position;
  final Value<DateTime> addedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const PlaylistItemsCompanion({
    this.playlistId = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.position = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistItemsCompanion.insert({
    required int playlistId,
    required int episodeId,
    required int position,
    required DateTime addedAt,
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       episodeId = Value(episodeId),
       position = Value(position),
       addedAt = Value(addedAt);
  static Insertable<PlaylistItem> custom({
    Expression<int>? playlistId,
    Expression<int>? episodeId,
    Expression<int>? position,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (episodeId != null) 'episode_id': episodeId,
      if (position != null) 'position': position,
      if (addedAt != null) 'added_at': addedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistItemsCompanion copyWith({
    Value<int>? playlistId,
    Value<int>? episodeId,
    Value<int>? position,
    Value<DateTime>? addedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? rowid,
  }) {
    return PlaylistItemsCompanion(
      playlistId: playlistId ?? this.playlistId,
      episodeId: episodeId ?? this.episodeId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('episodeId: $episodeId, ')
          ..write('position: $position, ')
          ..write('addedAt: $addedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    episodeId,
    startMs,
    title,
    url,
    imageUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId, startMs};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int episodeId;
  final int startMs;
  final String title;
  final String? url;
  final String? imageUrl;
  const Chapter({
    required this.episodeId,
    required this.startMs,
    required this.title,
    this.url,
    this.imageUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['start_ms'] = Variable<int>(startMs);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      episodeId: Value(episodeId),
      startMs: Value(startMs),
      title: Value(title),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String?>(json['url']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'startMs': serializer.toJson<int>(startMs),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String?>(url),
      'imageUrl': serializer.toJson<String?>(imageUrl),
    };
  }

  Chapter copyWith({
    int? episodeId,
    int? startMs,
    String? title,
    Value<String?> url = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
  }) => Chapter(
    episodeId: episodeId ?? this.episodeId,
    startMs: startMs ?? this.startMs,
    title: title ?? this.title,
    url: url.present ? url.value : this.url,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('episodeId: $episodeId, ')
          ..write('startMs: $startMs, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('imageUrl: $imageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(episodeId, startMs, title, url, imageUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.episodeId == this.episodeId &&
          other.startMs == this.startMs &&
          other.title == this.title &&
          other.url == this.url &&
          other.imageUrl == this.imageUrl);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> episodeId;
  final Value<int> startMs;
  final Value<String> title;
  final Value<String?> url;
  final Value<String?> imageUrl;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.episodeId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required int episodeId,
    required int startMs,
    required String title,
    this.url = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : episodeId = Value(episodeId),
       startMs = Value(startMs),
       title = Value(title);
  static Insertable<Chapter> custom({
    Expression<int>? episodeId,
    Expression<int>? startMs,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? imageUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (startMs != null) 'start_ms': startMs,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (imageUrl != null) 'image_url': imageUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? episodeId,
    Value<int>? startMs,
    Value<String>? title,
    Value<String?>? url,
    Value<String?>? imageUrl,
    Value<int>? rowid,
  }) {
    return ChaptersCompanion(
      episodeId: episodeId ?? this.episodeId,
      startMs: startMs ?? this.startMs,
      title: title ?? this.title,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('startMs: $startMs, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    episodeId,
    positionMs,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_episodeIdMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final int episodeId;
  final int positionMs;
  final String? note;
  final DateTime createdAt;
  const Bookmark({
    required this.id,
    required this.episodeId,
    required this.positionMs,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['episode_id'] = Variable<int>(episodeId);
    map['position_ms'] = Variable<int>(positionMs);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      episodeId: Value(episodeId),
      positionMs: Value(positionMs),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      episodeId: serializer.fromJson<int>(json['episodeId']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'episodeId': serializer.toJson<int>(episodeId),
      'positionMs': serializer.toJson<int>(positionMs),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith({
    int? id,
    int? episodeId,
    int? positionMs,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => Bookmark(
    id: id ?? this.id,
    episodeId: episodeId ?? this.episodeId,
    positionMs: positionMs ?? this.positionMs,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('positionMs: $positionMs, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, episodeId, positionMs, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.episodeId == this.episodeId &&
          other.positionMs == this.positionMs &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<int> episodeId;
  final Value<int> positionMs;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int episodeId,
    required int positionMs,
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : episodeId = Value(episodeId),
       positionMs = Value(positionMs),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<int>? episodeId,
    Expression<int>? positionMs,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (episodeId != null) 'episode_id': episodeId,
      if (positionMs != null) 'position_ms': positionMs,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? episodeId,
    Value<int>? positionMs,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      episodeId: episodeId ?? this.episodeId,
      positionMs: positionMs ?? this.positionMs,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('episodeId: $episodeId, ')
          ..write('positionMs: $positionMs, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EpisodeNotesTable extends EpisodeNotes
    with TableInfo<$EpisodeNotesTable, EpisodeNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodeNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [episodeId, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episode_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpisodeNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  EpisodeNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeNote(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $EpisodeNotesTable createAlias(String alias) {
    return $EpisodeNotesTable(attachedDatabase, alias);
  }
}

class EpisodeNote extends DataClass implements Insertable<EpisodeNote> {
  final int episodeId;
  final String notes;
  const EpisodeNote({required this.episodeId, required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  EpisodeNotesCompanion toCompanion(bool nullToAbsent) {
    return EpisodeNotesCompanion(
      episodeId: Value(episodeId),
      notes: Value(notes),
    );
  }

  factory EpisodeNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeNote(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'notes': serializer.toJson<String>(notes),
    };
  }

  EpisodeNote copyWith({int? episodeId, String? notes}) => EpisodeNote(
    episodeId: episodeId ?? this.episodeId,
    notes: notes ?? this.notes,
  );
  EpisodeNote copyWithCompanion(EpisodeNotesCompanion data) {
    return EpisodeNote(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeNote(')
          ..write('episodeId: $episodeId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(episodeId, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeNote &&
          other.episodeId == this.episodeId &&
          other.notes == this.notes);
}

class EpisodeNotesCompanion extends UpdateCompanion<EpisodeNote> {
  final Value<int> episodeId;
  final Value<String> notes;
  const EpisodeNotesCompanion({
    this.episodeId = const Value.absent(),
    this.notes = const Value.absent(),
  });
  EpisodeNotesCompanion.insert({
    this.episodeId = const Value.absent(),
    required String notes,
  }) : notes = Value(notes);
  static Insertable<EpisodeNote> custom({
    Expression<int>? episodeId,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (notes != null) 'notes': notes,
    });
  }

  EpisodeNotesCompanion copyWith({
    Value<int>? episodeId,
    Value<String>? notes,
  }) {
    return EpisodeNotesCompanion(
      episodeId: episodeId ?? this.episodeId,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeNotesCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PlayHistoryTable extends PlayHistory
    with TableInfo<$PlayHistoryTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeTitleMeta = const VerificationMeta(
    'episodeTitle',
  );
  @override
  late final GeneratedColumn<String> episodeTitle = GeneratedColumn<String>(
    'episode_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _podcastTitleMeta = const VerificationMeta(
    'podcastTitle',
  );
  @override
  late final GeneratedColumn<String> podcastTitle = GeneratedColumn<String>(
    'podcast_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedUrl,
    guid,
    episodeTitle,
    podcastTitle,
    imageUrl,
    durationMs,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'play_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('episode_title')) {
      context.handle(
        _episodeTitleMeta,
        episodeTitle.isAcceptableOrUnknown(
          data['episode_title']!,
          _episodeTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeTitleMeta);
    }
    if (data.containsKey('podcast_title')) {
      context.handle(
        _podcastTitleMeta,
        podcastTitle.isAcceptableOrUnknown(
          data['podcast_title']!,
          _podcastTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastTitleMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      episodeTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episode_title'],
      )!,
      podcastTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_title'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $PlayHistoryTable createAlias(String alias) {
    return $PlayHistoryTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final String feedUrl;
  final String guid;
  final String episodeTitle;
  final String podcastTitle;
  final String? imageUrl;
  final int? durationMs;
  final DateTime playedAt;
  const HistoryEntry({
    required this.id,
    required this.feedUrl,
    required this.guid,
    required this.episodeTitle,
    required this.podcastTitle,
    this.imageUrl,
    this.durationMs,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feed_url'] = Variable<String>(feedUrl);
    map['guid'] = Variable<String>(guid);
    map['episode_title'] = Variable<String>(episodeTitle);
    map['podcast_title'] = Variable<String>(podcastTitle);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  PlayHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlayHistoryCompanion(
      id: Value(id),
      feedUrl: Value(feedUrl),
      guid: Value(guid),
      episodeTitle: Value(episodeTitle),
      podcastTitle: Value(podcastTitle),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      playedAt: Value(playedAt),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      guid: serializer.fromJson<String>(json['guid']),
      episodeTitle: serializer.fromJson<String>(json['episodeTitle']),
      podcastTitle: serializer.fromJson<String>(json['podcastTitle']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'guid': serializer.toJson<String>(guid),
      'episodeTitle': serializer.toJson<String>(episodeTitle),
      'podcastTitle': serializer.toJson<String>(podcastTitle),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'durationMs': serializer.toJson<int?>(durationMs),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  HistoryEntry copyWith({
    int? id,
    String? feedUrl,
    String? guid,
    String? episodeTitle,
    String? podcastTitle,
    Value<String?> imageUrl = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    DateTime? playedAt,
  }) => HistoryEntry(
    id: id ?? this.id,
    feedUrl: feedUrl ?? this.feedUrl,
    guid: guid ?? this.guid,
    episodeTitle: episodeTitle ?? this.episodeTitle,
    podcastTitle: podcastTitle ?? this.podcastTitle,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    playedAt: playedAt ?? this.playedAt,
  );
  HistoryEntry copyWithCompanion(PlayHistoryCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      guid: data.guid.present ? data.guid.value : this.guid,
      episodeTitle: data.episodeTitle.present
          ? data.episodeTitle.value
          : this.episodeTitle,
      podcastTitle: data.podcastTitle.present
          ? data.podcastTitle.value
          : this.podcastTitle,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('guid: $guid, ')
          ..write('episodeTitle: $episodeTitle, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    feedUrl,
    guid,
    episodeTitle,
    podcastTitle,
    imageUrl,
    durationMs,
    playedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.feedUrl == this.feedUrl &&
          other.guid == this.guid &&
          other.episodeTitle == this.episodeTitle &&
          other.podcastTitle == this.podcastTitle &&
          other.imageUrl == this.imageUrl &&
          other.durationMs == this.durationMs &&
          other.playedAt == this.playedAt);
}

class PlayHistoryCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<String> feedUrl;
  final Value<String> guid;
  final Value<String> episodeTitle;
  final Value<String> podcastTitle;
  final Value<String?> imageUrl;
  final Value<int?> durationMs;
  final Value<DateTime> playedAt;
  const PlayHistoryCompanion({
    this.id = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.guid = const Value.absent(),
    this.episodeTitle = const Value.absent(),
    this.podcastTitle = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  PlayHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String feedUrl,
    required String guid,
    required String episodeTitle,
    required String podcastTitle,
    this.imageUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    required DateTime playedAt,
  }) : feedUrl = Value(feedUrl),
       guid = Value(guid),
       episodeTitle = Value(episodeTitle),
       podcastTitle = Value(podcastTitle),
       playedAt = Value(playedAt);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? feedUrl,
    Expression<String>? guid,
    Expression<String>? episodeTitle,
    Expression<String>? podcastTitle,
    Expression<String>? imageUrl,
    Expression<int>? durationMs,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (guid != null) 'guid': guid,
      if (episodeTitle != null) 'episode_title': episodeTitle,
      if (podcastTitle != null) 'podcast_title': podcastTitle,
      if (imageUrl != null) 'image_url': imageUrl,
      if (durationMs != null) 'duration_ms': durationMs,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  PlayHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? feedUrl,
    Value<String>? guid,
    Value<String>? episodeTitle,
    Value<String>? podcastTitle,
    Value<String?>? imageUrl,
    Value<int?>? durationMs,
    Value<DateTime>? playedAt,
  }) {
    return PlayHistoryCompanion(
      id: id ?? this.id,
      feedUrl: feedUrl ?? this.feedUrl,
      guid: guid ?? this.guid,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      imageUrl: imageUrl ?? this.imageUrl,
      durationMs: durationMs ?? this.durationMs,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (episodeTitle.present) {
      map['episode_title'] = Variable<String>(episodeTitle.value);
    }
    if (podcastTitle.present) {
      map['podcast_title'] = Variable<String>(podcastTitle.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayHistoryCompanion(')
          ..write('id: $id, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('guid: $guid, ')
          ..write('episodeTitle: $episodeTitle, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PodcastsTable podcasts = $PodcastsTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistItemsTable playlistItems = $PlaylistItemsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $EpisodeNotesTable episodeNotes = $EpisodeNotesTable(this);
  late final $PlayHistoryTable playHistory = $PlayHistoryTable(this);
  late final Index episodesPubDate = Index(
    'episodes_pub_date',
    'CREATE INDEX episodes_pub_date ON episodes (pub_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    podcasts,
    episodes,
    settings,
    downloads,
    playlists,
    playlistItems,
    chapters,
    bookmarks,
    episodeNotes,
    playHistory,
    episodesPubDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'podcasts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('episodes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'episodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('downloads', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'episodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'episodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('chapters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'episodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'episodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('episode_notes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PodcastsTableCreateCompanionBuilder = PodcastsCompanion Function({
  Value<int> id,
  required String feedUrl,
  required String title,
  Value<String?> author,
  Value<String?> description,
  Value<String?> imageUrl,
  Value<String?> websiteUrl,
  Value<bool> serial,
  Value<String?> fundingUrl,
  Value<String?> fundingLabel,
  Value<int> rating,
  Value<bool> provisional,
  Value<String?> etag,
  Value<String?> lastModified,
  Value<DateTime?> lastRefreshAt,
  Value<String?> lastError,
  required DateTime subscribedAt,
  Value<AutoDownloadMode> autoDownloadMode,
  Value<String?> autoDownloadThemes,
  Value<String?> autoPlayedThemes,
  Value<int> autoDownloadMaxEpisodes,
  Value<bool> autoDeletePlayed,
  Value<double?> boostDb,
  Value<int?> autoPlaylistId,
  Value<String?> autoPlaylistName,
  Value<bool> episodeCounter,
  Value<int> episodeNumberOffset,
  Value<bool> episodeOwnCount,
  Value<bool> streamVaries,
});
typedef $$PodcastsTableUpdateCompanionBuilder = PodcastsCompanion Function({
  Value<int> id,
  Value<String> feedUrl,
  Value<String> title,
  Value<String?> author,
  Value<String?> description,
  Value<String?> imageUrl,
  Value<String?> websiteUrl,
  Value<bool> serial,
  Value<String?> fundingUrl,
  Value<String?> fundingLabel,
  Value<int> rating,
  Value<bool> provisional,
  Value<String?> etag,
  Value<String?> lastModified,
  Value<DateTime?> lastRefreshAt,
  Value<String?> lastError,
  Value<DateTime> subscribedAt,
  Value<AutoDownloadMode> autoDownloadMode,
  Value<String?> autoDownloadThemes,
  Value<String?> autoPlayedThemes,
  Value<int> autoDownloadMaxEpisodes,
  Value<bool> autoDeletePlayed,
  Value<double?> boostDb,
  Value<int?> autoPlaylistId,
  Value<String?> autoPlaylistName,
  Value<bool> episodeCounter,
  Value<int> episodeNumberOffset,
  Value<bool> episodeOwnCount,
  Value<bool> streamVaries,
});

final class $$PodcastsTableReferences
    extends BaseReferences<_$AppDatabase, $PodcastsTable, Podcast> {
  $$PodcastsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.episodes,
    aliasName: 'podcasts__id__episodes__podcast_id',
  );

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PodcastsTableFilterComposer
    extends Composer<_$AppDatabase, $PodcastsTable> {
  $$PodcastsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fundingUrl => $composableBuilder(
    column: $table.fundingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fundingLabel => $composableBuilder(
    column: $table.fundingLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get provisional => $composableBuilder(
    column: $table.provisional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRefreshAt => $composableBuilder(
    column: $table.lastRefreshAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AutoDownloadMode, AutoDownloadMode, String>
  get autoDownloadMode => $composableBuilder(
    column: $table.autoDownloadMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get autoDownloadThemes => $composableBuilder(
    column: $table.autoDownloadThemes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoPlayedThemes => $composableBuilder(
    column: $table.autoPlayedThemes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoDownloadMaxEpisodes => $composableBuilder(
    column: $table.autoDownloadMaxEpisodes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoDeletePlayed => $composableBuilder(
    column: $table.autoDeletePlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get boostDb => $composableBuilder(
    column: $table.boostDb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoPlaylistId => $composableBuilder(
    column: $table.autoPlaylistId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoPlaylistName => $composableBuilder(
    column: $table.autoPlaylistName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get episodeCounter => $composableBuilder(
    column: $table.episodeCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeNumberOffset => $composableBuilder(
    column: $table.episodeNumberOffset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get episodeOwnCount => $composableBuilder(
    column: $table.episodeOwnCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get streamVaries => $composableBuilder(
    column: $table.streamVaries,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> episodesRefs(
    Expression<bool> Function($$EpisodesTableFilterComposer f) f,
  ) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastsTableOrderingComposer
    extends Composer<_$AppDatabase, $PodcastsTable> {
  $$PodcastsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get serial => $composableBuilder(
    column: $table.serial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fundingUrl => $composableBuilder(
    column: $table.fundingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fundingLabel => $composableBuilder(
    column: $table.fundingLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get provisional => $composableBuilder(
    column: $table.provisional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRefreshAt => $composableBuilder(
    column: $table.lastRefreshAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoDownloadMode => $composableBuilder(
    column: $table.autoDownloadMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoDownloadThemes => $composableBuilder(
    column: $table.autoDownloadThemes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoPlayedThemes => $composableBuilder(
    column: $table.autoPlayedThemes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoDownloadMaxEpisodes => $composableBuilder(
    column: $table.autoDownloadMaxEpisodes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoDeletePlayed => $composableBuilder(
    column: $table.autoDeletePlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get boostDb => $composableBuilder(
    column: $table.boostDb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoPlaylistId => $composableBuilder(
    column: $table.autoPlaylistId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoPlaylistName => $composableBuilder(
    column: $table.autoPlaylistName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get episodeCounter => $composableBuilder(
    column: $table.episodeCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeNumberOffset => $composableBuilder(
    column: $table.episodeNumberOffset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get episodeOwnCount => $composableBuilder(
    column: $table.episodeOwnCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get streamVaries => $composableBuilder(
    column: $table.streamVaries,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PodcastsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PodcastsTable> {
  $$PodcastsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get serial =>
      $composableBuilder(column: $table.serial, builder: (column) => column);

  GeneratedColumn<String> get fundingUrl => $composableBuilder(
    column: $table.fundingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fundingLabel => $composableBuilder(
    column: $table.fundingLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<bool> get provisional => $composableBuilder(
    column: $table.provisional,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRefreshAt => $composableBuilder(
    column: $table.lastRefreshAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AutoDownloadMode, String>
  get autoDownloadMode => $composableBuilder(
    column: $table.autoDownloadMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoDownloadThemes => $composableBuilder(
    column: $table.autoDownloadThemes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoPlayedThemes => $composableBuilder(
    column: $table.autoPlayedThemes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoDownloadMaxEpisodes => $composableBuilder(
    column: $table.autoDownloadMaxEpisodes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoDeletePlayed => $composableBuilder(
    column: $table.autoDeletePlayed,
    builder: (column) => column,
  );

  GeneratedColumn<double> get boostDb =>
      $composableBuilder(column: $table.boostDb, builder: (column) => column);

  GeneratedColumn<int> get autoPlaylistId => $composableBuilder(
    column: $table.autoPlaylistId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoPlaylistName => $composableBuilder(
    column: $table.autoPlaylistName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get episodeCounter => $composableBuilder(
    column: $table.episodeCounter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get episodeNumberOffset => $composableBuilder(
    column: $table.episodeNumberOffset,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get episodeOwnCount => $composableBuilder(
    column: $table.episodeOwnCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get streamVaries => $composableBuilder(
    column: $table.streamVaries,
    builder: (column) => column,
  );

  Expression<T> episodesRefs<T extends Object>(
    Expression<T> Function($$EpisodesTableAnnotationComposer a) f,
  ) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PodcastsTable,
          Podcast,
          $$PodcastsTableFilterComposer,
          $$PodcastsTableOrderingComposer,
          $$PodcastsTableAnnotationComposer,
          $$PodcastsTableCreateCompanionBuilder,
          $$PodcastsTableUpdateCompanionBuilder,
          (Podcast, $$PodcastsTableReferences),
          Podcast,
          PrefetchHooks Function({bool episodesRefs})
        > {
  $$PodcastsTableTableManager(_$AppDatabase db, $PodcastsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> websiteUrl = const Value.absent(),
                Value<bool> serial = const Value.absent(),
                Value<String?> fundingUrl = const Value.absent(),
                Value<String?> fundingLabel = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<bool> provisional = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<DateTime?> lastRefreshAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> subscribedAt = const Value.absent(),
                Value<AutoDownloadMode> autoDownloadMode = const Value.absent(),
                Value<String?> autoDownloadThemes = const Value.absent(),
                Value<String?> autoPlayedThemes = const Value.absent(),
                Value<int> autoDownloadMaxEpisodes = const Value.absent(),
                Value<bool> autoDeletePlayed = const Value.absent(),
                Value<double?> boostDb = const Value.absent(),
                Value<int?> autoPlaylistId = const Value.absent(),
                Value<String?> autoPlaylistName = const Value.absent(),
                Value<bool> episodeCounter = const Value.absent(),
                Value<int> episodeNumberOffset = const Value.absent(),
                Value<bool> episodeOwnCount = const Value.absent(),
                Value<bool> streamVaries = const Value.absent(),
              }) => PodcastsCompanion(
                id: id,
                feedUrl: feedUrl,
                title: title,
                author: author,
                description: description,
                imageUrl: imageUrl,
                websiteUrl: websiteUrl,
                serial: serial,
                fundingUrl: fundingUrl,
                fundingLabel: fundingLabel,
                rating: rating,
                provisional: provisional,
                etag: etag,
                lastModified: lastModified,
                lastRefreshAt: lastRefreshAt,
                lastError: lastError,
                subscribedAt: subscribedAt,
                autoDownloadMode: autoDownloadMode,
                autoDownloadThemes: autoDownloadThemes,
                autoPlayedThemes: autoPlayedThemes,
                autoDownloadMaxEpisodes: autoDownloadMaxEpisodes,
                autoDeletePlayed: autoDeletePlayed,
                boostDb: boostDb,
                autoPlaylistId: autoPlaylistId,
                autoPlaylistName: autoPlaylistName,
                episodeCounter: episodeCounter,
                episodeNumberOffset: episodeNumberOffset,
                episodeOwnCount: episodeOwnCount,
                streamVaries: streamVaries,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String feedUrl,
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> websiteUrl = const Value.absent(),
                Value<bool> serial = const Value.absent(),
                Value<String?> fundingUrl = const Value.absent(),
                Value<String?> fundingLabel = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<bool> provisional = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<DateTime?> lastRefreshAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime subscribedAt,
                Value<AutoDownloadMode> autoDownloadMode = const Value.absent(),
                Value<String?> autoDownloadThemes = const Value.absent(),
                Value<String?> autoPlayedThemes = const Value.absent(),
                Value<int> autoDownloadMaxEpisodes = const Value.absent(),
                Value<bool> autoDeletePlayed = const Value.absent(),
                Value<double?> boostDb = const Value.absent(),
                Value<int?> autoPlaylistId = const Value.absent(),
                Value<String?> autoPlaylistName = const Value.absent(),
                Value<bool> episodeCounter = const Value.absent(),
                Value<int> episodeNumberOffset = const Value.absent(),
                Value<bool> episodeOwnCount = const Value.absent(),
                Value<bool> streamVaries = const Value.absent(),
              }) => PodcastsCompanion.insert(
                id: id,
                feedUrl: feedUrl,
                title: title,
                author: author,
                description: description,
                imageUrl: imageUrl,
                websiteUrl: websiteUrl,
                serial: serial,
                fundingUrl: fundingUrl,
                fundingLabel: fundingLabel,
                rating: rating,
                provisional: provisional,
                etag: etag,
                lastModified: lastModified,
                lastRefreshAt: lastRefreshAt,
                lastError: lastError,
                subscribedAt: subscribedAt,
                autoDownloadMode: autoDownloadMode,
                autoDownloadThemes: autoDownloadThemes,
                autoPlayedThemes: autoPlayedThemes,
                autoDownloadMaxEpisodes: autoDownloadMaxEpisodes,
                autoDeletePlayed: autoDeletePlayed,
                boostDb: boostDb,
                autoPlaylistId: autoPlaylistId,
                autoPlaylistName: autoPlaylistName,
                episodeCounter: episodeCounter,
                episodeNumberOffset: episodeNumberOffset,
                episodeOwnCount: episodeOwnCount,
                streamVaries: streamVaries,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PodcastsTable, Podcast>(table),
                  $$PodcastsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (episodesRefs) db.episodes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (episodesRefs)
                    await $_getPrefetchedData<Podcast, $PodcastsTable, Episode>(
                      currentTable: table,
                      referencedTable: $$PodcastsTableReferences
                          ._episodesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PodcastsTableReferences(db, table, p0).episodesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.podcastId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PodcastsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PodcastsTable,
      Podcast,
      $$PodcastsTableFilterComposer,
      $$PodcastsTableOrderingComposer,
      $$PodcastsTableAnnotationComposer,
      $$PodcastsTableCreateCompanionBuilder,
      $$PodcastsTableUpdateCompanionBuilder,
      (Podcast, $$PodcastsTableReferences),
      Podcast,
      PrefetchHooks Function({bool episodesRefs})
    >;
typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  required int podcastId,
  required String guid,
  required String title,
  Value<String?> description,
  required String audioUrl,
  Value<String?> audioMimeType,
  Value<int?> audioSizeBytes,
  Value<int?> durationMs,
  Value<DateTime?> pubDate,
  Value<String?> imageUrl,
  Value<String?> chaptersUrl,
  Value<String?> theme,
  Value<int?> episodeNumber,
  Value<int?> season,
  Value<EpisodeStatus> status,
  Value<int> positionMs,
  Value<DateTime?> playedAt,
  required DateTime addedAt,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  Value<int> podcastId,
  Value<String> guid,
  Value<String> title,
  Value<String?> description,
  Value<String> audioUrl,
  Value<String?> audioMimeType,
  Value<int?> audioSizeBytes,
  Value<int?> durationMs,
  Value<DateTime?> pubDate,
  Value<String?> imageUrl,
  Value<String?> chaptersUrl,
  Value<String?> theme,
  Value<int?> episodeNumber,
  Value<int?> season,
  Value<EpisodeStatus> status,
  Value<int> positionMs,
  Value<DateTime?> playedAt,
  Value<DateTime> addedAt,
});

final class $$EpisodesTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PodcastsTable _podcastIdTable(_$AppDatabase db) =>
      db.podcasts.createAlias('episodes__podcast_id__podcasts__id');

  $$PodcastsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<int>('podcast_id')!;

    final manager = $$PodcastsTableTableManager(
      $_db,
      $_db.podcasts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DownloadsTable, List<Download>>
  _downloadsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloads,
    aliasName: 'episodes__id__downloads__episode_id',
  );

  $$DownloadsTableProcessedTableManager get downloadsRefs {
    final manager = $$DownloadsTableTableManager(
      $_db,
      $_db.downloads,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_downloadsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlaylistItemsTable, List<PlaylistItem>>
  _playlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistItems,
    aliasName: 'episodes__id__playlist_items__episode_id',
  );

  $$PlaylistItemsTableProcessedTableManager get playlistItemsRefs {
    final manager = $$PlaylistItemsTableTableManager(
      $_db,
      $_db.playlistItems,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.chapters,
    aliasName: 'episodes__id__chapters__episode_id',
  );

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager(
      $_db,
      $_db.chapters,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'episodes__id__bookmarks__episode_id',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EpisodeNotesTable, List<EpisodeNote>>
  _episodeNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.episodeNotes,
    aliasName: 'episodes__id__episode_notes__episode_id',
  );

  $$EpisodeNotesTableProcessedTableManager get episodeNotesRefs {
    final manager = $$EpisodeNotesTableTableManager(
      $_db,
      $_db.episodeNotes,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodeNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioMimeType => $composableBuilder(
    column: $table.audioMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioSizeBytes => $composableBuilder(
    column: $table.audioSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chaptersUrl => $composableBuilder(
    column: $table.chaptersUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EpisodeStatus, EpisodeStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PodcastsTableFilterComposer get podcastId {
    final $$PodcastsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcasts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastsTableFilterComposer(
            $db: $db,
            $table: $db.podcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> downloadsRefs(
    Expression<bool> Function($$DownloadsTableFilterComposer f) f,
  ) {
    final $$DownloadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloads,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableFilterComposer(
            $db: $db,
            $table: $db.downloads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playlistItemsRefs(
    Expression<bool> Function($$PlaylistItemsTableFilterComposer f) f,
  ) {
    final $$PlaylistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistItems,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistItemsTableFilterComposer(
            $db: $db,
            $table: $db.playlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> chaptersRefs(
    Expression<bool> Function($$ChaptersTableFilterComposer f) f,
  ) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableFilterComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> episodeNotesRefs(
    Expression<bool> Function($$EpisodeNotesTableFilterComposer f) f,
  ) {
    final $$EpisodeNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodeNotes,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeNotesTableFilterComposer(
            $db: $db,
            $table: $db.episodeNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioMimeType => $composableBuilder(
    column: $table.audioMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioSizeBytes => $composableBuilder(
    column: $table.audioSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pubDate => $composableBuilder(
    column: $table.pubDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chaptersUrl => $composableBuilder(
    column: $table.chaptersUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PodcastsTableOrderingComposer get podcastId {
    final $$PodcastsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcasts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastsTableOrderingComposer(
            $db: $db,
            $table: $db.podcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get audioMimeType => $composableBuilder(
    column: $table.audioMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioSizeBytes => $composableBuilder(
    column: $table.audioSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pubDate =>
      $composableBuilder(column: $table.pubDate, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get chaptersUrl => $composableBuilder(
    column: $table.chaptersUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EpisodeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$PodcastsTableAnnotationComposer get podcastId {
    final $$PodcastsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcasts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastsTableAnnotationComposer(
            $db: $db,
            $table: $db.podcasts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> downloadsRefs<T extends Object>(
    Expression<T> Function($$DownloadsTableAnnotationComposer a) f,
  ) {
    final $$DownloadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloads,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> playlistItemsRefs<T extends Object>(
    Expression<T> Function($$PlaylistItemsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistItems,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> chaptersRefs<T extends Object>(
    Expression<T> Function($$ChaptersTableAnnotationComposer a) f,
  ) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.chapters,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChaptersTableAnnotationComposer(
            $db: $db,
            $table: $db.chapters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> episodeNotesRefs<T extends Object>(
    Expression<T> Function($$EpisodeNotesTableAnnotationComposer a) f,
  ) {
    final $$EpisodeNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodeNotes,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodeNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({
            bool podcastId,
            bool downloadsRefs,
            bool playlistItemsRefs,
            bool chaptersRefs,
            bool bookmarksRefs,
            bool episodeNotesRefs,
          })
        > {
  $$EpisodesTableTableManager(_$AppDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> podcastId = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<String?> audioMimeType = const Value.absent(),
                Value<int?> audioSizeBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> pubDate = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> chaptersUrl = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<int?> episodeNumber = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<EpisodeStatus> status = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<DateTime?> playedAt = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                podcastId: podcastId,
                guid: guid,
                title: title,
                description: description,
                audioUrl: audioUrl,
                audioMimeType: audioMimeType,
                audioSizeBytes: audioSizeBytes,
                durationMs: durationMs,
                pubDate: pubDate,
                imageUrl: imageUrl,
                chaptersUrl: chaptersUrl,
                theme: theme,
                episodeNumber: episodeNumber,
                season: season,
                status: status,
                positionMs: positionMs,
                playedAt: playedAt,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int podcastId,
                required String guid,
                required String title,
                Value<String?> description = const Value.absent(),
                required String audioUrl,
                Value<String?> audioMimeType = const Value.absent(),
                Value<int?> audioSizeBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime?> pubDate = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> chaptersUrl = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<int?> episodeNumber = const Value.absent(),
                Value<int?> season = const Value.absent(),
                Value<EpisodeStatus> status = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<DateTime?> playedAt = const Value.absent(),
                required DateTime addedAt,
              }) => EpisodesCompanion.insert(
                id: id,
                podcastId: podcastId,
                guid: guid,
                title: title,
                description: description,
                audioUrl: audioUrl,
                audioMimeType: audioMimeType,
                audioSizeBytes: audioSizeBytes,
                durationMs: durationMs,
                pubDate: pubDate,
                imageUrl: imageUrl,
                chaptersUrl: chaptersUrl,
                theme: theme,
                episodeNumber: episodeNumber,
                season: season,
                status: status,
                positionMs: positionMs,
                playedAt: playedAt,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodesTable, Episode>(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                podcastId = false,
                downloadsRefs = false,
                playlistItemsRefs = false,
                chaptersRefs = false,
                bookmarksRefs = false,
                episodeNotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (downloadsRefs) db.downloads,
                    if (playlistItemsRefs) db.playlistItems,
                    if (chaptersRefs) db.chapters,
                    if (bookmarksRefs) db.bookmarks,
                    if (episodeNotesRefs) db.episodeNotes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (podcastId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.podcastId,
                            referencedTable: $$EpisodesTableReferences
                                ._podcastIdTable(db),
                            referencedColumn: $$EpisodesTableReferences
                                ._podcastIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (downloadsRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          Download
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._downloadsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (playlistItemsRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          PlaylistItem
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._playlistItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).playlistItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (chaptersRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          Chapter
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._chaptersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).chaptersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          Bookmark
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (episodeNotesRefs)
                        await $_getPrefetchedData<
                          Episode,
                          $EpisodesTable,
                          EpisodeNote
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodesTableReferences
                              ._episodeNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodesTableReferences(
                                db,
                                table,
                                p0,
                              ).episodeNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({
        bool podcastId,
        bool downloadsRefs,
        bool playlistItemsRefs,
        bool chaptersRefs,
        bool bookmarksRefs,
        bool episodeNotesRefs,
      })
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableCreateCompanionBuilder = DownloadsCompanion Function({
  Value<int> episodeId,
  required String relativePath,
  required DownloadState state,
  Value<int?> sizeBytes,
  Value<bool> wifiOnly,
  Value<int> failedAttempts,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
});
typedef $$DownloadsTableUpdateCompanionBuilder = DownloadsCompanion Function({
  Value<int> episodeId,
  Value<String> relativePath,
  Value<DownloadState> state,
  Value<int?> sizeBytes,
  Value<bool> wifiOnly,
  Value<int> failedAttempts,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
});

final class $$DownloadsTableReferences
    extends BaseReferences<_$AppDatabase, $DownloadsTable, Download> {
  $$DownloadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias('downloads__episode_id__episodes__id');

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DownloadState, DownloadState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DownloadState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get wifiOnly =>
      $composableBuilder(column: $table.wifiOnly, builder: (column) => column);

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (Download, $$DownloadsTableReferences),
          Download,
          PrefetchHooks Function({bool episodeId})
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<DownloadState> state = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DownloadsCompanion(
                episodeId: episodeId,
                relativePath: relativePath,
                state: state,
                sizeBytes: sizeBytes,
                wifiOnly: wifiOnly,
                failedAttempts: failedAttempts,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required String relativePath,
                required DownloadState state,
                Value<int?> sizeBytes = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DownloadsCompanion.insert(
                episodeId: episodeId,
                relativePath: relativePath,
                state: state,
                sizeBytes: sizeBytes,
                wifiOnly: wifiOnly,
                failedAttempts: failedAttempts,
                createdAt: createdAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DownloadsTable, Download>(table),
                  $$DownloadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.episodeId,
                        referencedTable: $$DownloadsTableReferences
                            ._episodeIdTable(db),
                        referencedColumn: $$DownloadsTableReferences
                            ._episodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (Download, $$DownloadsTableReferences),
      Download,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<int?> lastEpisodeId,
  Value<PlaylistColor?> color,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<int?> lastEpisodeId,
  Value<PlaylistColor?> color,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, Playlist> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistItemsTable, List<PlaylistItem>>
  _playlistItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playlistItems,
    aliasName: 'playlists__id__playlist_items__playlist_id',
  );

  $$PlaylistItemsTableProcessedTableManager get playlistItemsRefs {
    final manager = $$PlaylistItemsTableTableManager(
      $_db,
      $_db.playlistItems,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastEpisodeId => $composableBuilder(
    column: $table.lastEpisodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlaylistColor?, PlaylistColor, String>
  get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> playlistItemsRefs(
    Expression<bool> Function($$PlaylistItemsTableFilterComposer f) f,
  ) {
    final $$PlaylistItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistItems,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistItemsTableFilterComposer(
            $db: $db,
            $table: $db.playlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastEpisodeId => $composableBuilder(
    column: $table.lastEpisodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get lastEpisodeId => $composableBuilder(
    column: $table.lastEpisodeId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PlaylistColor?, String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> playlistItemsRefs<T extends Object>(
    Expression<T> Function($$PlaylistItemsTableAnnotationComposer a) f,
  ) {
    final $$PlaylistItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistItems,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistsTable,
          Playlist,
          $$PlaylistsTableFilterComposer,
          $$PlaylistsTableOrderingComposer,
          $$PlaylistsTableAnnotationComposer,
          $$PlaylistsTableCreateCompanionBuilder,
          $$PlaylistsTableUpdateCompanionBuilder,
          (Playlist, $$PlaylistsTableReferences),
          Playlist,
          PrefetchHooks Function({bool playlistItemsRefs})
        > {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> lastEpisodeId = const Value.absent(),
                Value<PlaylistColor?> color = const Value.absent(),
              }) => PlaylistsCompanion(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastEpisodeId: lastEpisodeId,
                color: color,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int?> lastEpisodeId = const Value.absent(),
                Value<PlaylistColor?> color = const Value.absent(),
              }) => PlaylistsCompanion.insert(
                id: id,
                name: name,
                sortOrder: sortOrder,
                createdAt: createdAt,
                lastEpisodeId: lastEpisodeId,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistsTable, Playlist>(table),
                  $$PlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistItemsRefs) db.playlistItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistItemsRefs)
                    await $_getPrefetchedData<
                      Playlist,
                      $PlaylistsTable,
                      PlaylistItem
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistsTableReferences
                          ._playlistItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).playlistItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistsTable,
      Playlist,
      $$PlaylistsTableFilterComposer,
      $$PlaylistsTableOrderingComposer,
      $$PlaylistsTableAnnotationComposer,
      $$PlaylistsTableCreateCompanionBuilder,
      $$PlaylistsTableUpdateCompanionBuilder,
      (Playlist, $$PlaylistsTableReferences),
      Playlist,
      PrefetchHooks Function({bool playlistItemsRefs})
    >;
typedef $$PlaylistItemsTableCreateCompanionBuilder =
    PlaylistItemsCompanion Function({
      required int playlistId,
      required int episodeId,
      required int position,
      required DateTime addedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });
typedef $$PlaylistItemsTableUpdateCompanionBuilder =
    PlaylistItemsCompanion Function({
      Value<int> playlistId,
      Value<int> episodeId,
      Value<int> position,
      Value<DateTime> addedAt,
      Value<DateTime?> finishedAt,
      Value<int> rowid,
    });

final class $$PlaylistItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItem> {
  $$PlaylistItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_items__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager(
      $_db,
      $_db.playlists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias('playlist_items__episode_id__episodes__id');

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.playlists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaylistItemsTable,
          PlaylistItem,
          $$PlaylistItemsTableFilterComposer,
          $$PlaylistItemsTableOrderingComposer,
          $$PlaylistItemsTableAnnotationComposer,
          $$PlaylistItemsTableCreateCompanionBuilder,
          $$PlaylistItemsTableUpdateCompanionBuilder,
          (PlaylistItem, $$PlaylistItemsTableReferences),
          PlaylistItem,
          PrefetchHooks Function({bool playlistId, bool episodeId})
        > {
  $$PlaylistItemsTableTableManager(_$AppDatabase db, $PlaylistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> playlistId = const Value.absent(),
                Value<int> episodeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistItemsCompanion(
                playlistId: playlistId,
                episodeId: episodeId,
                position: position,
                addedAt: addedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int playlistId,
                required int episodeId,
                required int position,
                required DateTime addedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaylistItemsCompanion.insert(
                playlistId: playlistId,
                episodeId: episodeId,
                position: position,
                addedAt: addedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaylistItemsTable, PlaylistItem>(table),
                  $$PlaylistItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playlistId,
                        referencedTable: $$PlaylistItemsTableReferences
                            ._playlistIdTable(db),
                        referencedColumn: $$PlaylistItemsTableReferences
                            ._playlistIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (episodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.episodeId,
                        referencedTable: $$PlaylistItemsTableReferences
                            ._episodeIdTable(db),
                        referencedColumn: $$PlaylistItemsTableReferences
                            ._episodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaylistItemsTable,
      PlaylistItem,
      $$PlaylistItemsTableFilterComposer,
      $$PlaylistItemsTableOrderingComposer,
      $$PlaylistItemsTableAnnotationComposer,
      $$PlaylistItemsTableCreateCompanionBuilder,
      $$PlaylistItemsTableUpdateCompanionBuilder,
      (PlaylistItem, $$PlaylistItemsTableReferences),
      PlaylistItem,
      PrefetchHooks Function({bool playlistId, bool episodeId})
    >;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  required int episodeId,
  required int startMs,
  required String title,
  Value<String?> url,
  Value<String?> imageUrl,
  Value<int> rowid,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<int> episodeId,
  Value<int> startMs,
  Value<String> title,
  Value<String?> url,
  Value<String?> imageUrl,
  Value<int> rowid,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias('chapters__episode_id__episodes__id');

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, $$ChaptersTableReferences),
          Chapter,
          PrefetchHooks Function({bool episodeId})
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion(
                episodeId: episodeId,
                startMs: startMs,
                title: title,
                url: url,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int episodeId,
                required int startMs,
                required String title,
                Value<String?> url = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion.insert(
                episodeId: episodeId,
                startMs: startMs,
                title: title,
                url: url,
                imageUrl: imageUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChaptersTable, Chapter>(table),
                  $$ChaptersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.episodeId,
                        referencedTable: $$ChaptersTableReferences
                            ._episodeIdTable(db),
                        referencedColumn: $$ChaptersTableReferences
                            ._episodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, $$ChaptersTableReferences),
      Chapter,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  required int episodeId,
  required int positionMs,
  Value<String?> note,
  required DateTime createdAt,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<int> id,
  Value<int> episodeId,
  Value<int> positionMs,
  Value<String?> note,
  Value<DateTime> createdAt,
});

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias('bookmarks__episode_id__episodes__id');

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool episodeId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> episodeId = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                episodeId: episodeId,
                positionMs: positionMs,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int episodeId,
                required int positionMs,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => BookmarksCompanion.insert(
                id: id,
                episodeId: episodeId,
                positionMs: positionMs,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookmarksTable, Bookmark>(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.episodeId,
                        referencedTable: $$BookmarksTableReferences
                            ._episodeIdTable(db),
                        referencedColumn: $$BookmarksTableReferences
                            ._episodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$EpisodeNotesTableCreateCompanionBuilder =
    EpisodeNotesCompanion Function({
      Value<int> episodeId,
      required String notes,
    });
typedef $$EpisodeNotesTableUpdateCompanionBuilder =
    EpisodeNotesCompanion Function({Value<int> episodeId, Value<String> notes});

final class $$EpisodeNotesTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodeNotesTable, EpisodeNote> {
  $$EpisodeNotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodesTable _episodeIdTable(_$AppDatabase db) =>
      db.episodes.createAlias('episode_notes__episode_id__episodes__id');

  $$EpisodesTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodeNotesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodeNotesTable> {
  $$EpisodeNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodesTableFilterComposer get episodeId {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodeNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodeNotesTable> {
  $$EpisodeNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodesTableOrderingComposer get episodeId {
    final $$EpisodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableOrderingComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodeNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodeNotesTable> {
  $$EpisodeNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$EpisodesTableAnnotationComposer get episodeId {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodeNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodeNotesTable,
          EpisodeNote,
          $$EpisodeNotesTableFilterComposer,
          $$EpisodeNotesTableOrderingComposer,
          $$EpisodeNotesTableAnnotationComposer,
          $$EpisodeNotesTableCreateCompanionBuilder,
          $$EpisodeNotesTableUpdateCompanionBuilder,
          (EpisodeNote, $$EpisodeNotesTableReferences),
          EpisodeNote,
          PrefetchHooks Function({bool episodeId})
        > {
  $$EpisodeNotesTableTableManager(_$AppDatabase db, $EpisodeNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodeNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodeNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodeNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> episodeId = const Value.absent(),
            Value<String> notes = const Value.absent(),
          }) => EpisodeNotesCompanion(episodeId: episodeId, notes: notes),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required String notes,
              }) => EpisodeNotesCompanion.insert(
                episodeId: episodeId,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodeNotesTable, EpisodeNote>(table),
                  $$EpisodeNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (episodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.episodeId,
                        referencedTable: $$EpisodeNotesTableReferences
                            ._episodeIdTable(db),
                        referencedColumn: $$EpisodeNotesTableReferences
                            ._episodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodeNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodeNotesTable,
      EpisodeNote,
      $$EpisodeNotesTableFilterComposer,
      $$EpisodeNotesTableOrderingComposer,
      $$EpisodeNotesTableAnnotationComposer,
      $$EpisodeNotesTableCreateCompanionBuilder,
      $$EpisodeNotesTableUpdateCompanionBuilder,
      (EpisodeNote, $$EpisodeNotesTableReferences),
      EpisodeNote,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$PlayHistoryTableCreateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      required String feedUrl,
      required String guid,
      required String episodeTitle,
      required String podcastTitle,
      Value<String?> imageUrl,
      Value<int?> durationMs,
      required DateTime playedAt,
    });
typedef $$PlayHistoryTableUpdateCompanionBuilder =
    PlayHistoryCompanion Function({
      Value<int> id,
      Value<String> feedUrl,
      Value<String> guid,
      Value<String> episodeTitle,
      Value<String> podcastTitle,
      Value<String?> imageUrl,
      Value<int?> durationMs,
      Value<DateTime> playedAt,
    });

class $$PlayHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get podcastTitle => $composableBuilder(
    column: $table.podcastTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get podcastTitle => $composableBuilder(
    column: $table.podcastTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayHistoryTable> {
  $$PlayHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get episodeTitle => $composableBuilder(
    column: $table.episodeTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get podcastTitle => $composableBuilder(
    column: $table.podcastTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);
}

class $$PlayHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayHistoryTable,
          HistoryEntry,
          $$PlayHistoryTableFilterComposer,
          $$PlayHistoryTableOrderingComposer,
          $$PlayHistoryTableAnnotationComposer,
          $$PlayHistoryTableCreateCompanionBuilder,
          $$PlayHistoryTableUpdateCompanionBuilder,
          (
            HistoryEntry,
            BaseReferences<_$AppDatabase, $PlayHistoryTable, HistoryEntry>,
          ),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$PlayHistoryTableTableManager(_$AppDatabase db, $PlayHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String> episodeTitle = const Value.absent(),
                Value<String> podcastTitle = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
              }) => PlayHistoryCompanion(
                id: id,
                feedUrl: feedUrl,
                guid: guid,
                episodeTitle: episodeTitle,
                podcastTitle: podcastTitle,
                imageUrl: imageUrl,
                durationMs: durationMs,
                playedAt: playedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String feedUrl,
                required String guid,
                required String episodeTitle,
                required String podcastTitle,
                Value<String?> imageUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required DateTime playedAt,
              }) => PlayHistoryCompanion.insert(
                id: id,
                feedUrl: feedUrl,
                guid: guid,
                episodeTitle: episodeTitle,
                podcastTitle: podcastTitle,
                imageUrl: imageUrl,
                durationMs: durationMs,
                playedAt: playedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayHistoryTable, HistoryEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayHistoryTable,
                    HistoryEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayHistoryTable,
      HistoryEntry,
      $$PlayHistoryTableFilterComposer,
      $$PlayHistoryTableOrderingComposer,
      $$PlayHistoryTableAnnotationComposer,
      $$PlayHistoryTableCreateCompanionBuilder,
      $$PlayHistoryTableUpdateCompanionBuilder,
      (
        HistoryEntry,
        BaseReferences<_$AppDatabase, $PlayHistoryTable, HistoryEntry>,
      ),
      HistoryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PodcastsTableTableManager get podcasts =>
      $$PodcastsTableTableManager(_db, _db.podcasts);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistItemsTableTableManager get playlistItems =>
      $$PlaylistItemsTableTableManager(_db, _db.playlistItems);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$EpisodeNotesTableTableManager get episodeNotes =>
      $$EpisodeNotesTableTableManager(_db, _db.episodeNotes);
  $$PlayHistoryTableTableManager get playHistory =>
      $$PlayHistoryTableTableManager(_db, _db.playHistory);
}
