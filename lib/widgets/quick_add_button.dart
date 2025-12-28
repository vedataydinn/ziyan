import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';
import '../services/database_service.dart';

class QuickAddButtons extends StatelessWidget {
  const QuickAddButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = DatabaseService.categories.values.toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _QuickAddItem(
            name: category.name,
            icon: category.iconData,
            color: category.color,
            onTap: () => _showQuickAddDialog(context, category.id, category.name),
          );
        },
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context, String categoryId, String categoryName) {
    int selectedMinutes = 15;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Süre seçimi
              const Text(
                'Ne kadar süre?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15, 30, 45, 60, 90, 120].map((minutes) {
                  final isSelected = selectedMinutes == minutes;
                  return ChoiceChip(
                    label: Text(_formatQuickMinutes(minutes)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedMinutes = minutes;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Özel süre
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Özel süre (dakika)',
                        hintText: 'Örn: 25',
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          setState(() {
                            selectedMinutes = parsed;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Açıklama
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (isteğe bağlı)',
                  hintText: 'Ne yaptın?',
                ),
              ),

              const SizedBox(height: 24),

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<TimeProvider>().addManualEntry(
                          categoryId: categoryId,
                          description: descriptionController.text,
                          durationMinutes: selectedMinutes,
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_formatQuickMinutes(selectedMinutes)} $categoryName kaydedildi',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text('${_formatQuickMinutes(selectedMinutes)} Ekle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuickMinutes(int minutes) {
    if (minutes < 60) return '${minutes}dk';
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    if (mins == 0) return '${hours}s';
    return '${hours}s ${mins}dk';
  }
}

class _QuickAddItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
