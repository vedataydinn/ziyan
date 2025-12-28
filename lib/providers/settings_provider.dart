import 'package:flutter/foundation.dart';
import '../models/notification_setting.dart';
import '../models/category.dart';
import '../models/achievement.dart';
import '../services/database_service.dart';

class SettingsProvider with ChangeNotifier {
  AppSettings get settings =>
      DatabaseService.appSettings.get('settings') ?? AppSettings();

  List<ZiyanCategory> get categories =>
      DatabaseService.categories.values.toList();

  // Sadece ziyan kategorileri
  List<ZiyanCategory> get wasteCategories =>
      DatabaseService.categories.values.where((c) => !c.isProductive).toList();

  // Sadece verimli kategoriler (telafi için)
  List<ZiyanCategory> get productiveCategories =>
      DatabaseService.categories.values.where((c) => c.isProductive).toList();

  List<NotificationSetting> get notificationSettings =>
      DatabaseService.notificationSettings.values.toList();

  List<Achievement> get achievements =>
      DatabaseService.achievements.values.toList();

  // Tema değiştir
  Future<void> toggleDarkMode() async {
    final current = settings;
    final updated = AppSettings(
      isDarkMode: !current.isDarkMode,
      dailyReminderEnabled: current.dailyReminderEnabled,
      dailyReminderHour: current.dailyReminderHour,
      dailyReminderMinute: current.dailyReminderMinute,
      weeklyReportEnabled: current.weeklyReportEnabled,
      weeklyGoalMinutes: current.weeklyGoalMinutes,
      motivationQuotesEnabled: current.motivationQuotesEnabled,
    );
    await DatabaseService.appSettings.put('settings', updated);
    notifyListeners();
  }

  // Ayarları güncelle
  Future<void> updateSettings({
    bool? isDarkMode,
    bool? dailyReminderEnabled,
    int? dailyReminderHour,
    int? dailyReminderMinute,
    bool? weeklyReportEnabled,
    int? weeklyGoalMinutes,
    bool? motivationQuotesEnabled,
    int? dailyGoalMinutes,
    int? monthlyGoalMinutes,
  }) async {
    final current = settings;
    final updated = AppSettings(
      isDarkMode: isDarkMode ?? current.isDarkMode,
      dailyReminderEnabled: dailyReminderEnabled ?? current.dailyReminderEnabled,
      dailyReminderHour: dailyReminderHour ?? current.dailyReminderHour,
      dailyReminderMinute: dailyReminderMinute ?? current.dailyReminderMinute,
      weeklyReportEnabled: weeklyReportEnabled ?? current.weeklyReportEnabled,
      weeklyGoalMinutes: weeklyGoalMinutes ?? current.weeklyGoalMinutes,
      motivationQuotesEnabled: motivationQuotesEnabled ?? current.motivationQuotesEnabled,
      dailyGoalMinutes: dailyGoalMinutes ?? current.dailyGoalMinutes,
      monthlyGoalMinutes: monthlyGoalMinutes ?? current.monthlyGoalMinutes,
    );
    await DatabaseService.appSettings.put('settings', updated);
    notifyListeners();
  }

  // Bildirim ayarı ekle/güncelle
  Future<void> saveNotificationSetting(NotificationSetting setting) async {
    await DatabaseService.notificationSettings.put(setting.id, setting);
    notifyListeners();
  }

  // Bildirim ayarını sil
  Future<void> deleteNotificationSetting(String id) async {
    await DatabaseService.notificationSettings.delete(id);
    notifyListeners();
  }

  // Bildirim ayarını aç/kapat
  Future<void> toggleNotificationSetting(String id) async {
    final setting = DatabaseService.notificationSettings.get(id);
    if (setting != null) {
      setting.isEnabled = !setting.isEnabled;
      await setting.save();
      notifyListeners();
    }
  }

  // Kategori için bildirim ayarlarını getir
  List<NotificationSetting> getNotificationSettingsForCategory(String categoryId) {
    return notificationSettings.where((s) => s.categoryId == categoryId).toList();
  }

  // Kategori uyarı süresini güncelle
  Future<void> updateCategoryWarningMinutes(String categoryId, int minutes) async {
    final category = DatabaseService.categories.get(categoryId);
    if (category != null) {
      category.warningMinutes = minutes;
      await category.save();
      notifyListeners();
    }
  }

  // Yeni kategori ekle
  Future<void> addCategory(ZiyanCategory category) async {
    await DatabaseService.categories.put(category.id, category);
    notifyListeners();
  }

  // Kategori sil
  Future<void> deleteCategory(String id) async {
    await DatabaseService.categories.delete(id);
    notifyListeners();
  }

  // Başarı güncelle
  Future<void> updateAchievement(String id, {int? currentValue, bool? isUnlocked}) async {
    final achievement = DatabaseService.achievements.get(id);
    if (achievement != null) {
      if (currentValue != null) {
        achievement.currentValue = currentValue;
      }
      if (isUnlocked != null && isUnlocked && !achievement.isUnlocked) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
      }
      await achievement.save();
      notifyListeners();
    }
  }

  // Kilidi açılmış başarıları getir
  List<Achievement> get unlockedAchievements =>
      achievements.where((a) => a.isUnlocked).toList();

  // Kilidi açılmamış başarıları getir
  List<Achievement> get lockedAchievements =>
      achievements.where((a) => !a.isUnlocked).toList();
}
