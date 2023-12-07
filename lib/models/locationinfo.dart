class LocationInfo {
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;

  LocationInfo(this.userId, this.userName, this.latitude, this.longitude);

  LocationInfo.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        userName = json['userName'],
        latitude = json['latitude'],
        longitude = json['longitude'];
}

class LocationCheck {
  final String userId;
  final String userName;
  final double latitude;
  final double longitude;
  final bool isNear;

  LocationCheck(
      this.userId, this.userName, this.latitude, this.longitude, this.isNear);

  LocationCheck.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        userName = json['userName'],
        latitude = json['latitude'],
        longitude = json['longitude'],
        isNear = json['isNear'];
}
