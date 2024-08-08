// /utilities/short_date.dart

String shortWeekday(DateTime date) {
  switch (date.weekday) {
    case DateTime.monday:
      return 'Mon';
    case DateTime.tuesday:
      return 'Tue';
    case DateTime.wednesday:
      return 'Wed';
    case DateTime.thursday:
      return 'Thu';
    case DateTime.friday:
      return 'Fri';
    case DateTime.saturday:
      return 'Sat';
    case DateTime.sunday:
      return 'Sun';
    default:
      return '';
  }
}

String shortMonth(DateTime date) {
  switch (date.month) {
    case DateTime.january:
      return 'Jan';
    case DateTime.february:
      return 'Feb';
    case DateTime.march:
      return 'Mar';
    case DateTime.april:
      return 'Apr';
    case DateTime.may:
      return 'May';
    case DateTime.june:
      return 'Jun';
    case DateTime.july:
      return 'Jul';
    case DateTime.august:
      return 'Aug';
    case DateTime.september:
      return 'Sep';
    case DateTime.october:
      return 'Oct';
    case DateTime.november:
      return 'Nov';
    case DateTime.december:
      return 'Dec';
    default:
      return '';
  }
}

String formatShortDateRange(DateTime start, DateTime end) {
  return '${shortWeekday(start)}, ${start.day} ${shortMonth(start)} \'${start.year % 100} - ${shortWeekday(end)}, ${end.day} ${shortMonth(end)} \'${end.year % 100}';
}