import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'case.g.dart';

@JsonSerializable()
class Case extends Equatable {
  final String postcode;
  final String suburb;
  final double latitude;
  final double longitude;
  final String venue;
  final String address;
  final String action;
  final bool isExpired;

  @JsonKey(
    fromJson: _Converters.jsonToDateTimeRange,
    toJson: _Converters.dateTimeRangeToJson,
  )
  final List<DateTimeRange> dateTimes;

  Case(this.postcode, this.suburb, this.latitude, this.longitude, this.venue,
      this.address, this.dateTimes, this.action, this.isExpired);

  factory Case.fromJson(Map<String, dynamic> json) => _$CaseFromJson(json);
  Map<String, dynamic> toJson() => _$CaseToJson(this);

  @override
  List<Object> get props {
    return [
      postcode,
      suburb,
      latitude,
      longitude,
      venue,
      address,
      dateTimes,
      action,
      isExpired,
    ];
  }

  LatLng get latLng => LatLng(latitude, longitude);

  String get formattedDateTimes {
    var result = '';
    for (final dateTime in dateTimes) {
      if (dateTime.start != dateTime.end) {
        final formattedStart =
            DateFormat('E d MMM, y h:mma').format(dateTime.start);
        final formattedEnd = DateFormat('h:mma').format(dateTime.end);
        result += '- $formattedStart to $formattedEnd\n';
      } else {
        final formattedDate = DateFormat('E d MMM, y').format(dateTime.end);
        result += '- $formattedDate\n';
      }
    }

    return result.trim();
  }
}

class _Converters {
  static List<DateTimeRange> jsonToDateTimeRange(List<dynamic> dateTimes) {
    return dateTimes
        .map(
          (e) => DateTimeRange(
            start: DateTime.parse(e['start']),
            end: DateTime.parse(e['end']),
          ),
        )
        .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
  }

  static List<dynamic> dateTimeRangeToJson(List<DateTimeRange> dateTimes) {
    return dateTimes
        .map(
          (e) => {
            'start': e.start.toIso8601String(),
            'end': e.end.toIso8601String(),
          },
        )
        .toList();
  }
}
