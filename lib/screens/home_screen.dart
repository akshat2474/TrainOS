import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/fitness_service.dart';
import '../models/fitness_data.dart';
import 'profile_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FitnessService _fitnessService = FitnessService();
  FitnessData? _currentData;
  List<FitnessData> _weeklyData = [];
  
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    _listenToFitnessUpdates();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration:const Duration(milliseconds: 2000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration:const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );

    _cardController.forward();
  }

  void _loadData() async {
    final weeklyData = await _fitnessService.getWeeklyData();
    setState(() {
      _weeklyData = weeklyData;
    });
  }

  void _listenToFitnessUpdates() {
    _fitnessService.fitnessStream.listen((data) {
      setState(() {
        _currentData = data;
      });
      _updateProgress();
    });
  }

  void _updateProgress() {
    if (_currentData != null && _fitnessService.userProfile != null) {
      final progress = _currentData!.steps / _fitnessService.userProfile!.dailyStepGoal;
      _progressController.animateTo(progress.clamp(0.0, 1.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fitnessService.userProfile == null) {
      return ProfileSetupScreen();
    }

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
          child: CustomScrollView(
            physics:const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding:const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _cardAnimation,
                    child: Column(
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 24),
                        _buildStepCounter(),
                        const SizedBox(height: 24),
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildWeeklyChart(),
                        const SizedBox(height: 24),
                        _buildInsightsCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace:const FlexibleSpaceBar(
        title: Text(
          'TrainOS',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
      ),
      actions: [
        IconButton(
          icon:const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => ProfileSetupScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin:const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final progress = _currentData != null && _fitnessService.userProfile != null
        ? _currentData!.steps / _fitnessService.userProfile!.dailyStepGoal
        : 0.0;

    String statusMessage = _getStatusMessage(progress);
    Color statusColor = _getStatusColor(progress);

    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              statusMessage,
              style:const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(double progress) {
    if (progress >= 1.0) return "Goal achieved! Excellent work today.";
    if (progress >= 0.8) return "Almost there! You're doing great.";
    if (progress >= 0.5) return "Good progress! Keep it up.";
    if (progress >= 0.2) return "Getting started! Every step counts.";
    return "Ready to start your fitness journey?";
  }

  Color _getStatusColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF00FF88);
    if (progress >= 0.8) return const Color(0xFF00D4FF);
    if (progress >= 0.5) return const Color(0xFF5B73FF);
    if (progress >= 0.2) return const Color(0xFFFFB800);
    return const Color(0xFF8E8E93);
  }

  Widget _buildStepCounter() {
    final steps = _currentData?.steps ?? 0;
    final goal = _fitnessService.userProfile?.dailyStepGoal ?? 10000;
    final progress = steps / goal;

    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Steps Today',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? const Color(0xFF00FF88) : const Color(0xFF00D4FF),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$steps',
                        style:const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'of $goal',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Calories',
            '${_currentData?.caloriesBurned.toStringAsFixed(0) ?? '0'}',
            Icons.local_fire_department_outlined,
            const Color(0xFFFF6B6B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Distance',
            '${((_currentData?.distance ?? 0) / 1000).toStringAsFixed(2)} km',
            Icons.straighten,
            const Color(0xFF4ECDC4),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (_fitnessService.userProfile?.dailyStepGoal ?? 10000).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(
                          days[value.toInt()],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _weeklyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.steps.toDouble(),
                        gradient: LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF5B73FF)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          _buildInsightItem("Take regular breaks", "Stand up every hour"),
          _buildInsightItem("Stay hydrated", "Drink water throughout the day"),
          _buildInsightItem("Track progress", "Monitor your daily achievements"),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00D4FF),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }
}



