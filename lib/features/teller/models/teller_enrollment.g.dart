// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teller_enrollment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TellerEnrollment _$TellerEnrollmentFromJson(Map<String, dynamic> json) =>
    _TellerEnrollment(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      profileId: json['profile_id'] as String,
      tellerEnrollmentId: json['teller_enrollment_id'] as String,
      institutionName: json['institution_name'] as String,
      accountName: json['account_name'] as String,
      accountLastFour: json['account_last_four'] as String?,
      accountType: json['account_type'] as String,
      accountSubtype: json['account_subtype'] as String?,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TellerEnrollmentToJson(_TellerEnrollment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'org_id': instance.orgId,
      'profile_id': instance.profileId,
      'teller_enrollment_id': instance.tellerEnrollmentId,
      'institution_name': instance.institutionName,
      'account_name': instance.accountName,
      'account_last_four': instance.accountLastFour,
      'account_type': instance.accountType,
      'account_subtype': instance.accountSubtype,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
