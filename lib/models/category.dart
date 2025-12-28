import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class ZiyanCategory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int warningMinutes; // Bu süreyi aşınca uyar

  @HiveField(5)
  bool isDefault;

  @HiveField(6)
  bool isProductive; // Verimli kategori mi (telafi için)

  ZiyanCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.warningMinutes = 60,
    this.isDefault = false,
    this.isProductive = false, // Varsayılan olarak ziyan kategorisi
  });

  Color get color => Color(colorValue);

  IconData get iconData {
    switch (icon) {
      // Ziyan ikonları
      case 'phone':
        return Icons.phone_android;
      case 'games':
        return Icons.sports_esports;
      case 'tv':
        return Icons.tv;
      case 'social':
        return Icons.people;
      case 'youtube':
        return Icons.play_circle_filled;
      case 'shopping':
        return Icons.shopping_cart;
      case 'chat':
        return Icons.chat;
      case 'music':
        return Icons.music_note;
      case 'other':
        return Icons.more_horiz;
      // Verimli/Telafi ikonları
      case 'book':
        return Icons.menu_book;
      case 'exercise':
        return Icons.fitness_center;
      case 'meditation':
        return Icons.self_improvement;
      case 'study':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'walk':
        return Icons.directions_walk;
      case 'code':
        return Icons.code;
      case 'art':
        return Icons.brush;
      case 'language':
        return Icons.translate;
      default:
        return Icons.access_time;
    }
  }

  static List<ZiyanCategory> getDefaultCategories() {
    return [
      ZiyanCategory(
        id: 'social_media',
        name: 'Sosyal Medya',
        icon: 'social',
        colorValue: Colors.blue.value,
        warningMinutes: 60,
        isDefault: true,
      ),
      ZiyanCategory(
        id: 'games',
        name: 'Oyunlar',
        icon: 'games',
        colorValue: Colors.purple.value,
        warningMinutes: 90,
        isDefault: true,
      ),
      ZiyanCategory(
        id: 'youtube',
        name: 'YouTube',
        icon: 'youtube',
        colorValue: Colors.red.value,
        warningMinutes: 60,
        isDefault: true,
      ),
      ZiyanCategory(
        id: 'tv',
        name: 'TV / Dizi / Film',
        icon: 'tv',
        colorValue: Colors.orange.value,
        warningMinutes: 120,
        isDefault: true,
      ),
      ZiyanCategory(
        id: 'chat',
        name: 'Mesajlaşma',
        icon: 'chat',
        colorValue: Colors.green.value,
        warningMinutes: 45,
        isDefault: true,
      ),
      ZiyanCategory(
        id: 'shopping',
        name: 'Online Alışveriş',
        icon: 'shopping',
        colorValue: Colors.teal.value,
        warningMinutes: 30,
        isDefault: true,
      ),
      ZiyanCategory(
        id: 'other',
        name: 'Diğer',
        icon: 'other',
        colorValue: Colors.grey.value,
        warningMinutes: 60,
        isDefault: true,
      ),
    ];
  }

  // Varsayılan verimli kategoriler (telafi için) - 3 adet
  static List<ZiyanCategory> getDefaultProductiveCategories() {
    return [
      ZiyanCategory(
        id: 'reading',
        name: 'Kitap Okuma',
        icon: 'book',
        colorValue: Colors.indigo.value,
        warningMinutes: 0, // Verimli için limit yok
        isDefault: true,
        isProductive: true,
      ),
      ZiyanCategory(
        id: 'exercise',
        name: 'Egzersiz',
        icon: 'exercise',
        colorValue: Colors.green.value,
        warningMinutes: 0,
        isDefault: true,
        isProductive: true,
      ),
      ZiyanCategory(
        id: 'study',
        name: 'Ders Çalışma',
        icon: 'study',
        colorValue: Colors.blue.value,
        warningMinutes: 0,
        isDefault: true,
        isProductive: true,
      ),
    ];
  }
}
