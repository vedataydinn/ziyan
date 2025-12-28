import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/time_provider.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
            Tab(text: 'Yıllık'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DailyStats(),
          _WeeklyStats(),
          _MonthlyStats(),
          _YearlyStats(),
        ],
      ),
    );
  }
}

// Günlük İstatistikler
class _DailyStats extends StatelessWidget {
  const _DailyStats();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeProvider>(
      builder: (context, timeProvider, child) {
        final today = DateTime.now();
        final entries = timeProvider.getEntriesForDate(today);
        final totalMinutes = timeProvider.getTodayTotal();
        final categoryStats = timeProvider.getCategoryStats(
          start: today,
          end: today,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Özet kart
              _SummaryCard(
                title: 'Bugün',
                subtitle: Helpers.formatDate(today),
                totalMinutes: totalMinutes,
              ),

              const SizedBox(height: 24),

              // Kategori dağılımı
              if (categoryStats.isNotEmpty) ...[
                const Text(
                  'Kategori Dağılımı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _CategoryPieChart(stats: categoryStats),
                const SizedBox(height: 16),
                _CategoryList(stats: categoryStats),
              ],

              const SizedBox(height: 24),

              // Kayıt listesi
              const Text(
                'Kayıtlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...entries.map((entry) {
                final category = DatabaseService.categories.get(entry.category);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      category?.iconData ?? Icons.access_time,
                      color: category?.color,
                    ),
                    title: Text(category?.name ?? 'Bilinmeyen'),
                    subtitle: Text(
                      '${Helpers.formatTime(entry.dateTime)} - ${entry.description}',
                    ),
                    trailing: Text(
                      entry.formattedDuration,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: category?.color,
                      ),
                    ),
                  ),
                );
              }),

              if (entries.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Bugün kayıt yok'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Haftalık İstatistikler
class _WeeklyStats extends StatelessWidget {
  const _WeeklyStats();

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimeProvider, SettingsProvider>(
      builder: (context, timeProvider, settingsProvider, child) {
        final now = DateTime.now();
        final weekStart = Helpers.getWeekStart(now);
        final weekEnd = Helpers.getWeekEnd(now);
        final totalMinutes = timeProvider.getWeeklyTotal();
        final goal = settingsProvider.settings.weeklyGoalMinutes;
        final last7Days = timeProvider.getLast7DaysData();
        final categoryStats = timeProvider.getCategoryStats(
          start: weekStart,
          end: weekEnd,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Özet kart
              _SummaryCard(
                title: 'Bu Hafta',
                subtitle:
                    '${Helpers.formatShortDate(weekStart)} - ${Helpers.formatShortDate(weekEnd)}',
                totalMinutes: totalMinutes,
                goalMinutes: goal,
              ),

              const SizedBox(height: 24),

              // Haftalık grafik
              const Text(
                'Son 7 Gün',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _WeeklyBarChart(data: last7Days),

              const SizedBox(height: 24),

              // Kategori dağılımı
              if (categoryStats.isNotEmpty) ...[
                const Text(
                  'Kategori Dağılımı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _CategoryPieChart(stats: categoryStats),
                const SizedBox(height: 16),
                _CategoryList(stats: categoryStats),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Aylık İstatistikler
class _MonthlyStats extends StatelessWidget {
  const _MonthlyStats();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeProvider>(
      builder: (context, timeProvider, child) {
        final now = DateTime.now();
        final monthStart = Helpers.getMonthStart(now);
        final monthEnd = Helpers.getMonthEnd(now);
        final totalMinutes = timeProvider.getMonthlyTotal();
        final categoryStats = timeProvider.getCategoryStats(
          start: monthStart,
          end: monthEnd,
        );

        // Günlük ortalama hesapla
        final daysPassed = now.day;
        final dailyAverage = daysPassed > 0 ? totalMinutes ~/ daysPassed : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Özet kart
              _SummaryCard(
                title: Helpers.getMonthName(now.month),
                subtitle: '${now.year}',
                totalMinutes: totalMinutes,
              ),

              const SizedBox(height: 16),

              // Günlük ortalama
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.show_chart, color: AppTheme.accentColor),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Günlük Ortalama',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            Helpers.formatMinutes(dailyAverage),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kategori dağılımı
              if (categoryStats.isNotEmpty) ...[
                const Text(
                  'Kategori Dağılımı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _CategoryPieChart(stats: categoryStats),
                const SizedBox(height: 16),
                _CategoryList(stats: categoryStats),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Yıllık İstatistikler
class _YearlyStats extends StatelessWidget {
  const _YearlyStats();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeProvider>(
      builder: (context, timeProvider, child) {
        final now = DateTime.now();
        final yearStart = Helpers.getYearStart(now);
        final yearEnd = Helpers.getYearEnd(now);
        final totalMinutes = timeProvider.getYearlyTotal();
        final categoryStats = timeProvider.getCategoryStats(
          start: yearStart,
          end: yearEnd,
        );

        // Aylık ortalama hesapla
        final monthsPassed = now.month;
        final monthlyAverage = monthsPassed > 0 ? totalMinutes ~/ monthsPassed : 0;

        // Haftalık ortalama hesapla
        final dayOfYear = now.difference(yearStart).inDays + 1;
        final weeksPassed = (dayOfYear / 7).ceil();
        final weeklyAverage = weeksPassed > 0 ? totalMinutes ~/ weeksPassed : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Özet kart
              _SummaryCard(
                title: '${now.year}',
                subtitle: 'Yıllık Özet',
                totalMinutes: totalMinutes,
              ),

              const SizedBox(height: 16),

              // Ortalamalar
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haftalık Ort.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatMinutes(weeklyAverage),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aylık Ort.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatMinutes(monthlyAverage),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Kategori dağılımı
              if (categoryStats.isNotEmpty) ...[
                const Text(
                  'Kategori Dağılımı',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _CategoryPieChart(stats: categoryStats),
                const SizedBox(height: 16),
                _CategoryList(stats: categoryStats),
              ],
            ],
          ),
        );
      },
    );
  }
}

// Özet Kartı
class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalMinutes;
  final int? goalMinutes;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.totalMinutes,
    this.goalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isOverGoal = goalMinutes != null && totalMinutes > goalMinutes!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isOverGoal ? AppTheme.dangerColor : AppTheme.primaryColor)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOverGoal ? Icons.warning : Icons.access_time,
                    color: isOverGoal ? AppTheme.dangerColor : AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              Helpers.formatMinutes(totalMinutes),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isOverGoal ? AppTheme.dangerColor : null,
              ),
            ),
            if (goalMinutes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (totalMinutes / goalMinutes!).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverGoal ? AppTheme.dangerColor : AppTheme.successColor,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOverGoal
                    ? 'Hedefi ${Helpers.formatMinutes(totalMinutes - goalMinutes!)} aştın!'
                    : 'Hedef: ${Helpers.formatMinutes(goalMinutes!)}',
                style: TextStyle(
                  color: isOverGoal ? AppTheme.dangerColor : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Haftalık Bar Chart
class _WeeklyBarChart extends StatelessWidget {
  final List<int> data;

  const _WeeklyBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxValue > 0 ? maxValue.toDouble() : 60.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: normalizedMax * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      Helpers.formatMinutes(data[group.x.toInt()]),
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final day = DateTime.now()
                          .subtract(Duration(days: 6 - value.toInt()));
                      return Text(
                        Helpers.getWeekdayName(day.weekday),
                        style: const TextStyle(fontSize: 12),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('');
                      return Text(
                        '${value.toInt()}dk',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: List.generate(7, (index) {
                final value = data[index].toDouble();
                final isToday = index == 6;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      color: isToday
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withValues(alpha: 0.5),
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// Kategori Pie Chart
class _CategoryPieChart extends StatelessWidget {
  final Map<String, int> stats;

  const _CategoryPieChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox();

    final sections = stats.entries.map((entry) {
      final category = DatabaseService.categories.get(entry.key);
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        color: category?.color ?? Colors.grey,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// Kategori Listesi
class _CategoryList extends StatelessWidget {
  final Map<String, int> stats;

  const _CategoryList({required this.stats});

  @override
  Widget build(BuildContext context) {
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = stats.values.fold(0, (a, b) => a + b);

    return Column(
      children: sortedEntries.map((entry) {
        final category = DatabaseService.categories.get(entry.key);
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (category?.color ?? Colors.grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category?.iconData ?? Icons.access_time,
                color: category?.color ?? Colors.grey,
              ),
            ),
            title: Text(category?.name ?? 'Bilinmeyen'),
            subtitle: Text('${percentage.toStringAsFixed(1)}%'),
            trailing: Text(
              Helpers.formatMinutes(entry.value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: category?.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
