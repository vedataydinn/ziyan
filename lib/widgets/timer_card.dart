import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';

class TimerCard extends StatelessWidget {
  const TimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeProvider>(
      builder: (context, timeProvider, child) {
        final isRunning = timeProvider.isTimerRunning;
        final entry = timeProvider.currentActiveEntry;
        final seconds = timeProvider.elapsedSeconds;

        if (!isRunning) {
          return Card(
            child: InkWell(
              onTap: () => _showStartTimerDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 48,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ziyanı Başlat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zamanını takip etmeye başla',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Aktif timer
        final category = DatabaseService.categories.get(entry?.category ?? '');
        final minutes = seconds ~/ 60;
        final isWarning = minutes >= (category?.warningMinutes ?? 60);

        return Card(
          color: isWarning ? AppTheme.dangerColor.withValues(alpha: 0.1) : null,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Kategori bilgisi
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category?.iconData ?? Icons.access_time,
                      color: isWarning
                          ? AppTheme.dangerColor
                          : Color(category?.colorValue ?? Colors.grey.value),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category?.name ?? 'Bilinmeyen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isWarning ? AppTheme.dangerColor : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (entry?.description.isNotEmpty ?? false)
                  Text(
                    entry!.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),

                const SizedBox(height: 24),

                // Sayaç
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isWarning
                        ? AppTheme.dangerColor.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isWarning
                          ? AppTheme.dangerColor
                          : AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    Helpers.formatSeconds(seconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: isWarning ? AppTheme.dangerColor : null,
                    ),
                  ),
                ),

                if (isWarning) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.dangerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Uyarı limitini aştın!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Butonlar - Durdur ve Durdur+Kaydet
                Row(
                  children: [
                    // Sadece Durdur (kaydetmeden)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCancelDialog(context, timeProvider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text(
                          'Durdur',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Durdur ve Kaydet
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => timeProvider.stopTimer(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.save_rounded, size: 20),
                        label: const Text(
                          'Durdur ve Kaydet',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, TimeProvider timeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sayacı İptal Et'),
        content: const Text(
          'Sayaç durdurulacak ve bu süre kaydedilmeyecek. Emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              timeProvider.cancelTimer();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sayaç iptal edildi, kayıt yapılmadı'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );
  }

  void _showStartTimerDialog(BuildContext context) {
    final wasteCategories = DatabaseService.categories.values.where((c) => !c.isProductive).toList();
    final productiveCategories = DatabaseService.categories.values.where((c) => c.isProductive).toList();
    String? selectedCategory;
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ziyanı Başlat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Ziyan Kategorileri
                Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Ziyan Kategorileri',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: wasteCategories.map((category) {
                    final isSelected = selectedCategory == category.id;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.iconData,
                            size: 18,
                            color: isSelected ? Colors.white : category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(category.name),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category.id : null;
                        });
                      },
                      selectedColor: category.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Verimli Kategoriler
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green.shade400, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Verimli Kategoriler (Telafi)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade400),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: productiveCategories.map((category) {
                    final isSelected = selectedCategory == category.id;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.iconData,
                            size: 18,
                            color: isSelected ? Colors.white : category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(category.name),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category.id : null;
                        });
                      },
                      selectedColor: category.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Açıklama
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama (isteğe bağlı)',
                    hintText: 'Ne yapıyorsun?',
                  ),
                ),

                const SizedBox(height: 24),

                // Başlat butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedCategory == null
                        ? null
                        : () {
                            context.read<TimeProvider>().startTimer(
                                  selectedCategory!,
                                  descriptionController.text,
                                );
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Başlat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
