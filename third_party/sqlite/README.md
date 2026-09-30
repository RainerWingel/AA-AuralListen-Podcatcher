# SQLite (public domain)

Official SQLite amalgamation, compiled into the app by the build hook of
`package:sqlite3` (`hooks: user_defines` in `pubspec.yaml`). Nothing is
downloaded during the build – required for F-Droid.

- Version: 3.53.4, from https://sqlite.org/2026/sqlite-amalgamation-3530400.zip
- SHA3-256 of the zip (as published on sqlite.org/download.html):
  `628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e`
- Only `sqlite3.c` and `sqlite3.h` are kept, unchanged.

Update: download the new amalgamation zip, compare its SHA3-256 with the value
on the download page, replace both files and update this README.
