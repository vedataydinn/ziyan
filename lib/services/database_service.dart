import 'package:hive_flutter/hive_flutter.dart';
import '../models/time_entry.dart';
import '../models/category.dart';
import '../models/notification_setting.dart';
import '../models/achievement.dart';
import '../models/custom_quote.dart';

class DatabaseService {
  static const String timeEntriesBox = 'time_entries';
  static const String categoriesBox = 'categories';
  static const String notificationSettingsBox = 'notification_settings';
  static const String appSettingsBox = 'app_settings';
  static const String achievementsBox = 'achievements';
  static const String activeTimerBox = 'active_timer';
  static const String customQuotesBox = 'custom_quotes';
  static const String appLockBox = 'app_lock';
  static const String generalSettingsBox = 'general_settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Adaptörleri kaydet
    Hive.registerAdapter(TimeEntryAdapter());
    Hive.registerAdapter(ZiyanCategoryAdapter());
    Hive.registerAdapter(NotificationSettingAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(CustomQuoteAdapter());
    Hive.registerAdapter(AppLockAdapter());

    // Box'ları aç
    await Hive.openBox<TimeEntry>(timeEntriesBox);
    await Hive.openBox<ZiyanCategory>(categoriesBox);
    await Hive.openBox<NotificationSetting>(notificationSettingsBox);
    await Hive.openBox<AppSettings>(appSettingsBox);
    await Hive.openBox<Achievement>(achievementsBox);
    await Hive.openBox(activeTimerBox);
    await Hive.openBox<CustomQuote>(customQuotesBox);
    await Hive.openBox<AppLock>(appLockBox);
    await Hive.openBox(generalSettingsBox);

    // Varsayılan değerleri ekle
    await _initDefaultCategories();
    await _initDefaultAchievements();
    await _initDefaultSettings();
    await _initDefaultLock();
  }

  static Future<void> _initDefaultCategories() async {
    final box = Hive.box<ZiyanCategory>(categoriesBox);
    if (box.isEmpty) {
      // Ziyan kategorileri
      final defaultCategories = ZiyanCategory.getDefaultCategories();
      for (var category in defaultCategories) {
        await box.put(category.id, category);
      }
      // Verimli kategoriler
      final productiveCategories = ZiyanCategory.getDefaultProductiveCategories();
      for (var category in productiveCategories) {
        await box.put(category.id, category);
      }
    }
  }

  // Verimli kategorileri kontrol et ve ekle (mevcut kullanıcılar için)
  static Future<void> ensureProductiveCategories() async {
    final box = Hive.box<ZiyanCategory>(categoriesBox);
    final hasProductive = box.values.any((c) => c.isProductive);
    if (!hasProductive) {
      final productiveCategories = ZiyanCategory.getDefaultProductiveCategories();
      for (var category in productiveCategories) {
        await box.put(category.id, category);
      }
    }
  }

  static Future<void> _initDefaultAchievements() async {
    final box = Hive.box<Achievement>(achievementsBox);
    if (box.isEmpty) {
      final defaultAchievements = Achievement.getDefaultAchievements();
      for (var achievement in defaultAchievements) {
        await box.put(achievement.id, achievement);
      }
    }
  }

  static Future<void> _initDefaultSettings() async {
    final box = Hive.box<AppSettings>(appSettingsBox);
    if (box.isEmpty) {
      await box.put('settings', AppSettings());
    }
  }

  static Future<void> _initDefaultLock() async {
    final box = Hive.box<AppLock>(appLockBox);
    if (box.isEmpty) {
      await box.put('lock', AppLock());
    }
  }

  // Getters
  static Box<TimeEntry> get timeEntries => Hive.box<TimeEntry>(timeEntriesBox);
  static Box<ZiyanCategory> get categories => Hive.box<ZiyanCategory>(categoriesBox);
  static Box<NotificationSetting> get notificationSettings =>
      Hive.box<NotificationSetting>(notificationSettingsBox);
  static Box<AppSettings> get appSettings => Hive.box<AppSettings>(appSettingsBox);
  static Box<Achievement> get achievements => Hive.box<Achievement>(achievementsBox);
  static Box get activeTimer => Hive.box(activeTimerBox);
  static Box<CustomQuote> get customQuotes => Hive.box<CustomQuote>(customQuotesBox);
  static Box<AppLock> get appLock => Hive.box<AppLock>(appLockBox);
  static Box get generalSettings => Hive.box(generalSettingsBox);
}
