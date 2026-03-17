// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    required String id,
    @JsonKey(name: 'org_id') required String orgId,
    @JsonKey(name: 'irs_rate_per_mile') required double irsRatePerMile,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
