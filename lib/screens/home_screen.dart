import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/helpers.dart';
import '../utils/motivation_quotes.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentQuote = '';
  DateTime _lastQuoteTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentQuote = MotivationQuotes.getRandomQuote();
  }

  void _updateQuoteIfNeeded() {
    final now = DateTime.now();
    // 5 dakikada bir söz değiştir
    if (now.difference(_lastQuoteTime).inMinutes >= 5) {
      setState(() {
        _currentQuote = MotivationQuotes.getRandomQuote();
        _lastQuoteTime = now;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Her build'de söz güncelleme kontrolü yap
    _updateQuoteIfNeeded();

    return Consumer2<TimeProvider, SettingsProvider>(
      builder: (context, timeProvider, settingsProvider, child) {
        final isTimerRunning = timeProvider.isTimerRunning;
        final wastedMinutes = timeProvider.getTodayWasteTotal();
        final productiveMinutes = timeProvider.getTodayProductiveTotal();
        final dailyGoal = settingsProvider.settings.dailyGoalMinutes;

        // Canlı hesaplama
        final currentEntry = timeProvider.currentActiveEntry;
        final elapsedSeconds = timeProvider.elapsedSeconds;
        final isCurrentWaste = currentEntry != null &&
            !(DatabaseService.categories.get(currentEntry.category)?.isProductive ?? false);
        final isCurrentProductive = currentEntry != null &&
            (DatabaseService.categories.get(currentEntry.category)?.isProductive ?? false);

        // Canlı toplam
        final liveWastedMinutes = wastedMinutes + (isCurrentWaste ? (elapsedSeconds ~/ 60) : 0);
        final liveProductiveMinutes = productiveMinutes + (isCurrentProductive ? (elapsedSeconds ~/ 60) : 0);

        // NET hesaplama: Ziyan - Telafi (minimum 0)
        final liveNetMinutes = (liveWastedMinutes - liveProductiveMinutes).clamp(0, 999999);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Ziyan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  settingsProvider.settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  size: 22,
                ),
                onPressed: () => settingsProvider.toggleDarkMode(),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // 1. MOTİVASYON SÖZÜ (Sabit boyut)
                  if (settingsProvider.settings.motivationQuotesEnabled)
                    _buildMotivationQuote(context),

                  if (settingsProvider.settings.motivationQuotesEnabled)
                    const SizedBox(height: 16),

                  // 2. SÜRE VE DEĞER GÖSTERGESİ + BUTONLAR (Ortalanmış)
                  Expanded(
                    child: Center(
                      child: _buildTimerSection(context, timeProvider, isTimerRunning, elapsedSeconds),
                    ),
                  ),

                  // 3. PROGRESS BAR - Günlük Durum
                  _buildDailyProgressBar(
                    context,
                    liveWastedMinutes,
                    liveProductiveMinutes,
                    liveNetMinutes,
                    dailyGoal,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== MOTİVASYON SÖZÜ (SABİT BOYUT) =====
  Widget _buildMotivationQuote(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote_rounded, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentQuote,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ===== SÜRE VE DEĞER + BUTONLAR =====
  Widget _buildTimerSection(BuildContext context, TimeProvider timeProvider, bool isRunning, int seconds) {
    final category = isRunning
        ? DatabaseService.categories.get(timeProvider.currentActiveEntry?.category ?? '')
        : null;
    final isProductive = category?.isProductive ?? false;
    final liveMoney = Helpers.minutesToMoney(seconds ~/ 60) + (seconds % 60) * 1.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRunning) ...[
            // Kategori bilgisi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (isProductive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (isProductive ? Colors.green : Colors.red).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category?.iconData ?? Icons.access_time,
                    color: isProductive ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category?.name ?? 'Bilinmeyen',
                    style: TextStyle(
                      color: isProductive ? Colors.green.shade700 : Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isProductive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'TELAFİ',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],

          // Süre | Değer
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'SÜRE',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isRunning ? Helpers.formatSeconds(seconds) : '00:00',
                      style: TextStyle(
                        color: isRunning
                            ? (isProductive ? Colors.green.shade700 : Colors.red.shade700)
                            : Colors.grey[700],
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              Container(width: 1, height: 60, color: Colors.grey[300]),

              Expanded(
                child: Column(
                  children: [
                    Text(
                      'DEĞER',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isRunning
                          ? '${isProductive ? '+' : '-'}${liveMoney.toInt()} ₺'
                          : '0 ₺',
                      style: TextStyle(
                        color: isRunning
                            ? (isProductive ? Colors.green.shade700 : Colors.red.shade700)
                            : Colors.grey[700],
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Butonlar
          if (isRunning) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context, timeProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('İptal', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => timeProvider.stopTimer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isProductive ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, size: 20),
                        SizedBox(width: 6),
                        Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () => _showStartDialog(context, isCompensation: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 26),
                        SizedBox(width: 8),
                        Text('ZİYANI BAŞLAT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _showStartDialog(context, isCompensation: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.spa_rounded, size: 26),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ===== GÜNLÜK PROGRESS BAR =====
  Widget _buildDailyProgressBar(
    BuildContext context,
    int wastedMinutes,
    int productiveMinutes,
    int netMinutes,
    int dailyGoal,
  ) {
    final isOverLimit = netMinutes >= dailyGoal && dailyGoal > 0;

    // Progress bar için: Önce NET (kırmızı), sonra Telafi (yeşil), sonra boş
    // Toplam = Ziyan (net + telafi aynı anda olmaz, ziyan = net + telafi edilmiş kısım)
    // Ama mantık şu: Bar üzerinde NET ziyan kırmızı, telafi yeşil, geri kalan boş

    // Yüzde hesaplamaları (dailyGoal üzerinden)
    final netPercent = dailyGoal > 0 ? (netMinutes / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final productivePercent = dailyGoal > 0 ? (productiveMinutes / dailyGoal).clamp(0.0, 1.0 - netPercent) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverLimit ? Colors.red.shade300 : Colors.grey.withValues(alpha: 0.15),
          width: isOverLimit ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Başlık satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Günlük Durum',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverLimit ? Colors.red.shade100 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverLimit
                      ? 'Limit Aşıldı!'
                      : 'Max: ${Helpers.formatMinutes(dailyGoal)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverLimit ? Colors.red.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final netWidth = totalWidth * netPercent;
                  final productiveWidth = totalWidth * productivePercent;

                  return Stack(
                    children: [
                      // Kırmızı - NET Ziyan (sol taraftan başlar)
                      if (netMinutes > 0)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: netWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red.shade400, Colors.red.shade500],
                              ),
                            ),
                          ),
                        ),

                      // Yeşil - Telafi (kırmızıdan sonra başlar)
                      if (productiveMinutes > 0)
                        Positioned(
                          left: netWidth,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: productiveWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade400, Colors.green.shade500],
                              ),
                            ),
                          ),
                        ),

                      // Üzerinde yazılar
                      Positioned.fill(
                        child: Row(
                          children: [
                            // Sol - Net Ziyan
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  'Net: ${Helpers.formatMinutes(netMinutes)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: netPercent > 0.2 ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            // Sağ - Limit
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Text(
                                '/ ${Helpers.formatMinutes(dailyGoal)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Alt bilgi satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Ziyan', wastedMinutes, Colors.red),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              _buildMiniStat('Telafi', productiveMinutes, Colors.green),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              _buildMiniStat('Net', netMinutes, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, int minutes, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              Helpers.formatMinutes(minutes),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== DİALOGLAR =====
  void _showStartDialog(BuildContext context, {required bool isCompensation}) {
    final categories = isCompensation
        ? DatabaseService.categories.values.where((c) => c.isProductive).toList()
        : DatabaseService.categories.values.where((c) => !c.isProductive).toList();
    String? selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCompensation ? 'Telafi Kategorisi Seç' : 'Ziyan Kategorisi Seç',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category.id;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = category.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? category.color : category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? category.color : category.color.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.iconData,
                            size: 18,
                            color: isSelected ? Colors.white : category.color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedCategory == null
                      ? null
                      : () {
                          context.read<TimeProvider>().startTimer(selectedCategory!, '');
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompensation ? Colors.green : Colors.red,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Başlat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, TimeProvider timeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('İptal Et', style: TextStyle(fontSize: 18)),
        content: const Text('Süre kaydedilmeyecek. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              timeProvider.cancelTimer();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }
}
