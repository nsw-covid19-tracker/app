import 'package:json_annotation/json_annotation.dart';

part 'case.g.dart';

@JsonSerializable()
class Case {
  final String postcode;
  final String suburb;
  final double latitude;
  final double longitude;
  final String location;
  final String dates;
  final String action;
  final bool isExpired;

  Case(this.postcode, this.suburb, this.latitude, this.longitude, this.location,
      this.dates, this.action, this.isExpired);

  factory Case.fromJson(Map<String, dynamic> json) => _$CaseFromJson(json);
  Map<String, dynamic> toJson() => _$CaseToJson(this);
}
