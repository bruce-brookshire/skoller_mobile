part of 'constants.dart';

class DateUtilities {
  static String getFutureRelativeString(DateTime date) {
    if (date == null) {
      return 'No due date';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (today.isAfter(date)) {
      return 'In the past';
    }

    final comp = date.toLocal();

    final diff = comp.toUtc().difference(today.toUtc());
    final int days = diff.inDays;

    if (days < 7) {
      switch (days) {
        case 0:
          return 'Today';
        case 1:
          return 'Tomorrow';
        default:
          switch (comp.weekday) {
            case 1:
              return 'Monday';
            case 2:
              return 'Tuesday';
            case 3:
              return 'Wednesday';
            case 4:
              return 'Thursday';
            case 5:
              return 'Friday';
            case 6:
              return 'Saturday';
            case 7:
              return 'Sunday';
            default:
              return 'Soon';
          }
      }
    } else {
      return '${days} days';
    }
  }
}

class NumberUtilities {
  static String formatWeightAsPercent(double weight) {
    return NumberFormat.percentPattern().format(weight);
  }

  static String formatGradeAsPercent(double grade) {
    return '${grade.round()}%';
  }
}
