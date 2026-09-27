import 'db/app_database.dart';

/// Key/value settings stored in the `settings` table (keys: `settings_keys.dart`).
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<String?> get(String key) async => (await (_db.select(
    _db.settings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watch(String key) =>
      (_db.select(_db.settings)..where((s) => s.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  Future<void> set(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));

  Future<void> remove(String key) =>
      (_db.delete(_db.settings)..where((s) => s.key.equals(key))).go();

  Future<int?> getInt(String key) async => int.tryParse(await get(key) ?? '');

  Future<double?> getDouble(String key) async =>
      double.tryParse(await get(key) ?? '');
}
