class Notice {
  final int noticeId;
  final String noticeDate;
  final String noticeTitle;
  final double noticeLatitude;
  final double noticeLongitude;

  Notice.fromJson(Map<String, dynamic> json)
      : noticeId = json['noticeId'],
        noticeDate = json['noticeDate'],
        noticeTitle = json['noticeTitle'],
        noticeLatitude = json['noticeLatitude'],
        noticeLongitude = json['noticeLongitude'];

  int parseMonth() {
    DateTime temp = DateTime.parse(noticeDate);
    return temp.month;
  }

  int parseDay() {
    DateTime temp = DateTime.parse(noticeDate);
    return temp.day;
  }

  int parseHour() {
    DateTime temp = DateTime.parse(noticeDate);
    return temp.hour;
  }

  int parseMinute() {
    DateTime temp = DateTime.parse(noticeDate);
    return temp.minute;
  }
}
