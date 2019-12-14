// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceralation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Acceralation _$AcceralationFromJson(Map<String, dynamic> json) {
  return Acceralation((json['x'] as num)?.toDouble(),
      (json['y'] as num)?.toDouble(), (json['z'] as num)?.toDouble());
}

Map<String, dynamic> _$AcceralationToJson(Acceralation instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y, 'z': instance.z};