import 'package:hive/hive.dart';

part 'time_entry.g.dart';

@HiveType(typeId: 0)
class TimeEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  String description;

  @HiveField(3)
  int durationMinutes;

  @HiveField(4)
  DateTime dateTime;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime? startTime;

  TimeEntry({
    required this.id,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.dateTime,
    this.isActive = false,
    this.startTime,
  });

  // Toplam süreyi saat ve dakika olarak formatlı göster
  String get formattedDuration {
    int hours = durationMinutes ~/ 60;
    int minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    }
    return '${minutes}dk';
  }

  // Kopyalama metodu
  TimeEntry copyWith({
    String? id,
    String? category,
    String? description,
    int? durationMinutes,
    DateTime? dateTime,
    bool? isActive,
    DateTime? startTime,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
      startTime: startTime ?? this.startTime,
    );
  }
}
