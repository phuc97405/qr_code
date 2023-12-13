import 'package:intl/intl.dart';

extension DateCompare on DateTime {
  bool isSameDate(DateTime one, DateTime two) {
    return one.year == two.year && one.month == two.month && one.day == two.day;
  }
}

extension TimerStampConvert on DateTime {
  String toDateFormat(String timestamp) {
    return DateFormat('HH:mm dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }
}
