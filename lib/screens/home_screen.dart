import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/fitness_service.dart';
import '../services/achievement_service.dart';
import '../services/health_score_service.dart';
import '../models/fitness_data.dart';
import '../models/health_score.dart';
import 'profile_setup_screen.dart';
import 'sleep_tracking_screen.dart';
import 'health_dashboard_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final FitnessService _fitnessService = FitnessService();
  final AchievementService _achievementService = AchievementService();
  final HealthScoreService _healthScoreService = HealthScoreService();
  
  FitnessData? _currentData;
  List<FitnessData> _weeklyData = [];
  HealthScore? _todaysHealthScore;
  
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeServices();
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

  void _initializeServices() async {
    await _achievementService.initialize();
    await _fitnessService.loadCurrentSteps();
  }

  void _loadData() async {
    final weeklyData = await _fitnessService.getWeeklyData();
    final healthScore = await _healthScoreService.calculateTodaysHealthScore();
    
    setState(() {
      _weeklyData = weeklyData;
      _todaysHealthScore = healthScore;
    });
  }

  void _listenToFitnessUpdates() {
    _fitnessService.fitnessStream.listen((data) {
      setState(() {
        _currentData = data;
      });
      _updateProgress();
      _checkAchievements(data);
    });
  }

  void _updateProgress() {
    if (_currentData != null && _fitnessService.userProfile != null) {
      final progress = _currentData!.steps / _fitnessService.userProfile!.dailyStepGoal;
      _progressController.animateTo(progress.clamp(0.0, 1.0));
    }
  }

  void _checkAchievements(FitnessData data) {
    _achievementService.checkAchievements(steps: data.steps);
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
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildHealthScoreCard(),
                        const SizedBox(height: 24),
                        _buildStepCounter(),
                        const SizedBox(height: 24),
                        _buildStatsCards(),
                        const SizedBox(height: 24),
                        _buildWeeklyChart(),
                        const SizedBox(height: 24),
                        _buildRecentAchievements(),
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
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Sleep',
            Icons.bedtime_outlined,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => SleepTrackingScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Health',
            Icons.favorite_outline,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => HealthDashboardScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            'Awards',
            Icons.emoji_events_outlined,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color:const Color(0xFF00D4FF), size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style:const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    if (_todaysHealthScore == null) return Container();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HealthDashboardScreen())),
      child: Container(
        width: double.infinity,
        padding:const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getScoreColor(_todaysHealthScore!.overallScore).withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  '${_todaysHealthScore!.overallScore}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: _getScoreColor(_todaysHealthScore!.overallScore),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScoreLabel(_todaysHealthScore!.overallScore),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCounter() {
    final steps = _currentData?.steps ?? _fitnessService.currentSteps;
    final goal = _fitnessService.userProfile?.dailyStepGoal ?? 10000;

    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            'Steps Today',
            style: TextStyle(
              fontSize: 18,
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
                      valueColor:const AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
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
      padding:const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style:const TextStyle(
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
            'Weekly Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
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
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _weeklyData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.steps.toDouble(),
                        gradient: const LinearGradient(
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

  Widget _buildRecentAchievements() {
    final recentAchievements = _achievementService.unlockedAchievements
        .take(3)
        .toList();

    if (recentAchievements.isEmpty) {
      return Container();
    }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementsScreen())),
                child:const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF00D4FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentAchievements.map((achievement) => _buildAchievementItem(achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementItem( achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:const Color(0xFF00D4FF).withOpacity(0.2),
            ),
            child:const Icon(
              Icons.emoji_events,
              color: Color(0xFF00D4FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${achievement.points} points',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
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

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }
}
