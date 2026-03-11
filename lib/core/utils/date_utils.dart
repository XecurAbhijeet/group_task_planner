/// Returns a date key string (yyyy-MM-dd) for the given [date].
String dateKey(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Today's date key.
String get todayKey => dateKey(DateTime.now());

/// Whether [date] is yesterday relative to [reference] (default now).
bool isYesterday(DateTime date, [DateTime? reference]) {
  final ref = reference ?? DateTime.now();
  return date.year == ref.year &&
      date.month == ref.month &&
      date.day == ref.day - 1;
}
