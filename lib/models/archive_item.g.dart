// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArchiveItemAdapter extends TypeAdapter<ArchiveItem> {
  @override
  final int typeId = 0;

  @override
  ArchiveItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArchiveItem(
      date: fields[0] as String,
      concern: fields[1] as String,
      decision: fields[2] as String,
      severity: fields[3] as int,
      todoTasks: (fields[7] as List).cast<String>(),
      timeline: (fields[8] as List)
          .map((dynamic e) => (e as Map).cast<String, String>())
          .toList(),
      isSolved: fields[4] as bool,
      comments: (fields[5] as List?)?.cast<String>(),
      todoStatus: (fields[6] as List?)?.cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, ArchiveItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.concern)
      ..writeByte(2)
      ..write(obj.decision)
      ..writeByte(3)
      ..write(obj.severity)
      ..writeByte(4)
      ..write(obj.isSolved)
      ..writeByte(5)
      ..write(obj.comments)
      ..writeByte(6)
      ..write(obj.todoStatus)
      ..writeByte(7)
      ..write(obj.todoTasks)
      ..writeByte(8)
      ..write(obj.timeline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArchiveItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
