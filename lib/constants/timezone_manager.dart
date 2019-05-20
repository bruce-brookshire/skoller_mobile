import 'package:time_machine/time_machine.dart';
import 'package:flutter/services.dart';

class TimeZoneManager {
  static DateTimeZoneProvider _tzdb;

  static bool _fetchingTZDB = false;

  static Future verifyTzDbActive() async {
    if (_tzdb == null && !_fetchingTZDB) {
      _fetchingTZDB = true;
      await TimeMachine.initialize({"rootBundle": rootBundle});
      _tzdb = await DateTimeZoneProviders.tzdb;
      _fetchingTZDB = false;
    }
  }

  static Future<DateTime> convertUtcOffsetFromLocalToSchool(
    DateTime date,
    String schoolTZString,
  ) async {
    await verifyTzDbActive();

    var schoolTZ = await _tzdb[schoolTZString ?? 'America/Chicago'];
    var currentTZ = DateTimeZone.local;

    var dueInstant = Instant.dateTime(date);

    int schoolOffset = schoolTZ.getUtcOffset(dueInstant).inSeconds;
    int currentOffset = currentTZ.getUtcOffset(dueInstant).inSeconds;

    return schoolOffset == currentOffset
        ? dueInstant.toDateTimeUtc()
        : dueInstant
            .add(Time(seconds: currentOffset - schoolOffset))
            .toDateTimeUtc();
  }

  /**
   * This is really only useful for when +1...etc GMT users exist
   */
  static Future<DateTime> createLocalRelativeAssignmentDueDate(
    DateTime date,
    String schoolTZString,
  ) async {
    await verifyTzDbActive();

    var schoolTZ = await _tzdb[schoolTZString ?? 'America/Chicago'];
    var currentTZ = DateTimeZone.local;

    var dueInstant = Instant.dateTime(date);

    int schoolOffset = schoolTZ.getUtcOffset(dueInstant).inSeconds;
    int currentOffset = currentTZ.getUtcOffset(dueInstant).inSeconds;

    return schoolOffset == currentOffset
        ? dueInstant.toDateTimeLocal()
        : dueInstant
            .subtract(Time(seconds: currentOffset - schoolOffset))
            .toDateTimeLocal();
  }
}
