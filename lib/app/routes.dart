/// Route paths, kept in one place to avoid typos.
abstract final class Routes {
  static const home = '/';
  static const subscriptions = '/abos';
  static const playlists = '/playlists';
  static const downloads = '/downloads';
  static const settings = '/einstellungen';
  static const player = '/player';
  static const bookmarks = '$settings/lesezeichen';
  static const history = '$settings/verlauf';
  static const info = '$settings/info';

  static const search = '$subscriptions/suche';

  static String playlist(int id) => '$playlists/$id';

  /// The playlist, scrolled to [episodeId] (from the player). [request]
  /// makes a repeated jump to the same place a new location.
  static String playlistAt(int id, int episodeId, int request) =>
      '$playlists/$id?folge=$episodeId&r=$request';

  static String podcast(int id) => '$subscriptions/podcast/$id';
}
