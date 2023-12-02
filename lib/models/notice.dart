class Notice {
  final int noticeId;
  final String noticeDate;
  final double noticeLatitude;
  final double noticeLongitude;
  final String noticePlace;

  Notice.fromJson(Map<String, dynamic> json)
      : noticeId = json['noticeId'],
        noticeDate = json['noticeDate'],
        noticeLatitude = json['noticeLatitude'],
        noticeLongitude = json['noticeLongitude'],
        noticePlace = '임시';
}
