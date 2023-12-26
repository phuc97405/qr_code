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

extension FromDateTo on DateTime {
  String aboutHour(String from, String to) {
    print('from$from');
    print('to$to');

    if (from.isNotEmpty) {
      return '${(DateTime.fromMillisecondsSinceEpoch(int.parse(from)).difference(DateTime.fromMillisecondsSinceEpoch(int.parse(to))).inMinutes / 60).toStringAsFixed(1)}H';
    } else {
      return '${(DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(int.parse(to))).inMinutes / 60).toStringAsFixed(1)}H';
    }
  }
}
