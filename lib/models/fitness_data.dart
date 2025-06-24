class FitnessData {
  final int steps;
  final double caloriesBurned;
  final double distance;
  final DateTime date;

  FitnessData({
    required this.steps,
    required this.caloriesBurned,
    required this.distance,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'steps': steps,
    'caloriesBurned': caloriesBurned,
    'distance': distance,
    'date': date.toIso8601String(),
  };

  factory FitnessData.fromJson(Map<String, dynamic> json) => FitnessData(
    steps: json['steps'],
    caloriesBurned: json['caloriesBurned'],
    distance: json['distance'],
    date: DateTime.parse(json['date']),
  );
}



