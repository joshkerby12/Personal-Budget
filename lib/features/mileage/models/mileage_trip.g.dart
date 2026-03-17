// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mileage_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MileageTrip _$MileageTripFromJson(Map<String, dynamic> json) => _MileageTrip(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  createdBy: json['created_by'] as String,
  date: DateTime.parse(json['date'] as String),
  purpose: json['purpose'] as String,
  fromAddress: json['from_address'] as String,
  toAddress: json['to_address'] as String,
  oneWayMiles: (json['one_way_miles'] as num).toDouble(),
  isRoundTrip: json['is_round_trip'] as bool,
  bizPct: (json['biz_pct'] as num).toDouble(),
  category: json['category'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MileageTripToJson(_MileageTrip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'created_by': instance.createdBy,
      'date': instance.date.toIso8601String(),
      'purpose': instance.purpose,
      'from_address': instance.fromAddress,
      'to_address': instance.toAddress,
      'one_way_miles': instance.oneWayMiles,
      'is_round_trip': instance.isRoundTrip,
      'biz_pct': instance.bizPct,
      'category': instance.category,
      'created_at': instance.createdAt.toIso8601String(),
    };
