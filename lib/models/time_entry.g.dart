// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeEntryAdapter extends TypeAdapter<TimeEntry> {
  @override
  final int typeId = 0;

  @override
  TimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeEntry(
      id: fields[0] as String,
      category: fields[1] as String,
      description: fields[2] as String,
      durationMinutes: fields[3] as int,
      dateTime: fields[4] as DateTime,
      isActive: fields[5] as bool,
      startTime: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TimeEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.dateTime)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.startTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
