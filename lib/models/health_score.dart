class HealthScore {
  final int overallScore;
  final int stepsScore;
  final int sleepScore;
  final int activityScore;
  final int consistencyScore;
  final String date;
  final String recommendation;

  HealthScore({
    required this.overallScore,
    required this.stepsScore,
    required this.sleepScore,
    required this.activityScore,
    required this.consistencyScore,
    required this.date,
    required this.recommendation,
  });

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'stepsScore': stepsScore,
    'sleepScore': sleepScore,
    'activityScore': activityScore,
    'consistencyScore': consistencyScore,
    'date': date,
    'recommendation': recommendation,
  };

  factory HealthScore.fromJson(Map<String, dynamic> json) => HealthScore(
    overallScore: json['overallScore'],
    stepsScore: json['stepsScore'],
    sleepScore: json['sleepScore'],
    activityScore: json['activityScore'],
    consistencyScore: json['consistencyScore'],
    date: json['date'],
    recommendation: json['recommendation'],
  );
}
