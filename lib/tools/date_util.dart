class DateUtil {
  static String formatter = "yyyy-MM-dd HH:mm:ss";

  static DateTime parseIntToTime(int milliseconds) {
    if ((milliseconds ?? 0) < 1) return null;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static String formatSeconds(int milliseconds, {String format}) {
    return formatTime(parseIntToTime(milliseconds), format: format);
  }

  static String formatTime(DateTime dateTime, {String format}) {
    if (dateTime == null) return '';
    format = format ?? formatter;
    if (format.contains('yy')) {
      String year = dateTime.year.toString();
      if (format.contains('yyyy')) {
        format = format.replaceAll('yyyy', year);
      } else {
        format = format.replaceAll(
            'yy', year.substring(year.length - 2, year.length));
      }
    }

    format = _comFormat(dateTime.month, format, 'M', 'MM');
    format = _comFormat(dateTime.day, format, 'd', 'dd');
    format = _comFormat(dateTime.hour, format, 'H', 'HH');
    format = _comFormat(dateTime.minute, format, 'm', 'mm');
    format = _comFormat(dateTime.second, format, 's', 'ss');
    format = _comFormat(dateTime.millisecond, format, 'S', 'SSS');

    return format;
  }

  static String _comFormat(
      int value, String format, String single, String full) {
    if (format.contains(single)) {
      if (format.contains(full)) {
        format =
            format.replaceAll(full, value < 10 ? '0$value' : value.toString());
      } else {
        format = format.replaceAll(single, value.toString());
      }
    }
    return format;
  }

  static String formatSecondsForRead(int milliseconds) {
    return formatTimeForRead(parseIntToTime(milliseconds));
  }

  static String computedTime(int startTime, int entTime) {
    return '';
    // TODO 计算时长算法待优化, 且还没计算节假日
    // int count = 0;
    // if ([4, 8].contains(_leaveType)) {
    // } else if ([5, 6, 7, 9].contains(_leaveType)) {
    //   int begin = _beginTime.millisecondsSinceEpoch;
    //   int end = _endTime.millisecondsSinceEpoch;
    //   DateTime tmp;
    //   while (begin <= end) {
    //     tmp = DateTime.fromMillisecondsSinceEpoch(begin);
    //     if (tmp.weekday >= 1 && tmp.weekday <= 5) {
    //       count++;
    //     }
    //     begin += 24 * 3600 * 1000;
    //   }
    //   _durationController.text = '$count';
    // } else {}
  }

  static String formatTimeForRead(DateTime dateTime) {
    if (dateTime == null) return '';
    DateTime now = DateTime.now();

    if (dateTime.day != now.day ||
        dateTime.month != now.month ||
        dateTime.year != now.year) {
      String month;
      String day;
      if (dateTime.month < 10) {
        month = "0${dateTime.month}";
      } else {
        month = dateTime.month.toString();
      }

      if (dateTime.day < 10) {
        day = "0${dateTime.day}";
      } else {
        day = dateTime.day.toString();
      }
      return "$month.$day";
    } else {
      String hour;
      String minute;
      if (dateTime.hour < 10) {
        hour = "0${dateTime.hour}";
      } else {
        hour = dateTime.hour.toString();
      }

      if (dateTime.minute < 10) {
        minute = "0${dateTime.minute}";
      } else {
        minute = dateTime.minute.toString();
      }
      return '$hour:$minute';
    }
  }

  static int getAge(int milliseconds) {
    if (milliseconds < 1) return null;
    DateTime time = parseIntToTime(milliseconds);
    if (time == null) return null;

    DateTime now = DateTime.now();
    int age = now.year -
        time.year -
        ((now.month < time.month ||
                (now.month == time.month && now.day < time.day))
            ? 1
            : 0);
    return age < 1 ? 0 : age;
  }
}
