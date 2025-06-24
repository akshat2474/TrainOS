import 'dart:async';
import 'dart:convert';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';
import '../models/fitness_data.dart';
import '../models/user_profile.dart';

class FitnessService {
  static final FitnessService _instance = FitnessService._internal();
  factory FitnessService() => _instance;
  FitnessService._internal();

  Stream<StepCount>? _stepCountStream;
  final StreamController<FitnessData> _fitnessController = StreamController.broadcast();
  
  int _currentSteps = 0;
  int _baseStepCount = 0;
  String _currentDate = '';
  UserProfile? _userProfile;

  Stream<FitnessData> get fitnessStream => _fitnessController.stream;

  Future<void> initialize() async {
    await _requestPermissions();
    await _loadUserProfile();
    await _initializeStepCounting();
    await _setupBackgroundWork();
  }

  Future<void> _requestPermissions() async {
    await Permission.activityRecognition.request();
  }

  Future<void> _setupBackgroundWork() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      "step-counter",
      "stepCounterTask",
      frequency:const Duration(minutes: 15),
    );
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

  Future<void> _initializeStepCounting() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _currentDate = today;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load today's steps or reset if new day
    final savedDate = prefs.getString('step_date') ?? '';
    final savedSteps = prefs.getInt('daily_steps') ?? 0;
    final savedBaseCount = prefs.getInt('base_step_count') ?? 0;
    
    if (savedDate == today) {
      _currentSteps = savedSteps;
      _baseStepCount = savedBaseCount;
    } else {
      // New day - reset steps
      _currentSteps = 0;
      _baseStepCount = 0;
      await prefs.setString('step_date', today);
      await prefs.setInt('daily_steps', 0);
      await prefs.setInt('base_step_count', 0);
    }

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream!.listen(_onStepCount);
    } catch (e) {
      print('Pedometer error: $e');
    }
  }

  void _onStepCount(StepCount event) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Check if day changed
    if (today != _currentDate) {
      await _resetDailySteps();
      _currentDate = today;
    }

    // Calculate daily steps
    if (_baseStepCount == 0) {
      _baseStepCount = event.steps;
    }
    
    _currentSteps = event.steps - _baseStepCount;
    if (_currentSteps < 0) _currentSteps = 0;

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_steps', _currentSteps);
    await prefs.setInt('base_step_count', _baseStepCount);
    await prefs.setString('step_date', today);

    final fitnessData = _calculateFitnessData();
    _fitnessController.add(fitnessData);
    await _saveDailyData(fitnessData);
  }

  Future<void> _resetDailySteps() async {
    _currentSteps = 0;
    _baseStepCount = 0;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_steps', 0);
    await prefs.setInt('base_step_count', 0);
    await prefs.setString('step_date', DateFormat('yyyy-MM-dd').format(DateTime.now()));
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
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setString('fitness_data_$today', json.encode(data.toJson()));
  }

  Future<List<FitnessData>> getWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<FitnessData> weeklyData = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
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

  // Load current steps on app start
  Future<void> loadCurrentSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('step_date') ?? '';
    
    if (savedDate == today) {
      _currentSteps = prefs.getInt('daily_steps') ?? 0;
      final fitnessData = _calculateFitnessData();
      _fitnessController.add(fitnessData);
    }
  }

  UserProfile? get userProfile => _userProfile;
  int get currentSteps => _currentSteps;
}

// Background task callback
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This runs in background to maintain step counting
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = prefs.getString('step_date') ?? '';
    
    // Reset steps if new day
    if (savedDate != today) {
      await prefs.setInt('daily_steps', 0);
      await prefs.setInt('base_step_count', 0);
      await prefs.setString('step_date', today);
    }
    
    return Future.value(true);
  });
}
