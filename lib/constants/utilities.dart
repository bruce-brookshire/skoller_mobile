part of 'constants.dart';

enum AppState { loading, auth, main }

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

  static String getPastRelativeString(DateTime date, {bool ago = true}) {
    final now_ms = DateTime.now().millisecondsSinceEpoch;
    final date_ms = date.millisecondsSinceEpoch;

    final diff = ((now_ms - date_ms) / 1000).truncate();

    if (diff < 5) {
      return 'Now';
    } else if (diff < 60) {
      return '${diff} sec${ago ? ' ago' : ''}';
    } else if (diff < 3600) {
      return '${(diff / 60).truncate()} min${ago ? ' ago' : ''}';
    } else if (diff < 86400) {
      final hrs = (diff / 3600).truncate();
      return '${hrs} ${hrs == 1 ? 'hr' : 'hrs'}${ago ? ' ago' : ''}';
    } else if (diff < 604800) {
      final days = (diff / 86400).truncate();
      return '${days} ${days == 1 ? 'day' : 'days'}${ago ? ' ago' : ''}';
    } else {
      return DateFormat('M/d/yy').format(date);
    }
  }
}

class NumberUtilities {
  static String formatWeightAsPercent(double weight) =>
      '${((weight * 1000).round()) / 10}%';

  static String formatGradeAsPercent(double grade) => '${grade.round()}%';
}

/// Format incoming numeric text to fit the format of (###) ###-#### ##...
class USNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength < oldValue.text.length) {
      return newValue;
    }

    if (newTextLength == 1) {
      newText.write('(');
      selectionIndex++;
    }
    if (newTextLength == 4) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 4) + ') ');
      selectionIndex += 2;
    }
    if (newTextLength == 9) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 9) + '-');
      selectionIndex++;
    }

    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
