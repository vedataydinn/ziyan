import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarılar'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final unlocked = settingsProvider.unlockedAchievements;
          final locked = settingsProvider.lockedAchievements;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // İstatistik kartı
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${unlocked.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kazanılan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 60,
                        color: Colors.grey[300],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${locked.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Kilitli',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kazanılan başarılar
              if (unlocked.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Kazanılan Başarılar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...unlocked.map((achievement) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement.icon,
                            color: Colors.amber,
                          ),
                        ),
                        title: Text(
                          achievement.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(achievement.description),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
              ],

              // Kilitli başarılar
              if (locked.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Kilitli Başarılar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...locked.map((achievement) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: Theme.of(context).cardColor.withValues(alpha: 0.7),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement.icon,
                            color: Colors.grey,
                          ),
                        ),
                        title: Text(
                          achievement.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.description,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: achievement.progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${achievement.currentValue}/${achievement.targetValue}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}
