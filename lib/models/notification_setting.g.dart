// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_setting.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingAdapter extends TypeAdapter<NotificationSetting> {
  @override
  final int typeId = 2;

  @override
  NotificationSetting read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSetting(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      thresholdMinutes: fields[2] as int,
      isEnabled: fields[3] as bool,
      message: fields[4] as String,
      isUrgent: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSetting obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.thresholdMinutes)
      ..writeByte(3)
      ..write(obj.isEnabled)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.isUrgent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      dailyReminderEnabled: fields[1] as bool,
      dailyReminderHour: fields[2] as int,
      dailyReminderMinute: fields[3] as int,
      weeklyReportEnabled: fields[4] as bool,
      weeklyGoalMinutes: fields[5] as int,
      motivationQuotesEnabled: fields[6] as bool,
      dailyGoalMinutes: fields[7] as int? ?? 120,
      monthlyGoalMinutes: fields[8] as int? ?? 2400,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.dailyReminderEnabled)
      ..writeByte(2)
      ..write(obj.dailyReminderHour)
      ..writeByte(3)
      ..write(obj.dailyReminderMinute)
      ..writeByte(4)
      ..write(obj.weeklyReportEnabled)
      ..writeByte(5)
      ..write(obj.weeklyGoalMinutes)
      ..writeByte(6)
      ..write(obj.motivationQuotesEnabled)
      ..writeByte(7)
      ..write(obj.dailyGoalMinutes)
      ..writeByte(8)
      ..write(obj.monthlyGoalMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
