class SleepData {
  final DateTime bedTime;
  final DateTime wakeTime;
  final double totalHours;
  final int sleepQuality;
  final String date;

  SleepData({
    required this.bedTime,
    required this.wakeTime,
    required this.totalHours,
    required this.sleepQuality,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'bedTime': bedTime.toIso8601String(),
    'wakeTime': wakeTime.toIso8601String(),
    'totalHours': totalHours,
    'sleepQuality': sleepQuality,
    'date': date,
  };

  factory SleepData.fromJson(Map<String, dynamic> json) => SleepData(
    bedTime: DateTime.parse(json['bedTime']),
    wakeTime: DateTime.parse(json['wakeTime']),
    totalHours: json['totalHours'].toDouble(),
    sleepQuality: json['sleepQuality'],
    date: json['date'],
  );
}