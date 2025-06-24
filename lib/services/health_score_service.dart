import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/health_score.dart';
import '../services/fitness_service.dart';
import '../services/sleep_service.dart';

class HealthScoreService {
  static final HealthScoreService _instance = HealthScoreService._internal();
  factory HealthScoreService() => _instance;
  HealthScoreService._internal();

  Future<HealthScore> calculateTodaysHealthScore() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Get fitness data
    final steps = FitnessService().currentSteps;
    final stepGoal = FitnessService().userProfile?.dailyStepGoal ?? 10000;
    
    // Get sleep data
    final sleepData = await SleepService().getLastNightSleep();
    
    // Calculate scores
    final stepsScore = _calculateStepsScore(steps, stepGoal);
    final sleepScore = _calculateSleepScore(sleepData?.totalHours, sleepData?.sleepQuality);
    final activityScore = _calculateActivityScore(steps);
    final consistencyScore = await _calculateConsistencyScore();
    
    final overallScore = ((stepsScore + sleepScore + activityScore + consistencyScore) / 4).round();
    final recommendation = _generateRecommendation(overallScore, stepsScore, sleepScore);
    
    final healthScore = HealthScore(
      overallScore: overallScore,
      stepsScore: stepsScore,
      sleepScore: sleepScore,
      activityScore: activityScore,
      consistencyScore: consistencyScore,
      date: today,
      recommendation: recommendation,
    );
    
    await _saveHealthScore(healthScore);
    return healthScore;
  }

  int _calculateStepsScore(int steps, int goal) {
    return ((steps / goal) * 100).clamp(0, 100).round();
  }

  int _calculateSleepScore(double? hours, int? quality) {
    if (hours == null || quality == null) return 0;
    
    int timeScore = 0;
    if (hours >= 7 && hours <= 9) {
      timeScore = 100;
    } else if (hours >= 6 && hours <= 10) {
      timeScore = 80;
    } else {
      timeScore = 50;
    }
    
    return ((timeScore + quality) / 2).round();
  }

  int _calculateActivityScore(int steps) {
    if (steps >= 15000) return 100;
    if (steps >= 10000) return 85;
    if (steps >= 7500) return 70;
    if (steps >= 5000) return 55;
    return 30;
  }

  Future<int> _calculateConsistencyScore() async {
    final weeklyData = await FitnessService().getWeeklyData();
    final goal = FitnessService().userProfile?.dailyStepGoal ?? 10000;
    
    int daysMetGoal = 0;
    for (final data in weeklyData) {
      if (data.steps >= goal) daysMetGoal++;
    }
    
    return ((daysMetGoal / 7) * 100).round();
  }

  String _generateRecommendation(int overall, int steps, int sleep) {
    if (overall >= 90) return "Excellent! You're maintaining outstanding health habits.";
    if (overall >= 80) return "Great job! Keep up the good work.";
    if (overall >= 70) return "Good progress! Focus on consistency.";
    if (sleep < 60) return "Prioritize better sleep for improved health.";
    if (steps < 60) return "Try to increase your daily activity.";
    return "Start with small, achievable daily goals.";
  }

  Future<void> _saveHealthScore(HealthScore score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('health_score_${score.date}', json.encode(score.toJson()));
  }

  Future<List<HealthScore>> getWeeklyHealthScores() async {
    final prefs = await SharedPreferences.getInstance();
    final List<HealthScore> weeklyScores = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final scoreJson = prefs.getString('health_score_$dateKey');
      
      if (scoreJson != null) {
        weeklyScores.add(HealthScore.fromJson(json.decode(scoreJson)));
      }
    }
    
    return weeklyScores;
  }
}
