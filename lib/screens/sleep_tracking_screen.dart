import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/sleep_service.dart';
import '../models/sleep_data.dart';

class SleepTrackingScreen extends StatefulWidget {
  @override
  _SleepTrackingScreenState createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  final SleepService _sleepService = SleepService();
  SleepData? _lastNightSleep;
  List<SleepData> _weeklySleep = [];
  
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  int _sleepQuality = 75;

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  void _loadSleepData() async {
    final lastNight = await _sleepService.getLastNightSleep();
    final weekly = await _sleepService.getWeeklySleepData();
    
    setState(() {
      _lastNightSleep = lastNight;
      _weeklySleep = weekly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding:const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildLastNightCard(),
                const SizedBox(height: 24),
                _buildSleepLogCard(),
                const SizedBox(height: 24),
                _buildWeeklySleepChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon:const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Sleep Tracking',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLastNightCard() {
    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last Night\'s Sleep',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (_lastNightSleep != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSleepStat(
                  'Duration',
                  '${_lastNightSleep!.totalHours.toStringAsFixed(1)}h',
                  Icons.bedtime,
                ),
                _buildSleepStat(
                  'Quality',
                  '${_lastNightSleep!.sleepQuality}%',
                  Icons.star,
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Text(
                'No sleep data recorded',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSleepStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color:const Color(0xFF00D4FF), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style:const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSleepLogCard() {
    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Sleep',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector(
                  'Bedtime',
                  _bedTime,
                  (time) => setState(() => _bedTime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeSelector(
                  'Wake Time',
                  _wakeTime,
                  (time) => setState(() => _wakeTime = time),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sleep Quality: $_sleepQuality%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          Slider(
            value: _sleepQuality.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            activeColor:const Color(0xFF00D4FF),
            inactiveColor: Colors.white.withOpacity(0.2),
            onChanged: (value) {
              setState(() {
                _sleepQuality = value.round();
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _bedTime != null && _wakeTime != null ? _logSleep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:const Text(
                'Log Sleep',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay? time, Function(TimeOfDay) onTimeSelected) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      child: Container(
        padding:const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time?.format(context) ?? 'Select time',
              style:const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // In sleep_tracking_screen.dart - _buildWeeklySleepChart()
Widget _buildWeeklySleepChart() {
  return Container(
    width: double.infinity,
    padding:const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Sleep Pattern',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: _weeklySleep.isEmpty
            ? Center(
                child: Text(
                  'No sleep data available',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              )
            : LineChart(
                LineChartData(
                  gridData:const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          int index = value.toInt();
                          if (index >= 0 && index < days.length) {
                            return Padding(
                              padding:const EdgeInsets.only(top: 8),
                              child: Text(
                                days[index],
                                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSleepSpots(),
                      isCurved: true,
                      color:const Color(0xFF00D4FF),
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color:const Color(0xFF00D4FF).withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 12,
                ),
              ),
        ),
      ],
    ),
  );
}

List<FlSpot> _generateSleepSpots() {
  List<FlSpot> spots = [];
  
  for (int i = 0; i < 7; i++) {
    double sleepHours = 0;
    if (i < _weeklySleep.length) {
      sleepHours = _weeklySleep[i].totalHours;
    }
    spots.add(FlSpot(i.toDouble(), sleepHours));
  }
  
  return spots;
}


  void _logSleep() async {
    if (_bedTime == null || _wakeTime == null) return;

    final now = DateTime.now();
    final bedDateTime = DateTime(now.year, now.month, now.day - 1, _bedTime!.hour, _bedTime!.minute);
    final wakeDateTime = DateTime(now.year, now.month, now.day, _wakeTime!.hour, _wakeTime!.minute);

    await _sleepService.logSleep(
      bedTime: bedDateTime,
      wakeTime: wakeDateTime,
      sleepQuality: _sleepQuality,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep logged successfully!'),
        backgroundColor: Color(0xFF00D4FF),
      ),
    );

    setState(() {
      _bedTime = null;
      _wakeTime = null;
      _sleepQuality = 75;
    });

    _loadSleepData();
  }
}
