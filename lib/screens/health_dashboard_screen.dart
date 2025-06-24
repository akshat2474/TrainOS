import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/health_score_service.dart';
import '../models/health_score.dart';

class HealthDashboardScreen extends StatefulWidget {
  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthScoreService _healthScoreService = HealthScoreService();
  HealthScore? _todaysScore;
  List<HealthScore> _weeklyScores = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  void _loadHealthData() async {
    final todaysScore = await _healthScoreService.calculateTodaysHealthScore();
    final weeklyScores = await _healthScoreService.getWeeklyHealthScores();
    
    setState(() {
      _todaysScore = todaysScore;
      _weeklyScores = weeklyScores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:const BoxDecoration(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildOverallScoreCard(),
                const SizedBox(height: 24),
                _buildScoreBreakdown(),
                const SizedBox(height: 24),
                _buildWeeklyTrendChart(),
                const SizedBox(height: 24),
                _buildRecommendationCard(),
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Health Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

    Widget _buildOverallScoreCard() {
    if (_todaysScore == null) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            'Overall Health Score',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: _todaysScore!.overallScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(_todaysScore!.overallScore),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${_todaysScore!.overallScore}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _getScoreLabel(_todaysScore!.overallScore),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getScoreColor(_todaysScore!.overallScore),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown() {
    if (_todaysScore == null) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score Breakdown',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildScoreItem('Steps', _todaysScore!.stepsScore, Icons.directions_walk),
          _buildScoreItem('Sleep', _todaysScore!.sleepScore, Icons.bedtime),
          _buildScoreItem('Activity', _todaysScore!.activityScore, Icons.fitness_center),
          _buildScoreItem('Consistency', _todaysScore!.consistencyScore, Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color:const Color(0xFF00D4FF), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      '$score%',
                      style: TextStyle(
                        color: _getScoreColor(score),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // In health_dashboard_screen.dart - _buildWeeklyTrendChart()
Widget _buildWeeklyTrendChart() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Trend',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: _weeklyScores.isEmpty
            ? Center(
                child: Text(
                  'No health data available',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              )
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
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
                      spots: _generateHealthSpots(),
                      isCurved: true,
                      color:const Color(0xFF00D4FF),
                      barWidth: 3,
                      dotData:const FlDotData(show: true),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
        ),
      ],
    ),
  );
}

List<FlSpot> _generateHealthSpots() {
  List<FlSpot> spots = [];
  
  for (int i = 0; i < 7; i++) {
    double score = 0;
    if (i < _weeklyScores.length) {
      score = _weeklyScores[i].overallScore.toDouble();
    }
    spots.add(FlSpot(i.toDouble(), score));
  }
  
  return spots;
}


  Widget _buildRecommendationCard() {
    if (_todaysScore == null) return Container();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFF00D4FF), size: 24),
              SizedBox(width: 12),
              Text(
                'Recommendation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _todaysScore!.recommendation,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF00FF88);
    if (score >= 80) return const Color(0xFF00D4FF);
    if (score >= 70) return const Color(0xFF5B73FF);
    if (score >= 60) return const Color(0xFFFFB800);
    return const Color(0xFFFF6B6B);
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Great';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Fair';
    return 'Needs Work';
  }
}
