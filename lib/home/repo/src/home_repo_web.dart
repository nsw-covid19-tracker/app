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
  Future<DateTime> getDataUpdatedAt() async {
    DateTime updatedAt;
    final event = await _db.ref('logs/dataUpdatedAt').once('value');
    final value = event.snapshot.val();

    if (value != null) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }

    return updatedAt;
  }

  @override
  Future<List<Suburb>> fetchSuburbs() async {
    final event = await _db.ref('suburbs').once('value');
    final value = event.snapshot.val();
    final queue = PriorityQueue<Suburb>(
      (Suburb a, Suburb b) => a.name.compareTo(b.name),
    );

    if (value != null) {
      for (MapEntry entry in value.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        queue.add(Suburb.fromJson(data));
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
