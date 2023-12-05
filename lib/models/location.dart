class Location {
  final String latitude;
  final String longitude;
  Location(this.latitude, this.longitude);

  Location.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];
}
