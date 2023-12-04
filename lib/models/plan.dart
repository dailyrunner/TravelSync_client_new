class Plan {
  final int planId;
  final int tourId;
  final int day;
  final String planTime;
  final String planTitle;
  final String planContent;

  Plan(this.planId, this.planTime, this.planTitle, this.planContent,
      this.tourId, this.day);

  Plan.fromJson(Map<String, dynamic> json)
      : planId = json['planId'],
        tourId = json['tourId'],
        day = json['day'],
        planTime = json['planTime'],
        planTitle = json['planTitle'],
        planContent = json['planContent'];
}
