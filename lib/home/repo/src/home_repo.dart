import 'package:collection/collection.dart';
import 'package:covid_tracing/home/repo/models/models.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeRepo {
  static final _rootRef = FirebaseDatabase.instance.reference();
  final _locationsRef = _rootRef.child('locations');
  final _casesRef = _rootRef.child('cases');

  Future<List<Location>> fetchLocations() async {
    final snapshot = await _locationsRef.once();
    final locations = <Location>[];

    for (MapEntry entry in snapshot.value.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      data['postcode'] = entry.key;
      locations.add(Location.fromJson(data));
    }

    return locations;
  }

  Future<List<Case>> fetchCases() async {
    final snapshot = await _casesRef.once();
    final queue = PriorityQueue<Case>(
      (Case a, Case b) => a.location.compareTo(b.location),
    );

    for (MapEntry entry in snapshot.value.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      queue.add(Case.fromJson(data));
    }

    return queue.toList();
  }
}
