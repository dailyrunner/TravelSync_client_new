class Plan {
  final int planId;
  final int tourId;
  final int day;
  final String time;
  final String planTitle;
  final String planContent;

  Plan(
    this.planId,
    this.tourId,
    this.day,
    this.time,
    this.planTitle,
    this.planContent,
  );

  Plan.fromJson(Map<String, dynamic> json)
      : planId = json['planId'],
        tourId = json['tourId'],
        day = json['day'],
        time = json['time'],
        planTitle = json['planTitle'],
        planContent = json['planContent'];
}
