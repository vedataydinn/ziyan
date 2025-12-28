import 'package:flutter/material.dart';
import '../utils/motivation_quotes.dart';
import '../services/database_service.dart';
import '../models/custom_quote.dart';

class QuotesManagementScreen extends StatefulWidget {
  const QuotesManagementScreen({super.key});

  @override
  State<QuotesManagementScreen> createState() => _QuotesManagementScreenState();
}

class _QuotesManagementScreenState extends State<QuotesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Devre dışı bırakılan sözleri al
  Set<String> get _disabledQuotes {
    final disabled = DatabaseService.generalSettings.get('disabled_quotes');
    if (disabled == null) return {};
    return Set<String>.from(disabled as List);
  }

  // Sözü devre dışı bırak/etkinleştir
  void _toggleQuote(String quote, bool enabled) {
    final disabled = _disabledQuotes;
    if (enabled) {
      disabled.remove(quote);
    } else {
      disabled.add(quote);
    }
    DatabaseService.generalSettings.put('disabled_quotes', disabled.toList());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivasyon Sözleri'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Varsayılan Sözler'),
            Tab(text: 'Kendi Sözlerim'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDefaultQuotesTab(),
          _buildCustomQuotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddQuoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Varsayılan sözler (silinebilir = devre dışı bırakılabilir)
  Widget _buildDefaultQuotesTab() {
    final quotes = MotivationQuotes.quotes;
    final disabledQuotes = _disabledQuotes;
    final enabledCount = quotes.where((q) => !disabledQuotes.contains(q)).length;

    return Column(
      children: [
        // Üst bilgi
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Görmek istemediğin sözleri kapat. $enabledCount/${quotes.length} aktif',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              if (disabledQuotes.isNotEmpty)
                TextButton(
                  onPressed: () {
                    DatabaseService.generalSettings.put('disabled_quotes', []);
                    setState(() {});
                  },
                  child: const Text('Tümünü Aç', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              final isEnabled = !disabledQuotes.contains(quote);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? Theme.of(context).cardColor
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEnabled
                        ? Colors.grey.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Icon(
                    Icons.format_quote,
                    size: 20,
                    color: isEnabled ? Colors.blue[400] : Colors.grey[400],
                  ),
                  title: Text(
                    quote,
                    style: TextStyle(
                      fontSize: 14,
                      color: isEnabled ? Colors.grey[700] : Colors.grey[400],
                      height: 1.4,
                      decoration: isEnabled ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  trailing: Switch(
                    value: isEnabled,
                    onChanged: (value) => _toggleQuote(quote, value),
                    activeColor: Colors.green,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Kullanıcının kendi sözleri
  Widget _buildCustomQuotesTab() {
    final customQuotes = DatabaseService.customQuotes.values.toList();

    if (customQuotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kendi sözün yok',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sağ alttaki + butonuna basarak ekle',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customQuotes.length,
      itemBuilder: (context, index) {
        final quote = customQuotes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.edit_note,
                size: 20,
                color: Colors.blue[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quote.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Düzenle butonu
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: Colors.grey[400]),
                onPressed: () => _showEditQuoteDialog(quote),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              // Sil butonu
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[300]),
                onPressed: () => _showDeleteQuoteDialog(quote),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        );
      },
    );
  }

  // Yeni söz ekleme
  void _showAddQuoteDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Söz Ekle'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Motivasyon sözünü yaz...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final quote = CustomQuote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: controller.text.trim(),
                  createdAt: DateTime.now(),
                );
                DatabaseService.customQuotes.put(quote.id, quote);
                setState(() {});
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Söz eklendi')),
                );
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  // Söz düzenleme
  void _showEditQuoteDialog(CustomQuote quote) {
    final controller = TextEditingController(text: quote.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sözü Düzenle'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Motivasyon sözünü yaz...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final updatedQuote = CustomQuote(
                  id: quote.id,
                  text: controller.text.trim(),
                  createdAt: quote.createdAt,
                );
                DatabaseService.customQuotes.put(quote.id, updatedQuote);
                setState(() {});
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Söz güncellendi')),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  // Söz silme
  void _showDeleteQuoteDialog(CustomQuote quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sözü Sil'),
        content: const Text('Bu sözü silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              DatabaseService.customQuotes.delete(quote.id);
              setState(() {});
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Söz silindi')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
