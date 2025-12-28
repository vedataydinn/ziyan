import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'providers/time_provider.dart';
import 'providers/settings_provider.dart';
import 'utils/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatı için
  await initializeDateFormatting('tr_TR', null);

  // Veritabanını başlat
  await DatabaseService.init();

  // Bildirimleri başlat
  await NotificationService.init();

  runApp(const ZiyanApp());
}

class ZiyanApp extends StatelessWidget {
  const ZiyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Ziyan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.settings.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(child: MainScreen()),
          );
        },
      ),
    );
  }
}
