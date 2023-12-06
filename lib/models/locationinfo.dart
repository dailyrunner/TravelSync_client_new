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
