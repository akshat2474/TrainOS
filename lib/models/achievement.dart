class Achievement {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isUnlocked;
  final DateTime? unlockedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'points': points,
    'isUnlocked': isUnlocked,
    'unlockedDate': unlockedDate?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    points: json['points'],
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedDate: json['unlockedDate'] != null 
        ? DateTime.parse(json['unlockedDate']) 
        : null,
  );

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedDate}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      points: points,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }
}