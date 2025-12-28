import 'package:hive/hive.dart';

part 'custom_quote.g.dart';

@HiveType(typeId: 5)
class CustomQuote extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime createdAt;

  CustomQuote({
    required this.id,
    required this.text,
    required this.createdAt,
  });
}

@HiveType(typeId: 6)
class AppLock extends HiveObject {
  @HiveField(0)
  String? pin; // 4 haneli PIN

  @HiveField(1)
  bool isEnabled;

  @HiveField(2)
  bool lockOnTimeExceed; // Süre aşımında kilitle

  AppLock({
    this.pin,
    this.isEnabled = false,
    this.lockOnTimeExceed = true,
  });
}
