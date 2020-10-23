import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suburb.g.dart';

@JsonSerializable()
class Suburb extends Equatable {
  final String postcode;
  final String name;
  final double latitude;
  final double longitude;

  Suburb(this.postcode, this.name, this.latitude, this.longitude);

  factory Suburb.fromJson(Map<String, dynamic> json) => _$SuburbFromJson(json);
  Map<String, dynamic> toJson() => _$SuburbToJson(this);

  factory Suburb.fromString(String string) {
    return Suburb.fromJson(jsonDecode(string));
  }

  @override
  String toString() => jsonEncode(toJson());

  @override
  List<Object> get props => [postcode, name, latitude, longitude];

  String get displayName => '$name ($postcode)';

  LatLng get latLng => LatLng(latitude, longitude);
}
