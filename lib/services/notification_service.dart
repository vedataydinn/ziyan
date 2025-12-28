import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android için bildirim kanalları oluştur
    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    const normalChannel = AndroidNotificationChannel(
      'ziyan_normal',
      'Normal Bildirimler',
      description: 'Normal uyarı bildirimleri',
      importance: Importance.high,
    );

    const urgentChannel = AndroidNotificationChannel(
      'ziyan_urgent',
      'Acil Bildirimler',
      description: 'Kırmızı alan uyarıları',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(normalChannel);
    await androidPlugin?.createNotificationChannel(urgentChannel);
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Bildirime tıklandığında yapılacak işlemler
  }

  // Normal bildirim gönder
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ziyan_normal',
      'Normal Bildirimler',
      channelDescription: 'Normal uyarı bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Acil (kırmızı) bildirim gönder
  static Future<void> showUrgentNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'ziyan_urgent',
      'Acil Bildirimler',
      channelDescription: 'Kırmızı alan uyarıları',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Colors.red,
      colorized: true,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  // Süre uyarısı gönder
  static Future<void> showTimeWarning({
    required String categoryName,
    required int minutes,
    required bool isUrgent,
    String? customMessage,
  }) async {
    final title = isUrgent ? '⚠️ UYARI: $categoryName' : '⏰ $categoryName Uyarısı';
    final body = customMessage ??
        'Bugün $categoryName için ${_formatMinutes(minutes)} harcadın. Dikkat et!';

    if (isUrgent) {
      await showUrgentNotification(
        id: categoryName.hashCode,
        title: title,
        body: body,
      );
    } else {
      await showNotification(
        id: categoryName.hashCode,
        title: title,
        body: body,
      );
    }
  }

  // Günlük özet bildirimi
  static Future<void> showDailySummary({
    required int totalMinutes,
    required String topCategory,
    required String motivationQuote,
  }) async {
    await showNotification(
      id: 999,
      title: '📊 Günlük Özet',
      body: 'Bugün toplam ${_formatMinutes(totalMinutes)} harcadın. '
          'En çok: $topCategory. $motivationQuote',
    );
  }

  // Haftalık rapor bildirimi
  static Future<void> showWeeklyReport({
    required int totalMinutes,
    required int goalMinutes,
    required bool goalAchieved,
  }) async {
    final title = goalAchieved
        ? '🎉 Haftalık Hedef Başarıldı!'
        : '📈 Haftalık Rapor';
    final body = goalAchieved
        ? 'Tebrikler! Bu hafta sadece ${_formatMinutes(totalMinutes)} harcadın. '
            'Hedefin ${_formatMinutes(goalMinutes)} idi.'
        : 'Bu hafta ${_formatMinutes(totalMinutes)} harcadın. '
            'Hedefin ${_formatMinutes(goalMinutes)} idi. Gelecek hafta daha iyi!';

    await showNotification(
      id: 1000,
      title: title,
      body: body,
    );
  }

  static String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes dakika';
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    if (mins == 0) return '$hours saat';
    return '$hours saat $mins dakika';
  }

  // Bildirimleri iptal et
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
