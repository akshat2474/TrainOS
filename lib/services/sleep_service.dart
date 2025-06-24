import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/sleep_data.dart';

class SleepService {
  static final SleepService _instance = SleepService._internal();
  factory SleepService() => _instance;
  SleepService._internal();

  final StreamController<SleepData> _sleepController = StreamController.broadcast();
  Stream<SleepData> get sleepStream => _sleepController.stream;

  Future<void> logSleep({
    required DateTime bedTime,
    required DateTime wakeTime,
    required int sleepQuality,
  }) async {
    final totalHours = wakeTime.difference(bedTime).inMinutes / 60.0;
    final dateKey = DateFormat('yyyy-MM-dd').format(bedTime);
    
    final sleepData = SleepData(
      bedTime: bedTime,
      wakeTime: wakeTime,
      totalHours: totalHours,
      sleepQuality: sleepQuality,
      date: dateKey,
    );

    await _saveSleepData(sleepData);
    _sleepController.add(sleepData);
  }

  Future<void> _saveSleepData(SleepData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_data_${data.date}', json.encode(data.toJson()));
  }

  Future<SleepData?> getSleepForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString('sleep_data_$date');
    
    if (dataJson != null) {
      return SleepData.fromJson(json.decode(dataJson));
    }
    return null;
  }

  Future<List<SleepData>> getWeeklySleepData() async {
    final List<SleepData> weeklyData = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final sleepData = await getSleepForDate(dateKey);
      
      if (sleepData != null) {
        weeklyData.add(sleepData);
      }
    }
    
    return weeklyData;
  }

  Future<SleepData?> getLastNightSleep() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateKey = DateFormat('yyyy-MM-dd').format(yesterday);
    return await getSleepForDate(dateKey);
  }
}
