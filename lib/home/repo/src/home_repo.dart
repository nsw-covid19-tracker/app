import 'package:collection/collection.dart';
import 'package:covid_tracing/home/repo/models/models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepo {
  static final _rootRef = FirebaseDatabase.instance.reference();
  final _locationsRef = _rootRef.child('locations');
  final _casesRef = _rootRef.child('cases');
  final _disclaimerKey = 'disclaimer';

  Future<List<Location>> fetchLocations() async {
    final snapshot = await _locationsRef.once();
    final queue = PriorityQueue<Location>(
      (Location a, Location b) => a.suburb.compareTo(b.suburb),
    );

    for (MapEntry entry in snapshot.value.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      data['postcode'] = entry.key;
      queue.add(Location.fromJson(data));
    }

    return queue.toList();
  }

  Future<List<Case>> fetchCases() async {
    await _casesRef.keepSynced(true);
    final snapshot = await _casesRef.once();
    final queue = PriorityQueue<Case>(
      (Case a, Case b) => a.venue.compareTo(b.venue),
    );

    for (MapEntry entry in snapshot.value.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      queue.add(Case.fromJson(data));
    }

    return queue.toList();
  }

  Future<bool> getIsShowDisclaimer() async {
    var prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(_disclaimerKey) ?? true;

    return result;
  }

  Future<void> setIsShowDisclaimer(bool value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerKey, value);
  }
}
