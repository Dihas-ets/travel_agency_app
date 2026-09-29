class AccessSession {
  final bool isActive;
  final DateTime? endsAt;

  const AccessSession({required this.isActive, required this.endsAt});

  factory AccessSession.fromJson(Map<String, dynamic> json, {DateTime? now}) {
    final access = _mapOf(json['access']);
    final assignment = _mapOf(access['affectation']);
    final rawDate =
        access['prolongation_date'] ??
        access['date_fin'] ??
        assignment['date_fin'];
    final rawTime =
        access['prolongation_heure'] ??
        access['heure_fin'] ??
        assignment['heure_fin'];
    final endsAt = _parseMoment(rawDate, rawTime);
    final currentTime = now ?? DateTime.now();
    return AccessSession(
      isActive:
          json['session_active'] == true &&
          (endsAt == null || endsAt.isAfter(currentTime)),
      endsAt: endsAt,
    );
  }

  int remainingSecondsAt(DateTime now) {
    if (!isActive || endsAt == null) return 0;
    final seconds = endsAt!.difference(now).inSeconds;
    return seconds > 0 ? seconds : 0;
  }

  static Map<String, dynamic> _mapOf(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  static DateTime? _parseMoment(Object? rawDate, Object? rawTime) {
    final dateValue = rawDate?.toString().trim();
    final timeValue = rawTime?.toString().trim();
    if (dateValue == null ||
        dateValue.isEmpty ||
        timeValue == null ||
        timeValue.isEmpty) {
      return null;
    }

    final datePart = dateValue.length >= 10
        ? dateValue.substring(0, 10)
        : dateValue;
    DateTime? date = DateTime.tryParse(datePart);
    if (date == null) {
      final parts = datePart.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          date = DateTime(year, month, day);
        }
      }
    }

    final timeMatch = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(timeValue);
    if (date == null || timeMatch == null) return null;
    final hour = int.tryParse(timeMatch.group(1)!);
    final minute = int.tryParse(timeMatch.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
