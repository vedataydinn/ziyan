import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/time_entry.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../utils/motivation_quotes.dart';

class TimeProvider with ChangeNotifier {
  Timer? _activeTimer;
  TimeEntry? _currentActiveEntry;
  int _elapsedSeconds = 0;

  TimeEntry? get currentActiveEntry => _currentActiveEntry;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isTimerRunning => _activeTimer != null;

  TimeProvider() {
    _loadActiveTimer();
  }

  // Aktif timer'ı yükle (uygulama kapansa bile)
  Future<void> _loadActiveTimer() async {
    final box = DatabaseService.activeTimer;
    final startTimeStr = box.get('startTime');
    final categoryId = box.get('categoryId');
    final description = box.get('description');

    if (startTimeStr != null && categoryId != null) {
      final startTime = DateTime.parse(startTimeStr);
      _elapsedSeconds = DateTime.now().difference(startTime).inSeconds;

      _currentActiveEntry = TimeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: categoryId,
        description: description ?? '',
        durationMinutes: 0,
        dateTime: DateTime.now(),
        isActive: true,
        startTime: startTime,
      );

      _startTimerTick();
      notifyListeners();
    }
  }

  // Sayacı başlat
  Future<void> startTimer(String categoryId, String description) async {
    if (_activeTimer != null) {
      await stopTimer();
    }

    final startTime = DateTime.now();
    _currentActiveEntry = TimeEntry(
      id: startTime.millisecondsSinceEpoch.toString(),
      category: categoryId,
      description: description,
      durationMinutes: 0,
      dateTime: startTime,
      isActive: true,
      startTime: startTime,
    );

    // Aktif timer'ı kaydet
    final box = DatabaseService.activeTimer;
    await box.put('startTime', startTime.toIso8601String());
    await box.put('categoryId', categoryId);
    await box.put('description', description);

    _elapsedSeconds = 0;
    _startTimerTick();
    notifyListeners();
  }

  void _startTimerTick() {
    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();

      // Her dakikada bildirim kontrolü yap
      if (_elapsedSeconds % 60 == 0) {
        _checkNotifications();
      }
    });
  }

  // Bildirim kontrolü
  Future<void> _checkNotifications() async {
    if (_currentActiveEntry == null) return;

    final categoryId = _currentActiveEntry!.category;
    final totalMinutesToday = getTodayTotalForCategory(categoryId) + (_elapsedSeconds ~/ 60);

    // Bildirim ayarlarını kontrol et
    final settings = DatabaseService.notificationSettings.values
        .where((s) => s.categoryId == categoryId && s.isEnabled)
        .toList();

    for (var setting in settings) {
      if (totalMinutesToday >= setting.thresholdMinutes) {
        final category = DatabaseService.categories.get(categoryId);
        await NotificationService.showTimeWarning(
          categoryName: category?.name ?? 'Bilinmeyen',
          minutes: totalMinutesToday,
          isUrgent: setting.isUrgent,
          customMessage: setting.message.isNotEmpty
              ? '${setting.message} (${MotivationQuotes.getRandomWarningQuote()})'
              : null,
        );
      }
    }
  }

  // Sayacı durdur ve kaydet
  Future<void> stopTimer() async {
    if (_currentActiveEntry == null) return;

    _activeTimer?.cancel();
    _activeTimer = null;

    final durationMinutes = _elapsedSeconds ~/ 60;
    if (durationMinutes > 0) {
      final entry = _currentActiveEntry!.copyWith(
        durationMinutes: durationMinutes,
        isActive: false,
      );
      await DatabaseService.timeEntries.put(entry.id, entry);
    }

    // Aktif timer'ı temizle
    final box = DatabaseService.activeTimer;
    await box.clear();

    _currentActiveEntry = null;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  // Sayacı iptal et (kaydetmeden durdur)
  Future<void> cancelTimer() async {
    if (_currentActiveEntry == null) return;

    _activeTimer?.cancel();
    _activeTimer = null;

    // Aktif timer'ı temizle (kaydetmeden)
    final box = DatabaseService.activeTimer;
    await box.clear();

    _currentActiveEntry = null;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  // Manuel kayıt ekle
  Future<void> addManualEntry({
    required String categoryId,
    required String description,
    required int durationMinutes,
    DateTime? dateTime,
  }) async {
    final entry = TimeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: categoryId,
      description: description,
      durationMinutes: durationMinutes,
      dateTime: dateTime ?? DateTime.now(),
    );

    await DatabaseService.timeEntries.put(entry.id, entry);
    notifyListeners();
  }

  // Kayıt sil
  Future<void> deleteEntry(String id) async {
    await DatabaseService.timeEntries.delete(id);
    notifyListeners();
  }

  // Bugünün toplamı
  int getTodayTotal() {
    final today = DateTime.now();
    return DatabaseService.timeEntries.values
        .where((e) =>
            e.dateTime.year == today.year &&
            e.dateTime.month == today.month &&
            e.dateTime.day == today.day)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Kategoriye göre bugünün toplamı
  int getTodayTotalForCategory(String categoryId) {
    final today = DateTime.now();
    return DatabaseService.timeEntries.values
        .where((e) =>
            e.category == categoryId &&
            e.dateTime.year == today.year &&
            e.dateTime.month == today.month &&
            e.dateTime.day == today.day)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Haftalık toplam
  int getWeeklyTotal() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return DatabaseService.timeEntries.values
        .where((e) => e.dateTime.isAfter(weekStart.subtract(const Duration(days: 1))))
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Aylık toplam
  int getMonthlyTotal() {
    final now = DateTime.now();
    return DatabaseService.timeEntries.values
        .where((e) => e.dateTime.year == now.year && e.dateTime.month == now.month)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Yıllık toplam
  int getYearlyTotal() {
    final now = DateTime.now();
    return DatabaseService.timeEntries.values
        .where((e) => e.dateTime.year == now.year)
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Belirli tarih aralığında toplam
  int getTotalForDateRange(DateTime start, DateTime end) {
    return DatabaseService.timeEntries.values
        .where((e) =>
            e.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
            e.dateTime.isBefore(end.add(const Duration(days: 1))))
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Bugünün kayıtlarını sil (sıfırla)
  Future<void> clearTodayEntries() async {
    final today = DateTime.now();
    final todayEntries = DatabaseService.timeEntries.values
        .where((e) =>
            e.dateTime.year == today.year &&
            e.dateTime.month == today.month &&
            e.dateTime.day == today.day)
        .toList();

    for (var entry in todayEntries) {
      await DatabaseService.timeEntries.delete(entry.id);
    }

    // Aktif timer'ı da iptal et
    if (_activeTimer != null) {
      _activeTimer?.cancel();
      _activeTimer = null;
      await DatabaseService.activeTimer.clear();
      _currentActiveEntry = null;
      _elapsedSeconds = 0;
    }

    notifyListeners();
  }

  // Tüm kayıtları sil
  Future<void> clearAllEntries() async {
    await DatabaseService.timeEntries.clear();

    if (_activeTimer != null) {
      _activeTimer?.cancel();
      _activeTimer = null;
      await DatabaseService.activeTimer.clear();
      _currentActiveEntry = null;
      _elapsedSeconds = 0;
    }

    notifyListeners();
  }

  // Kategori bazlı istatistikler
  Map<String, int> getCategoryStats({
    required DateTime start,
    required DateTime end,
  }) {
    final entries = DatabaseService.timeEntries.values.where((e) =>
        e.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
        e.dateTime.isBefore(end.add(const Duration(days: 1))));

    final Map<String, int> stats = {};
    for (var entry in entries) {
      stats[entry.category] = (stats[entry.category] ?? 0) + entry.durationMinutes;
    }
    return stats;
  }

  // Günlük kayıtları getir
  List<TimeEntry> getEntriesForDate(DateTime date) {
    return DatabaseService.timeEntries.values
        .where((e) =>
            e.dateTime.year == date.year &&
            e.dateTime.month == date.month &&
            e.dateTime.day == date.day)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Son 7 günlük veriler (grafik için)
  List<int> getLast7DaysData() {
    final List<int> data = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final total = DatabaseService.timeEntries.values
          .where((e) =>
              e.dateTime.year == date.year &&
              e.dateTime.month == date.month &&
              e.dateTime.day == date.day)
          .fold(0, (sum, e) => sum + e.durationMinutes);
      data.add(total);
    }
    return data;
  }

  // Tüm kayıtları getir
  List<TimeEntry> getAllEntries() {
    return DatabaseService.timeEntries.values.toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // ===== VERİMLİ/ZİYAN AYIRIMI =====

  // Bugünün ziyan toplamı (sadece ziyan kategorileri)
  int getTodayWasteTotal() {
    final today = DateTime.now();
    return DatabaseService.timeEntries.values
        .where((e) {
          final category = DatabaseService.categories.get(e.category);
          return e.dateTime.year == today.year &&
              e.dateTime.month == today.month &&
              e.dateTime.day == today.day &&
              (category == null || !category.isProductive);
        })
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Bugünün verimli toplamı (sadece verimli kategorileri)
  int getTodayProductiveTotal() {
    final today = DateTime.now();
    return DatabaseService.timeEntries.values
        .where((e) {
          final category = DatabaseService.categories.get(e.category);
          return e.dateTime.year == today.year &&
              e.dateTime.month == today.month &&
              e.dateTime.day == today.day &&
              category != null &&
              category.isProductive;
        })
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Telafi oranı hesapla (verimli / ziyan)
  double getCompensationRatio() {
    final waste = getTodayWasteTotal();
    final productive = getTodayProductiveTotal();
    if (waste == 0) return productive > 0 ? 100.0 : 0.0;
    return (productive / waste) * 100;
  }

  // Net zaman (verimli - ziyan)
  int getNetTime() {
    return getTodayProductiveTotal() - getTodayWasteTotal();
  }

  // Haftalık ziyan toplamı
  int getWeeklyWasteTotal() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return DatabaseService.timeEntries.values
        .where((e) {
          final category = DatabaseService.categories.get(e.category);
          return e.dateTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              (category == null || !category.isProductive);
        })
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  // Haftalık verimli toplamı
  int getWeeklyProductiveTotal() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return DatabaseService.timeEntries.values
        .where((e) {
          final category = DatabaseService.categories.get(e.category);
          return e.dateTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              category != null &&
              category.isProductive;
        })
        .fold(0, (sum, e) => sum + e.durationMinutes);
  }

  @override
  void dispose() {
    _activeTimer?.cancel();
    super.dispose();
  }
}
