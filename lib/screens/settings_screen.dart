import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/time_provider.dart';
import '../models/notification_setting.dart';
import '../models/category.dart';
import '../models/custom_quote.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';
import 'achievements_screen.dart';
import 'quotes_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final settings = settingsProvider.settings;
          final appLock = DatabaseService.appLock.get('lock');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Görünüm ayarları
              _SectionTitle(title: 'Görünüm'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Karanlık Tema'),
                      subtitle: const Text('Koyu renk teması kullan'),
                      value: settings.isDarkMode,
                      onChanged: (value) => settingsProvider.toggleDarkMode(),
                      secondary: Icon(
                        settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Motivasyon Sözleri'),
                      subtitle: const Text('Ana sayfada motivasyon sözleri göster'),
                      value: settings.motivationQuotesEnabled,
                      onChanged: (value) => settingsProvider.updateSettings(
                        motivationQuotesEnabled: value,
                      ),
                      secondary: const Icon(Icons.format_quote),
                    ),
                    ListTile(
                      leading: const SizedBox(width: 24),
                      title: const Text('Sözleri Yönet'),
                      subtitle: const Text('Varsayılan sözleri gör, kendi sözlerini ekle'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuotesManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Kilit Sistemi
              _SectionTitle(title: 'Kilit Sistemi'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('PIN Kilidi'),
                      subtitle: Text(appLock?.isEnabled == true
                          ? 'Süre aşımında PIN sor'
                          : 'PIN kilidi kapalı'),
                      value: appLock?.isEnabled ?? false,
                      onChanged: (value) {
                        if (value) {
                          _showSetPinDialog(context);
                        } else {
                          _disableLock(context);
                        }
                      },
                      secondary: Icon(
                        appLock?.isEnabled == true ? Icons.lock : Icons.lock_open,
                        color: appLock?.isEnabled == true ? AppTheme.primaryColor : null,
                      ),
                    ),
                    if (appLock?.isEnabled == true)
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('PIN Değiştir'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showChangePinDialog(context),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Hedef ayarları
              _SectionTitle(title: 'Ziyan Hedefleri'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.today, color: Colors.orange),
                      title: const Text('Günlük Hedef'),
                      subtitle: Text('Max ${Helpers.formatMinutes(settings.dailyGoalMinutes)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showGoalDialog(
                        context,
                        settingsProvider,
                        'Günlük Hedef',
                        settings.dailyGoalMinutes,
                        (value) => settingsProvider.updateSettings(dailyGoalMinutes: value),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.view_week, color: Colors.blue),
                      title: const Text('Haftalık Hedef'),
                      subtitle: Text('Max ${Helpers.formatMinutes(settings.weeklyGoalMinutes)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showGoalDialog(
                        context,
                        settingsProvider,
                        'Haftalık Hedef',
                        settings.weeklyGoalMinutes,
                        (value) => settingsProvider.updateSettings(weeklyGoalMinutes: value),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.calendar_month, color: Colors.purple),
                      title: const Text('Aylık Hedef'),
                      subtitle: Text('Max ${Helpers.formatMinutes(settings.monthlyGoalMinutes)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showGoalDialog(
                        context,
                        settingsProvider,
                        'Aylık Hedef',
                        settings.monthlyGoalMinutes,
                        (value) => settingsProvider.updateSettings(monthlyGoalMinutes: value),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Ziyan Kategorileri
              _SectionTitle(title: 'Ziyan Kategorileri'),
              Card(
                child: Column(
                  children: [
                    ...settingsProvider.wasteCategories.map((category) {
                      return ListTile(
                        leading: Icon(
                          category.iconData,
                          color: category.color,
                        ),
                        title: Text(category.name),
                        subtitle: Text(
                          'Uyarı: ${Helpers.formatMinutes(category.warningMinutes)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showCategoryWarningDialog(
                                context,
                                settingsProvider,
                                category.id,
                                category.name,
                                category.warningMinutes,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppTheme.dangerColor,
                              onPressed: () => _showDeleteCategoryDialog(context, settingsProvider, category.id, category.name),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: AppTheme.dangerColor),
                      title: const Text('Ziyan Kategorisi Ekle'),
                      onTap: () => _showAddCategoryDialog(context, settingsProvider, isProductive: false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Verimli Kategorileri (Telafi)
              _SectionTitle(title: 'Verimli Kategoriler (Telafi)'),
              Card(
                child: Column(
                  children: [
                    ...settingsProvider.productiveCategories.map((category) {
                      return ListTile(
                        leading: Icon(
                          category.iconData,
                          color: category.color,
                        ),
                        title: Text(category.name),
                        subtitle: const Text('Telafi kategorisi'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AppTheme.dangerColor,
                          onPressed: () => _showDeleteCategoryDialog(context, settingsProvider, category.id, category.name),
                        ),
                      );
                    }),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                      title: const Text('Verimli Kategori Ekle'),
                      onTap: () => _showAddCategoryDialog(context, settingsProvider, isProductive: true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Motivasyon Sözleri
              _SectionTitle(title: 'Motivasyon Sözlerim'),
              Card(
                child: Column(
                  children: [
                    ...DatabaseService.customQuotes.values.map((quote) {
                      return ListTile(
                        leading: const Icon(Icons.format_quote),
                        title: Text(
                          quote.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AppTheme.dangerColor,
                          onPressed: () => _deleteQuote(context, quote.id),
                        ),
                      );
                    }),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                      title: const Text('Motivasyon Sözü Ekle'),
                      onTap: () => _showAddQuoteDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bildirim ayarları
              _SectionTitle(title: 'Bildirimler'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Günlük Hatırlatma'),
                      subtitle: Text(
                        'Saat ${settings.dailyReminderHour.toString().padLeft(2, '0')}:${settings.dailyReminderMinute.toString().padLeft(2, '0')}',
                      ),
                      value: settings.dailyReminderEnabled,
                      onChanged: (value) => settingsProvider.updateSettings(
                        dailyReminderEnabled: value,
                      ),
                      secondary: const Icon(Icons.notifications),
                    ),
                    if (settings.dailyReminderEnabled)
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('Hatırlatma Saati'),
                        trailing: TextButton(
                          onPressed: () => _showTimePickerDialog(context, settingsProvider),
                          child: Text(
                            '${settings.dailyReminderHour.toString().padLeft(2, '0')}:${settings.dailyReminderMinute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Haftalık Rapor'),
                      subtitle: const Text('Her Pazar günü özet bildirim'),
                      value: settings.weeklyReportEnabled,
                      onChanged: (value) => settingsProvider.updateSettings(
                        weeklyReportEnabled: value,
                      ),
                      secondary: const Icon(Icons.summarize),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.add_alert),
                      title: const Text('Özel Bildirim Ekle'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAddNotificationDialog(context, settingsProvider),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Başarılar
              _SectionTitle(title: 'Başarılar'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.emoji_events, color: Colors.amber),
                  title: const Text('Başarılarım'),
                  subtitle: Text(
                    '${settingsProvider.unlockedAchievements.length}/${settingsProvider.achievements.length} başarı',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Mevcut bildirim ayarları listesi
              if (settingsProvider.notificationSettings.isNotEmpty) ...[
                _SectionTitle(title: 'Aktif Bildirim Kuralları'),
                Card(
                  child: Column(
                    children: settingsProvider.notificationSettings.map((setting) {
                      final category = DatabaseService.categories.get(setting.categoryId);
                      return ListTile(
                        leading: Icon(
                          setting.isUrgent ? Icons.warning : Icons.notifications,
                          color: setting.isUrgent ? AppTheme.dangerColor : null,
                        ),
                        title: Text(category?.name ?? 'Bilinmeyen'),
                        subtitle: Text(
                          '${Helpers.formatMinutes(setting.thresholdMinutes)} sonra${setting.isUrgent ? ' (Acil)' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: setting.isEnabled,
                              onChanged: (value) {
                                settingsProvider.toggleNotificationSetting(setting.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppTheme.dangerColor,
                              onPressed: () {
                                settingsProvider.deleteNotificationSetting(setting.id);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Veri Yönetimi
              _SectionTitle(title: 'Veri Yönetimi'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh, color: Colors.orange),
                      title: const Text('Bugünü Sıfırla'),
                      subtitle: const Text('Bugünkü tüm ziyan ve telafi kayıtlarını sil'),
                      onTap: () => _showResetTodayDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Tüm Verileri Sil'),
                      subtitle: const Text('Tüm kayıtları kalıcı olarak sil'),
                      onTap: () => _showResetAllDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  // Bugünü Sıfırla Dialog
  void _showResetTodayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Bugünü Sıfırla'),
          ],
        ),
        content: const Text('Bugünkü tüm ziyan ve telafi kayıtları silinecek. Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              context.read<TimeProvider>().clearTodayEntries();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bugünkü kayıtlar sıfırlandı')),
              );
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  // Tüm Verileri Sil Dialog
  void _showResetAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Tüm Verileri Sil'),
          ],
        ),
        content: const Text('TÜM ziyan ve telafi kayıtları kalıcı olarak silinecek. Bu işlem GERİ ALINAMAZ!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TimeProvider>().clearAllEntries();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm kayıtlar silindi')),
              );
            },
            child: const Text('Tümünü Sil'),
          ),
        ],
      ),
    );
  }

  // PIN Ayarlama
  void _showSetPinDialog(BuildContext context) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN Belirle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Süre aşımında sorulacak 4 haneli PIN belirle'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN',
                hintText: '4 haneli PIN',
              ),
            ),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'PIN Tekrar',
                hintText: 'PIN\'i tekrar gir',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN 4 haneli olmalı')),
                );
                return;
              }
              if (pinController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN\'ler eşleşmiyor')),
                );
                return;
              }
              final lock = DatabaseService.appLock.get('lock');
              if (lock != null) {
                lock.pin = pinController.text;
                lock.isEnabled = true;
                lock.save();
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN ayarlandı')),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context) {
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PIN Değiştir'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mevcut PIN',
              ),
            ),
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni PIN',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final lock = DatabaseService.appLock.get('lock');
              if (lock?.pin != oldPinController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mevcut PIN yanlış')),
                );
                return;
              }
              if (newPinController.text.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN 4 haneli olmalı')),
                );
                return;
              }
              lock?.pin = newPinController.text;
              lock?.save();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN değiştirildi')),
              );
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _disableLock(BuildContext context) {
    final lock = DatabaseService.appLock.get('lock');
    lock?.isEnabled = false;
    lock?.save();
  }

  // Kategori Ekleme
  void _showAddCategoryDialog(BuildContext context, SettingsProvider provider, {bool isProductive = false}) {
    final nameController = TextEditingController();
    String selectedIcon = isProductive ? 'book' : 'other';
    int selectedColor = isProductive ? Colors.green.value : Colors.blue.value;
    int warningMinutes = 60;

    final wasteIcons = ['phone', 'games', 'tv', 'social', 'youtube', 'shopping', 'chat', 'music', 'other'];
    final productiveIcons = ['book', 'exercise', 'meditation', 'study', 'work', 'walk', 'code', 'art', 'language'];
    final icons = isProductive ? productiveIcons : wasteIcons;
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.cyan];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isProductive ? 'Yeni Verimli Kategori' : 'Yeni Ziyan Kategorisi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Adı',
                    hintText: 'Örn: Instagram',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('İkon'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Color(selectedColor).withValues(alpha: 0.2) : null,
                          border: Border.all(
                            color: isSelected ? Color(selectedColor) : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconData(icon),
                          color: isSelected ? Color(selectedColor) : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Renk'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) {
                    final isSelected = selectedColor == color.value;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color.value),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (!isProductive) ...[
                  const SizedBox(height: 16),
                  const Text('Uyarı Süresi'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [30, 60, 90, 120].map((m) {
                      return ChoiceChip(
                        label: Text(Helpers.formatMinutes(m)),
                        selected: warningMinutes == m,
                        onSelected: (selected) {
                          setState(() => warningMinutes = m);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: nameController.text.isEmpty
                  ? null
                  : () {
                      final category = ZiyanCategory(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        icon: selectedIcon,
                        colorValue: selectedColor,
                        warningMinutes: isProductive ? 0 : warningMinutes,
                        isDefault: false,
                        isProductive: isProductive,
                      );
                      provider.addCategory(category);
                      Navigator.pop(context);
                    },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'phone': return Icons.phone_android;
      case 'games': return Icons.sports_esports;
      case 'tv': return Icons.tv;
      case 'social': return Icons.people;
      case 'youtube': return Icons.play_circle_filled;
      case 'shopping': return Icons.shopping_cart;
      case 'chat': return Icons.chat;
      case 'music': return Icons.music_note;
      default: return Icons.more_horiz;
    }
  }

  void _deleteCategory(BuildContext context, SettingsProvider provider, String id) {
    provider.deleteCategory(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori silindi')),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, SettingsProvider provider, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kategori Sil'),
        content: Text('"$name" kategorisini silmek istediğine emin misin?\n\nBu kategoriye ait kayıtlar silinmeyecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            onPressed: () {
              provider.deleteCategory(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$name" kategorisi silindi')),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // Motivasyon Sözü Ekleme
  void _showAddQuoteDialog(BuildContext context) {
    final quoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motivasyon Sözü Ekle'),
        content: TextField(
          controller: quoteController,
          decoration: const InputDecoration(
            labelText: 'Motivasyon Sözü',
            hintText: 'Kendi motivasyon sözünü yaz...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (quoteController.text.isNotEmpty) {
                final quote = CustomQuote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: quoteController.text,
                  createdAt: DateTime.now(),
                );
                DatabaseService.customQuotes.put(quote.id, quote);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Motivasyon sözü eklendi')),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _deleteQuote(BuildContext context, String id) {
    DatabaseService.customQuotes.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Motivasyon sözü silindi')),
    );
  }

  // Genel hedef dialog
  void _showGoalDialog(
    BuildContext context,
    SettingsProvider provider,
    String title,
    int currentMinutes,
    Function(int) onSave,
  ) {
    int hours = currentMinutes ~/ 60;
    int minutes = currentMinutes % 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Maksimum ne kadar ziyan edebilirsin?'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text('Saat'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: hours > 0 ? () => setState(() => hours--) : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            hours.toString(),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => setState(() => hours++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      const Text('Dakika'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: minutes >= 15 ? () => setState(() => minutes -= 15) : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            minutes.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: minutes < 45 ? () => setState(() => minutes += 15) : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                onSave(hours * 60 + minutes);
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeeklyGoalDialog(BuildContext context, SettingsProvider provider) {
    int hours = provider.settings.weeklyGoalMinutes ~/ 60;
    int minutes = provider.settings.weeklyGoalMinutes % 60;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Haftalık Hedef'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Haftalık maksimum ziyan hedefini belirle'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text('Saat'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: hours > 0 ? () => setState(() => hours--) : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            hours.toString(),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => setState(() => hours++),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      const Text('Dakika'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            onPressed: minutes >= 15 ? () => setState(() => minutes -= 15) : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            minutes.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: minutes < 45 ? () => setState(() => minutes += 15) : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                provider.updateSettings(weeklyGoalMinutes: hours * 60 + minutes);
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context, SettingsProvider provider) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: provider.settings.dailyReminderHour,
        minute: provider.settings.dailyReminderMinute,
      ),
    );
    if (time != null) {
      provider.updateSettings(dailyReminderHour: time.hour, dailyReminderMinute: time.minute);
    }
  }

  void _showCategoryWarningDialog(BuildContext context, SettingsProvider provider, String categoryId, String categoryName, int currentMinutes) {
    int minutes = currentMinutes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('$categoryName Uyarısı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Kaç dakika sonra uyarı gelsin?'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [15, 30, 45, 60, 90, 120].map((m) {
                  return ChoiceChip(
                    label: Text(Helpers.formatMinutes(m)),
                    selected: minutes == m,
                    onSelected: (selected) => setState(() => minutes = m),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: () {
                provider.updateCategoryWarningMinutes(categoryId, minutes);
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNotificationDialog(BuildContext context, SettingsProvider provider) {
    String? selectedCategoryId;
    int thresholdMinutes = 60;
    bool isUrgent = false;
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Özel Bildirim Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategori'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  items: provider.categories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.iconData, color: c.color, size: 20),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCategoryId = value),
                  decoration: const InputDecoration(hintText: 'Kategori seç'),
                ),
                const SizedBox(height: 16),
                const Text('Ne zaman uyar?'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [30, 60, 90, 120, 180].map((m) {
                    return ChoiceChip(
                      label: Text(Helpers.formatMinutes(m)),
                      selected: thresholdMinutes == m,
                      onSelected: (selected) => setState(() => thresholdMinutes = m),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Özel mesaj (isteğe bağlı)',
                    hintText: 'Bildirimin göstereceği mesaj',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Acil Bildirim'),
                  subtitle: const Text('Kırmızı uyarı bildirimi'),
                  value: isUrgent,
                  onChanged: (value) => setState(() => isUrgent = value),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
            ElevatedButton(
              onPressed: selectedCategoryId == null
                  ? null
                  : () {
                      final setting = NotificationSetting(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        categoryId: selectedCategoryId!,
                        thresholdMinutes: thresholdMinutes,
                        message: messageController.text,
                        isUrgent: isUrgent,
                      );
                      provider.saveNotificationSetting(setting);
                      Navigator.pop(context);
                    },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600]),
      ),
    );
  }
}
