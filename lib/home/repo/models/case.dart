import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
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
  final List<dynamic> dateTimes;
  final String action;
  final bool isExpired;

  Case(this.postcode, this.suburb, this.latitude, this.longitude, this.venue,
      this.dateTimes, this.action, this.isExpired);

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
      dateTimes,
      action,
      isExpired,
    ];
  }

  LatLng get latLng => LatLng(latitude, longitude);

  String get formattedDateTimes {
    var result = '';
    final queue = PriorityQueue<Map<String, DateTime>>(
      (a, b) => a['end'].compareTo(b['end']),
    );

    for (final dateTime in dateTimes) {
      final start = DateTime.parse(dateTime['start']);
      final end = DateTime.parse(dateTime['end']);
      queue.add({'start': start, 'end': end});
    }

    for (final dateTime in queue.toList()) {
      if (dateTime['start'] != dateTime['end']) {
        final formattedStart =
            DateFormat('E d MMM, y h:mma').format(dateTime['start']);
        final formattedEnd = DateFormat('h:mma').format(dateTime['end']);
        result += '- $formattedStart to $formattedEnd\n';
      } else {
        final formattedDate =
            DateFormat('E d MMM, y').format(dateTime['start']);
        result += '- $formattedDate\n';
      }
    }

    return result.trim();
  }
}
