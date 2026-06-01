// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_banner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromoBannerAdapter extends TypeAdapter<PromoBanner> {
  @override
  final int typeId = 8;

  @override
  PromoBanner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromoBanner(
      id: fields[0] as String,
      imageUrl: fields[1] as String,
      title: fields[2] as String,
      tag: fields[3] as String,
      btnText: fields[4] as String,
      colorHex: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PromoBanner obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.tag)
      ..writeByte(4)
      ..write(obj.btnText)
      ..writeByte(5)
      ..write(obj.colorHex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromoBannerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
