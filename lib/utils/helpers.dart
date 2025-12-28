import 'package:intl/intl.dart';

class Helpers {
  // Dakikayı formatlı string'e çevir
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes dk';
    }
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    if (mins == 0) {
      return '$hours saat';
    }
    return '$hours saat $mins dk';
  }

  // Saniyeyi formatlı string'e çevir (sayaç için)
  static String formatSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }

  // Tarihi formatlı string'e çevir
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Bugün';
    } else if (dateOnly == yesterday) {
      return 'Dün';
    } else {
      return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
    }
  }

  // Kısa tarih formatı
  static String formatShortDate(DateTime date) {
    return DateFormat('dd.MM').format(date);
  }

  // Saat formatı
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Hafta günü adı
  static String getWeekdayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }

  // Ay adı
  static String getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  // Haftanın başlangıç tarihi
  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Haftanın bitiş tarihi
  static DateTime getWeekEnd(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  // Ayın başlangıç tarihi
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Ayın bitiş tarihi
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Yılın başlangıç tarihi
  static DateTime getYearStart(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Yılın bitiş tarihi
  static DateTime getYearEnd(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  // Yüzde hesapla
  static double calculatePercentage(int value, int total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Yüzde string formatı
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // ===== PARA DÖNÜŞÜM SİSTEMİ =====
  // Günlük 86.400 saniye = 86.400 TL değerinde
  // Her saniye 1 TL değerinde

  static const int dailySeconds = 86400; // Günlük toplam saniye
  static const double secondValue = 1.0; // Her saniye 1 TL

  // Dakikayı TL'ye çevir (1 dakika = 60 TL)
  static double minutesToMoney(int minutes) {
    return minutes * 60 * secondValue;
  }

  // Saniyeyi TL'ye çevir
  static double secondsToMoney(int seconds) {
    return seconds * secondValue;
  }

  // Para formatla
  static String formatMoney(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ₺';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ₺';
    }
    return '${amount.toStringAsFixed(0)} ₺';
  }

  // Detaylı para formatı
  static String formatMoneyDetailed(double amount) {
    final formatter = NumberFormat('#,###', 'tr_TR');
    return '${formatter.format(amount.toInt())} ₺';
  }

  // Günlük ziyan yüzdesi
  static double getDailyWastePercentage(int wastedMinutes) {
    int wastedSeconds = wastedMinutes * 60;
    return (wastedSeconds / dailySeconds) * 100;
  }

  // Kalan değerli zaman (saniye cinsinden)
  static int getRemainingValueableSeconds(int wastedMinutes) {
    int wastedSeconds = wastedMinutes * 60;
    return dailySeconds - wastedSeconds;
  }

  // Ziyan edilen zamanın somut karşılıkları
  static Map<String, dynamic> getWasteEquivalents(int wastedMinutes) {
    return {
      'money': minutesToMoney(wastedMinutes),
      'books': (wastedMinutes / 180).toStringAsFixed(1), // 3 saat = 1 kitap
      'exercise': (wastedMinutes / 30).toStringAsFixed(1), // 30 dk = 1 egzersiz
      'meditation': (wastedMinutes / 10).toStringAsFixed(0), // 10 dk = 1 meditasyon
      'walks': (wastedMinutes / 20).toStringAsFixed(1), // 20 dk = 1 yürüyüş
      'lessons': (wastedMinutes / 45).toStringAsFixed(1), // 45 dk = 1 ders
    };
  }

  // Haftalık ziyan parası
  static double weeklyWasteMoney(int totalMinutes) {
    return minutesToMoney(totalMinutes);
  }

  // Aylık ziyan parası
  static double monthlyWasteMoney(int totalMinutes) {
    return minutesToMoney(totalMinutes);
  }

  // Yıllık projeksiyon
  static double yearlyProjection(int dailyAverageMinutes) {
    return minutesToMoney(dailyAverageMinutes * 365);
  }
}
