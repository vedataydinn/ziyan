import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_provider.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';

class RecentEntriesList extends StatelessWidget {
  const RecentEntriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeProvider>(
      builder: (context, timeProvider, child) {
        final entries = timeProvider.getEntriesForDate(DateTime.now());

        if (entries.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz kayıt yok',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sayacı başlat veya hızlı ekle',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: entries.take(5).map((entry) {
            final category = DatabaseService.categories.get(entry.category);
            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Kaydı Sil'),
                    content: const Text('Bu kaydı silmek istediğinizden emin misiniz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.dangerColor,
                        ),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                timeProvider.deleteEntry(entry.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kayıt silindi'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Card(
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
                  title: Text(
                    category?.name ?? 'Silinmiş Kategori',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: category == null ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  subtitle: entry.description.isNotEmpty
                      ? Text(
                          entry.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          Helpers.formatTime(entry.dateTime),
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (category?.color ?? Colors.grey).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      entry.formattedDuration,
                      style: TextStyle(
                        color: category?.color ?? Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
