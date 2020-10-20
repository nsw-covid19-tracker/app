import 'package:collection/collection.dart';
import 'package:nsw_covid_tracker/home/repo/models/models.dart';
import 'package:nsw_covid_tracker/home/repo/src/home_repo.dart';
import 'package:firebase/firebase.dart' as fb;

HomeRepo getHomeRepo() => HomeRepoWeb();

class HomeRepoWeb extends HomeRepo {
  final _auth = fb.auth();
  final _db = fb.database();

  @override
  Future<void> signInAnonymously() async {
    final user = _auth.currentUser;
    if (user == null) await _auth.signInAnonymously();
  }

  @override
  Future<List<Location>> fetchLocations() async {
    final event = await _db.ref('locations').once('value');
    final value = event.snapshot.val();
    final queue = PriorityQueue<Location>(
      (Location a, Location b) => a.suburb.compareTo(b.suburb),
    );

    if (value != null) {
      for (MapEntry entry in value.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        data['postcode'] = entry.key;
        queue.add(Location.fromJson(data));
      }
    }

    return queue.toList();
  }

  @override
  Future<List<Case>> fetchCases() async {
    final event = await _db.ref('cases').once('value');
    final value = event.snapshot.val();
    final queue = PriorityQueue<Case>(
      (Case a, Case b) => a.venue.compareTo(b.venue),
    );

    if (value != null) {
      for (MapEntry entry in value.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        queue.add(Case.fromJson(data));
      }
    }

    return queue.toList();
  }
}