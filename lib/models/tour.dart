class Tour {
  final int tourId;
  final String tourName;
  final String tourCompany;

  Tour(this.tourId, this.tourName, this.tourCompany);

  Tour.fromJson(Map<String, dynamic> json)
      : tourId = json['tourId'],
        tourName = json['tourName'],
        tourCompany = json['tourCompany'];
}
