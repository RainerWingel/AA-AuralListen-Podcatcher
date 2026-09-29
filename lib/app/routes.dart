/// Route paths, kept in one place to avoid typos.
abstract final class Routes {
  static const home = '/';
  static const subscriptions = '/abos';
  static const playlists = '/playlists';
  static const downloads = '/downloads';
  static const settings = '/einstellungen';
  static const player = '/player';
  static const bookmarks = '$settings/lesezeichen';
  static const info = '$settings/info';

  static const search = '$subscriptions/suche';

  static String playlist(int id) => '$playlists/$id';

  static String podcast(int id) => '$subscriptions/podcast/$id';
}
