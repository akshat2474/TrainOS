import 'dart:async';
import 'dart:convert';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/fitness_data.dart';
import '../models/user_profile.dart';

class FitnessService {
  static final FitnessService _instance = FitnessService._internal();
  factory FitnessService() => _instance;
  FitnessService._internal();

  Stream<StepCount>? _stepCountStream;
  final StreamController<FitnessData> _fitnessController = StreamController.broadcast();
  
  int _currentSteps = 0;
  UserProfile? _userProfile;

  Stream<FitnessData> get fitnessStream => _fitnessController.stream;

  Future<void> initialize() async {
    await _requestPermissions();
    await _loadUserProfile();
    await _initializePedometer();
  }

  Future<void> _requestPermissions() async {
    await Permission.activityRecognition.request();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(json.decode(profileJson));
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
  }

  Future<void> _initializePedometer() async {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream!.listen(_onStepCount);
    } catch (e) {
      print('Pedometer error: $e');
    }
  }

  void _onStepCount(StepCount event) {
    _currentSteps = event.steps;
    final fitnessData = _calculateFitnessData();
    _fitnessController.add(fitnessData);
    _saveDailyData(fitnessData);
  }

  FitnessData _calculateFitnessData() {
    final calories = _calculateCalories(_currentSteps);
    final distance = _calculateDistance(_currentSteps);
    
    return FitnessData(
      steps: _currentSteps,
      caloriesBurned: calories,
      distance: distance,
      date: DateTime.now(),
    );
  }

  double _calculateCalories(int steps) {
    if (_userProfile == null) return steps * 0.04;
    final weight = _userProfile!.weight;
    final caloriesPerStep = (weight * 0.57) / 1000;
    return steps * caloriesPerStep;
  }

  double _calculateDistance(int steps) {
    if (_userProfile == null) return steps * 0.762;
    final stepLength = _userProfile!.height * 0.43 / 100;
    return steps * stepLength;
  }

  Future<void> _saveDailyData(FitnessData data) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('fitness_data_$today', json.encode(data.toJson()));
  }

  Future<List<FitnessData>> getWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<FitnessData> weeklyData = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];
      final dataJson = prefs.getString('fitness_data_$dateKey');
      
      if (dataJson != null) {
        weeklyData.add(FitnessData.fromJson(json.decode(dataJson)));
      } else {
        weeklyData.add(FitnessData(
          steps: 0,
          caloriesBurned: 0,
          distance: 0,
          date: date,
        ));
      }
    }
    
    return weeklyData;
  }

  UserProfile? get userProfile => _userProfile;
  int get currentSteps => _currentSteps;
}

