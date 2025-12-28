import 'dart:math';
import '../services/database_service.dart';

class MotivationQuotes {
  static final List<String> quotes = [
    // Zaman ve değer
    "Zaman, geri alamayacağın tek şey. Her saniyeyi değerlendir.",
    "Bugün ziyan ettiğin her dakika, yarın pişman olacağın bir kayıp.",
    "Hayat çok kısa, sosyal medyada harcamak için çok değerli.",
    "Şu an yaptığın şey, 5 yıl sonraki seni belirliyor.",
    "Bir saatlik odaklanma, beş saatlik dağınık çalışmadan değerli.",

    // Sosyal medya uyarıları
    "Telefonuna her baktığında, hayatından bir parça çalınıyor.",
    "Scroll yapmak yerine, hayallerini inşa etmeye ne dersin?",
    "Başkalarının hayatını izlemek, kendi hayatını yaşamak değil.",
    "Beğeni sayıları değil, gerçek başarılar önemli.",
    "Notification sesleri seni yönetmesin, sen zamanını yönet.",

    // Oyun ve eğlence
    "Oyunlarda seviye atlamak güzel, ama gerçek hayatta?",
    "Sanal dünyada geçirdiğin her saat, gerçek fırsatları kaçırıyorsun.",
    "Eğlence için biraz vakit ayır, ama hayatın eğlence olmasın.",

    // Odak ve disiplin
    "Dikkat dağınıklığı, modern çağın en büyük hastalığı.",
    "Derin odaklanma, süper güç gibidir. Onu geliştir.",
    "Disiplin özgürlük getirir, gevşeklik kölelik.",
    "Bugün kolay olanı seçersen, yarın zor olur.",
    "Konsantrasyon, başarının gizli silahıdır.",

    // Hedef ve başarı
    "Hedefsiz yaşamak, rüzgarda savrulan yaprak gibidir.",
    "Küçük adımlar, dev başarıların temelidir.",
    "Başarı bir gece olmuyor, her gün biraz biraz inşa ediliyor.",
    "Hayallerin büyük, alışkanlıkların güçlü olsun.",
    "Bugün ne yaparsan, yarın onu biçersin.",

    // Kendini geliştirme
    "En iyi yatırım, kitap okumak, öğrenmek, gelişmektir.",
    "Her gün %1 gelişim, yıl sonunda bambaşka biri olursun.",
    "Konfor alanın dışında, gerçek büyüme başlar.",
    "Öğrenmeyi bıraktığın gün, yaşlanmaya başlarsın.",
    "Kendine yaptığın her yatırım, faizle geri döner.",

    // Farkındalık
    "Bu uygulamayı kullanman bile bir farkındalık. Devam et!",
    "Zamanını takip etmek, onu kontrol etmenin ilk adımı.",
    "Bugün nasıl geçiriyorsan, hayatın da öyle geçiyor.",
    "Kötü alışkanlıkların farkında olmak, onları yenmenin yarısı.",

    // Motivasyon
    "Şimdi başla. Yarın diye bir gün yok, sadece bugün var.",
    "Harekete geç! Mükemmel plan, kötü uygulamadan bile kötüdür.",
    "Pişmanlık acıdır, ama disiplin geçicidir.",
    "Yapamam deme, henüz öğrenmedim de.",
    "Einstein da bir zamanlar matematik bilmiyordu.",

    // Pratik öneriler
    "5 dakika mola ver, sonra devam et.",
    "Telefonu başka odaya bırak, mucizeye bak.",
    "Pomodoro dene: 25 dakika çalış, 5 dakika dinlen.",
    "Bir şeyler yapmak istemiyorsan bile, sadece başla.",
    "En zor adım, birinci adım. At onu.",

    // Türkçe atasözleri
    "Bugünün işini yarına bırakma.",
    "Damlaya damlaya göl olur.",
    "Azim varsa, yol da var.",
    "Sabır acıdır, meyvesi tatlıdır.",
    "Çalışan demir pas tutmaz.",
    "Ak akça kara gün içindir.",
  ];

