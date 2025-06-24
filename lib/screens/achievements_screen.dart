import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();

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
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding:const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildAchievementsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon:const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
         const SizedBox(width: 8),
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final unlockedCount = _achievementService.unlockedAchievements.length;
    final totalCount = _achievementService.allAchievements.length;
    final totalPoints = _achievementService.totalPoints;

    return Container(
      width: double.infinity,
      padding:const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Unlocked', '$unlockedCount/$totalCount', Icons.emoji_events),
              _buildStatItem('Total Points', '$totalPoints', Icons.star),
              _buildStatItem('Progress', '${((unlockedCount / totalCount) * 100).round()}%', Icons.trending_up),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: unlockedCount / totalCount,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF00D4FF), size: 28),
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

  Widget _buildAchievementsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ..._achievementService.allAchievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = _achievementService.unlockedAchievements
        .any((a) => a.id == achievement.id);

    return Container(
      margin:const EdgeInsets.only(bottom: 12),
      padding:const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnlocked 
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked 
              ? Color(0xFF00D4FF).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked 
                  ? Color(0xFF00D4FF).withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock,
              color: isUnlocked ? Color(0xFF00D4FF) : Colors.white.withOpacity(0.4),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnlocked 
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
                if (isUnlocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Unlocked ${_formatDate(_achievementService.unlockedAchievements.firstWhere((a) => a.id == achievement.id).unlockedDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00D4FF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding:const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? Color(0xFF00D4FF) : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${achievement.points}',
              style:const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
