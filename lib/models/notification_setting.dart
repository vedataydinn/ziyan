import 'package:hive/hive.dart';

part 'notification_setting.g.dart';

@HiveType(typeId: 2)
class NotificationSetting extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId; // Hangi kategori için

  @HiveField(2)
  int thresholdMinutes; // Kaç dakika sonra uyarsın

  @HiveField(3)
  bool isEnabled;

  @HiveField(4)
  String message; // Özel mesaj

  @HiveField(5)
  bool isUrgent; // Kırmızı acil bildirim mi

  NotificationSetting({
    required this.id,
    required this.categoryId,
    required this.thresholdMinutes,
    this.isEnabled = true,
    this.message = '',
    this.isUrgent = false,
  });
}

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool dailyReminderEnabled;

  @HiveField(2)
  int dailyReminderHour;

  @HiveField(3)
  int dailyReminderMinute;

  @HiveField(4)
  bool weeklyReportEnabled;

  @HiveField(5)
  int weeklyGoalMinutes; // Haftalık hedef (max bu kadar ziyan)

  @HiveField(6)
  bool motivationQuotesEnabled;

  @HiveField(7)
  int dailyGoalMinutes; // Günlük hedef (max bu kadar ziyan)

  @HiveField(8)
  int monthlyGoalMinutes; // Aylık hedef (max bu kadar ziyan)

  AppSettings({
    this.isDarkMode = false,
    this.dailyReminderEnabled = true,
    this.dailyReminderHour = 21,
    this.dailyReminderMinute = 0,
    this.weeklyReportEnabled = true,
    this.weeklyGoalMinutes = 600, // 10 saat
    this.motivationQuotesEnabled = true,
    this.dailyGoalMinutes = 120, // 2 saat günlük
    this.monthlyGoalMinutes = 2400, // 40 saat aylık
  });
}
