// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'mileage_trip.freezed.dart';
part 'mileage_trip.g.dart';

@freezed
abstract class MileageTrip with _$MileageTrip {
  const factory MileageTrip({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'created_by') required String createdBy,
    required DateTime date,
    required String purpose,
    @JsonKey(name: 'from_address') required String fromAddress,
    @JsonKey(name: 'to_address') required String toAddress,
    @JsonKey(name: 'one_way_miles') required double oneWayMiles,
    @JsonKey(name: 'is_round_trip') required bool isRoundTrip,
    @JsonKey(name: 'biz_pct') required double bizPct,
    required String category,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MileageTrip;

  factory MileageTrip.fromJson(Map<String, dynamic> json) =>
      _$MileageTripFromJson(json);
}
