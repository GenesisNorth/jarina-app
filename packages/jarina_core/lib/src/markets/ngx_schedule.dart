/// NGX equities trading hours: Monday–Friday, 10:00–14:30 West Africa Time
/// (UTC+1, no daylight saving).
///
/// Public holidays are announced by NGX; in production the server sends the
/// calendar and this is only the fallback for the UI hint.
abstract final class NgxSchedule {
  static const _wat = Duration(hours: 1);
  static const int _openMinutes = 10 * 60;
  static const int _closeMinutes = 14 * 60 + 30;

  static DateTime _toWat(DateTime t) => t.toUtc().add(_wat);

  static bool isOpen(DateTime now) {
    final w = _toWat(now);
    if (w.weekday > DateTime.friday) return false;
    final m = w.hour * 60 + w.minute;
    return m >= _openMinutes && m < _closeMinutes;
  }

  /// The next session start (UTC). If the market is open, today's open.
  static DateTime nextOpen(DateTime now) {
    final w = _toWat(now);
    var day = DateTime.utc(w.year, w.month, w.day);
    final m = w.hour * 60 + w.minute;
    if (m >= _openMinutes || w.weekday > DateTime.friday) day = day.add(const Duration(days: 1));
    while (day.weekday > DateTime.friday) {
      day = day.add(const Duration(days: 1));
    }
    // 10:00 WAT == 09:00 UTC.
    return day.add(const Duration(minutes: _openMinutes)).subtract(_wat);
  }
}
