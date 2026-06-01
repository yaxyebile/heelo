// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StoreAdapter extends TypeAdapter<Store> {
  @override
  final int typeId = 2;

  @override
  Store read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Store(
      id: fields[0] as String,
      name: fields[1] as String,
      logo: fields[2] as String,
      banner: fields[3] as String,
      description: fields[4] as String,
      contact: fields[5] as String,
      rating: fields[6] as double,
      followers: fields[7] as int,
      isApproved: fields[8] as bool,
      ownerId: fields[9] as String,
      hasDelivery: fields[10] as bool,
      evcNumber: fields[11] as String?,
      edahabNumber: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Store obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.logo)
      ..writeByte(3)
      ..write(obj.banner)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.contact)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.followers)
      ..writeByte(8)
      ..write(obj.isApproved)
      ..writeByte(9)
      ..write(obj.ownerId)
      ..writeByte(10)
      ..write(obj.hasDelivery)
      ..writeByte(11)
      ..write(obj.evcNumber)
      ..writeByte(12)
      ..write(obj.edahabNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
