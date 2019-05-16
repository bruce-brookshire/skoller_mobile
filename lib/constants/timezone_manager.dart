import 'package:time_machine/time_machine.dart';
import 'package:flutter/services.dart';

class TimeZoneManager {
  static DateTimeZoneProvider _tzdb;

  static Future _verifyTzDbActive() async {
    if (_tzdb == null) {
      await TimeMachine.initialize({"rootBundle": rootBundle});
      _tzdb = await DateTimeZoneProviders.tzdb;
    }
  }

  static Future<DateTime> convertUtcOffsetFromLocalToSchool(
    DateTime date,
    String schoolTZString,
  ) async {
    await _verifyTzDbActive();

    var schoolTZ = await _tzdb[schoolTZString ?? 'America/Chicago'];
    var currentTZ = DateTimeZone.local;

    var dueInstant = Instant.dateTime(date);

    int schoolOffset = schoolTZ.getUtcOffset(dueInstant).inSeconds;
    int currentOffset = currentTZ.getUtcOffset(dueInstant).inSeconds;

    return dueInstant
        .subtract(Time(seconds: schoolOffset))
        .add(Time(seconds: currentOffset))
        .toDateTimeUtc();
  }

  /**
   * This is really only useful for when +1...etc GMT users exist
   */
  static Future<DateTime> createLocalRelativeAssignmentDueDate(
    DateTime date,
    String schoolTZString,
  ) async {
    await _verifyTzDbActive();

    var schoolTZ = await _tzdb[schoolTZString ?? 'America/Chicago'];
    var currentTZ = DateTimeZone.local;

    var dueInstant = Instant.dateTime(date);

    int schoolOffset = schoolTZ.getUtcOffset(dueInstant).inSeconds;
    int currentOffset = currentTZ.getUtcOffset(dueInstant).inSeconds;

    return dueInstant
        .add(Time(seconds: schoolOffset))
        .subtract(Time(seconds: currentOffset))
        .toDateTimeLocal();
  }
}