  static final List<String> warningQuotes = [
    "⚠️ Dur ve düşün: Bu zaman dilimi geri gelmeyecek!",
    "⚠️ Dikkat! Hedeflerinden uzaklaşıyorsun.",
    "⚠️ Kendine verdiğin sözü hatırla!",
    "⚠️ Bu süre, hayallerine mi harcandı?",
    "⚠️ Şu an ne yapıyor olmalıydın?",
    "⚠️ Fırsat maliyetini düşün!",
    "⚠️ Zaman akıyor, sen de akıyor musun?",
    "⚠️ Gerçekten buna mı ihtiyacın var?",
    "⚠️ Önceliklerini gözden geçir!",
    "⚠️ Bu dakikalar, gelecekten çalınıyor.",
  ];

  static final List<String> successQuotes = [
    "🌟 Harika gidiyorsun! Bu disiplini koru!",
    "💪 Bugün kendini aştın, tebrikler!",
    "🎯 İşte bu odaklanma! Devam et!",
    "🏆 Mükemmel performans gösteriyorsun!",
    "🚀 Hedefine her geçen gün yaklaşıyorsun!",
    "⭐ Bugün gurur duyulacak bir gün!",
    "🎉 Başarı senin hakkın, devam et!",
    "🌱 Tutarlılığın meyvesini veriyor!",
    "💎 Elmas gibi parlıyorsun!",
    "🔥 Ateş gibi yanıyorsun, söndürme!",
  ];

  static final List<String> morningQuotes = [
    "🌅 Günaydın! Bugün harika şeyler başaracaksın!",
    "☀️ Yeni bir gün, yeni fırsatlar! Değerlendir!",
    "🎯 Bugün hedeflerine bir adım daha yaklaş!",
    "💪 Güne enerjik başla, güçlü bitir!",
    "🌟 Bu gün seni bekliyor, hayal kırıklığına uğratma!",
    "🌈 Her yeni gün, yeni bir başlangıç!",
  ];

  static final List<String> eveningQuotes = [
    "🌙 Bugün nasıl geçti? Kendini değerlendir.",
    "📝 Gün biterken bir özet çıkar, yarına hazırlan.",
    "📋 Yarın için planını yap, hazırlıklı ol.",
    "✨ Bugün öğrendiklerini not et, unutma.",
    "🌟 İyi geceler, yarın daha iyi olacak!",
    "🌜 Dinlen ve yarın için enerji topla.",
  ];

  static String getRandomQuote() {
    // Devre dışı bırakılmış sözleri al
    final disabled = DatabaseService.generalSettings.get('disabled_quotes');
    final disabledSet = disabled != null ? Set<String>.from(disabled as List) : <String>{};

    // Aktif varsayılan sözler
    final activeQuotes = quotes.where((q) => !disabledSet.contains(q)).toList();

    // Özel sözler
    final customQuotes = DatabaseService.customQuotes.values.toList();

    // Tüm aktif sözler
    final allQuotes = [...activeQuotes, ...customQuotes.map((q) => q.text)];

    if (allQuotes.isEmpty) {
      return 'Zamanını değerli kullan!';
    }

    final random = Random();
    return allQuotes[random.nextInt(allQuotes.length)];
  }

  static String getRandomWarningQuote() {
    final random = Random();
    return warningQuotes[random.nextInt(warningQuotes.length)];
  }

  static String getRandomSuccessQuote() {
    final random = Random();
    return successQuotes[random.nextInt(successQuotes.length)];
  }

  static String getMorningQuote() {
    final random = Random();
    return morningQuotes[random.nextInt(morningQuotes.length)];
  }

  static String getEveningQuote() {
    final random = Random();
    return eveningQuotes[random.nextInt(eveningQuotes.length)];
  }

  static String getQuoteByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return getMorningQuote();
    } else if (hour >= 20 || hour < 5) {
      return getEveningQuote();
    }
    return getRandomQuote();
  }
}
