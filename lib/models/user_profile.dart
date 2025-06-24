class UserProfile {
  final double weight; 
  final double height; 
  final int age;
  final String gender;
  final int dailyStepGoal;

  UserProfile({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    this.dailyStepGoal = 10000,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'height': height,
    'age': age,
    'gender': gender,
    'dailyStepGoal': dailyStepGoal,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    weight: json['weight'],
    height: json['height'],
    age: json['age'],
    gender: json['gender'],
    dailyStepGoal: json['dailyStepGoal'] ?? 10000,
  );
}