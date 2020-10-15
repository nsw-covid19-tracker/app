import 'package:collection/collection.dart';
import 'package:nsw_covid_tracker/home/repo/models/models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepo {
  static final _rootRef = FirebaseDatabase.instance.reference();
  final _locationsRef = _rootRef.child('locations');
  final _casesRef = _rootRef.child('cases');
  final _logsRef = _rootRef.child('logs');
  final _locationsKey = 'locationsUpdatedAt';
  final _casesKey = 'casesUpdatedAt';
  final _disclaimerKey = 'disclaimer';

  Future<List<Location>> fetchLocations() async {
    final isKeepSynced = await _getIsKeepSynced(_locationsKey);
    if (isKeepSynced) await _locationsRef.keepSynced(true);
    final snapshot = await _locationsRef.once();
    final queue = PriorityQueue<Location>(
      (Location a, Location b) => a.suburb.compareTo(b.suburb),
    );

    if (snapshot.value != null) {
      for (MapEntry entry in snapshot.value.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        data['postcode'] = entry.key;
        queue.add(Location.fromJson(data));
      }
    }

    return queue.toList();
  }

  Future<List<Case>> fetchCases() async {
    final isKeepSynced = await _getIsKeepSynced(_casesKey);
    if (isKeepSynced) await _casesRef.keepSynced(true);
    await _casesRef.keepSynced(true);
    final snapshot = await _casesRef.once();
    final queue = PriorityQueue<Case>(
      (Case a, Case b) => a.venue.compareTo(b.venue),
    );

    if (snapshot.value != null) {
      for (MapEntry entry in snapshot.value.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        queue.add(Case.fromJson(data));
      }
    }

    return queue.toList();
  }

  Future<bool> getIsShowDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(_disclaimerKey) ?? true;

    return result;
  }

  Future<void> setIsShowDisclaimer(bool value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerKey, value);
  }

  Future<bool> _getIsKeepSynced(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final epoch = prefs.getInt(key);
    DateTime localUpdatedAt, serverUpdatedAt;

    if (epoch != null) {
      localUpdatedAt = DateTime.fromMillisecondsSinceEpoch(epoch);
      final query = _logsRef.child(key);
      await query.keepSynced(true);
      final snapshot = await query.once();

      if (snapshot.value != null) {
        serverUpdatedAt =
            DateTime.fromMillisecondsSinceEpoch(snapshot.value, isUtc: true);
      }
    }

    final result = localUpdatedAt == null ||
        (serverUpdatedAt != null && localUpdatedAt.isBefore(serverUpdatedAt));
    if (result) await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);

    return result;
  }
}
