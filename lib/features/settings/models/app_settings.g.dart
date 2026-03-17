// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  id: json['id'] as String,
  orgId: json['org_id'] as String,
  irsRatePerMile: (json['irs_rate_per_mile'] as num).toDouble(),
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'irs_rate_per_mile': instance.irsRatePerMile,
    };
