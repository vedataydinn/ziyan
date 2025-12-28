// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomQuoteAdapter extends TypeAdapter<CustomQuote> {
  @override
  final int typeId = 5;

  @override
  CustomQuote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomQuote(
      id: fields[0] as String,
      text: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomQuote obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomQuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppLockAdapter extends TypeAdapter<AppLock> {
  @override
  final int typeId = 6;

  @override
  AppLock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppLock(
      pin: fields[0] as String?,
      isEnabled: fields[1] as bool,
      lockOnTimeExceed: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppLock obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pin)
      ..writeByte(1)
      ..write(obj.isEnabled)
      ..writeByte(2)
      ..write(obj.lockOnTimeExceed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppLockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
