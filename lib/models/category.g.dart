// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZiyanCategoryAdapter extends TypeAdapter<ZiyanCategory> {
  @override
  final int typeId = 1;

  @override
  ZiyanCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZiyanCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      colorValue: fields[3] as int,
      warningMinutes: fields[4] as int,
      isDefault: fields[5] as bool,
      isProductive: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ZiyanCategory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.warningMinutes)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.isProductive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZiyanCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
