import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 4)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconName;

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  DateTime? unlockedAt;

  @HiveField(6)
  int targetValue; // Hedef değer

  @HiveField(7)
  int currentValue; // Mevcut ilerleme

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.targetValue,
    this.currentValue = 0,
  });

  double get progress => currentValue / targetValue;

  IconData get icon {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'target':
        return Icons.track_changes;
      case 'clock':
        return Icons.access_time;
      case 'shield':
        return Icons.shield;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.workspace_premium;
    }
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_entry',
        title: 'İlk Adım',
        description: 'İlk ziyan kaydını oluşturdun!',
        iconName: 'star',
        targetValue: 1,
      ),
      Achievement(
        id: 'week_tracker',
        title: 'Haftalık Takipçi',
        description: '7 gün üst üste kayıt tuttun',
        iconName: 'fire',
        targetValue: 7,
      ),
      Achievement(
        id: 'goal_achiever',
        title: 'Hedef Avcısı',
        description: 'Haftalık hedefini tutturdun',
        iconName: 'target',
        targetValue: 1,
      ),
      Achievement(
        id: 'month_master',
        title: 'Ay Ustası',
        description: '30 gün boyunca takip ettin',
        iconName: 'trophy',
        targetValue: 30,
      ),
      Achievement(
        id: 'time_saver',
        title: 'Zaman Koruyucu',
        description: 'Bir haftada hedefin altında kaldın',
        iconName: 'shield',
        targetValue: 1,
      ),
      Achievement(
        id: 'diamond_focus',
        title: 'Elmas Odak',
        description: '3 gün hiç ziyan kaydetmedin',
        iconName: 'diamond',
        targetValue: 3,
      ),
    ];
  }
}
