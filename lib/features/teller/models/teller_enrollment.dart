// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'teller_enrollment.freezed.dart';
part 'teller_enrollment.g.dart';

@freezed
abstract class TellerEnrollment with _$TellerEnrollment {
  const factory TellerEnrollment({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'teller_enrollment_id') required String tellerEnrollmentId,
    @JsonKey(name: 'institution_name') required String institutionName,
    @JsonKey(name: 'account_name') required String accountName,
    @JsonKey(name: 'account_last_four') String? accountLastFour,
    @JsonKey(name: 'account_type') required String accountType,
    @JsonKey(name: 'account_subtype') String? accountSubtype,
    @JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TellerEnrollment;

  factory TellerEnrollment.fromJson(Map<String, dynamic> json) =>
      _$TellerEnrollmentFromJson(json);
}
