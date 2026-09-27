import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// "10. Juni 2025", or without year for the current year ("10. Juni").
String formatEpisodeDate(DateTime date, {required DateTime now}) {
  final local = date.toLocal();
  return local.year == now.year
      ? DateFormat.MMMMd('de').format(local)
      : DateFormat.yMMMMd('de').format(local);
}

/// "1 Std. 5 Min." or "42 Min." (at least 1 minute).
String formatEpisodeDuration(AppLocalizations l10n, Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return l10n.durationHoursMinutes(hours, minutes);
  }
  return l10n.durationMinutes(minutes < 1 ? 1 : minutes);
}

/// Player clock: "4:05" or "1:02:03".
String formatClock(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds'
      : '$minutes:$seconds';
}

/// "350 MB", "1,2 GB" (German decimal comma).
String formatBytes(int bytes) {
  const mb = 1024 * 1024;
  const gb = 1024 * mb;
  if (bytes >= gb) {
    return '${NumberFormat('#,##0.0', 'de').format(bytes / gb)} GB';
  }
  return '${NumberFormat('#,##0', 'de').format((bytes / mb).ceil())} MB';
}
