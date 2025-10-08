// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pattern_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatternModelAdapter extends TypeAdapter<PatternModel> {
  @override
  final int typeId = 0;

  @override
  PatternModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatternModel(
      id: fields[0] as String,
      originalFileName: fields[1] as String,
      customName: fields[2] as String,
      localFilePath: fields[3] as String,
      dateAdded: fields[4] as String,
      isFavourite: fields[5] as String,
      userNotes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PatternModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalFileName)
      ..writeByte(2)
      ..write(obj.customName)
      ..writeByte(3)
      ..write(obj.localFilePath)
      ..writeByte(4)
      ..write(obj.dateAdded)
      ..writeByte(5)
      ..write(obj.isFavourite)
      ..writeByte(6)
      ..write(obj.userNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
