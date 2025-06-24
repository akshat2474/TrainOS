import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final StreamController<Achievement> _achievementController = StreamController.broadcast();
  Stream<Achievement> get achievementStream => _achievementController.stream;

  List<Achievement> _allAchievements = [];
  List<Achievement> _unlockedAchievements = [];

  Future<void> initialize() async {
    _setupDefaultAchievements();
    await _loadUnlockedAchievements();
  }

  void _setupDefaultAchievements() {
    _allAchievements = [
      Achievement(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Take your first 100 steps',
        points: 10,
      ),
      Achievement(
        id: 'walker',
        title: 'Walker',
        description: 'Walk 5,000 steps in a day',
        points: 50,
      ),
      Achievement(
        id: 'marathon_walker',
        title: 'Marathon Walker',
        description: 'Walk 20,000 steps in a day',
        points: 200,
      ),
      Achievement(
        id: 'good_sleeper',
        title: 'Good Sleeper',
        description: 'Get 8+ hours of sleep',
        points: 75,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Wake up before 6 AM',
        points: 50,
      ),
      Achievement(
        id: 'consistent',
        title: 'Consistent',
        description: 'Meet step goal 3 days in a row',
        points: 100,
      ),
      Achievement(
        id: 'dedicated',
        title: 'Dedicated',
        description: 'Meet step goal 7 days in a row',
        points: 250,
      ),
    ];
  }

  Future<void> checkAchievements({
    int? steps,
    double? sleepHours,
    DateTime? wakeTime,
    int? streak,
  }) async {
    for (final achievement in _allAchievements) {
      if (!_isUnlocked(achievement.id) && _shouldUnlock(achievement, steps, sleepHours, wakeTime, streak)) {
        await _unlockAchievement(achievement);
      }
    }
  }

  bool _shouldUnlock(Achievement achievement, int? steps, double? sleepHours, DateTime? wakeTime, int? streak) {
    switch (achievement.id) {
      case 'first_steps':
        return steps != null && steps >= 100;
      case 'walker':
        return steps != null && steps >= 5000;
      case 'marathon_walker':
        return steps != null && steps >= 20000;
      case 'good_sleeper':
        return sleepHours != null && sleepHours >= 8.0;
      case 'early_bird':
        return wakeTime != null && wakeTime.hour < 6;
      case 'consistent':
        return streak != null && streak >= 3;
      case 'dedicated':
        return streak != null && streak >= 7;
      default:
        return false;
    }
  }

  bool _isUnlocked(String achievementId) {
    return _unlockedAchievements.any((a) => a.id == achievementId);
  }

  Future<void> _unlockAchievement(Achievement achievement) async {
    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedDate: DateTime.now(),
    );

    _unlockedAchievements.add(unlockedAchievement);
    await _saveUnlockedAchievements();
    _achievementController.add(unlockedAchievement);
  }

  Future<void> _loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = prefs.getString('unlocked_achievements');
    
    if (achievementsJson != null) {
      final List<dynamic> achievementsList = json.decode(achievementsJson);
      _unlockedAchievements = achievementsList
          .map((json) => Achievement.fromJson(json))
          .toList();
    }
  }

  Future<void> _saveUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsJson = json.encode(
      _unlockedAchievements.map((a) => a.toJson()).toList()
    );
    await prefs.setString('unlocked_achievements', achievementsJson);
  }

  List<Achievement> get allAchievements => _allAchievements;
  List<Achievement> get unlockedAchievements => _unlockedAchievements;
  int get totalPoints => _unlockedAchievements.fold(0, (sum, a) => sum + a.points);
}
