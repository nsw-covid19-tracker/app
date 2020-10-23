import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nsw_covid_tracker/home/repo/models/models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nsw_covid_tracker/home/repo/src/home_repo.dart';

HomeRepo getHomeRepo() => HomeRepoMobile();

class HomeRepoMobile extends HomeRepo {
  static final _rootRef = FirebaseDatabase.instance.reference();
  final _auth = FirebaseAuth.instance;

  @override
  Future<void> signInAnonymously() async {
    final user = _auth.currentUser;
    if (user == null) await _auth.signInAnonymously();
  }

  @override
  Future<DateTime> fetchDataUpdatedAt() async {
    DateTime updatedAt;
    final query = _rootRef.child('$logsKey/$dataUpdatedAtKey');
    await query.keepSynced(true);
    final snapshot = await query.once();

    if (snapshot.value != null) {
      updatedAt =
          DateTime.fromMillisecondsSinceEpoch(snapshot.value, isUtc: true);
    }

    return updatedAt;
  }

  @override
  Future<List<Suburb>> fetchSuburbs() async {
    final query = _rootRef.child(suburbsKey);
    final isKeepSynced = await shouldFetchFromServer(suburbsUpdatedAtKey);
    if (isKeepSynced) await query.keepSynced(true);
    final snapshot = await query.once();
    final queue = PriorityQueue<Suburb>(
      (Suburb a, Suburb b) => a.name.compareTo(b.name),
    );

    if (snapshot.value != null) {
      for (MapEntry entry in snapshot.value.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        queue.add(Suburb.fromJson(data));
      }
    }

    return queue.toList();
  }

  @override
  Future<List<Case>> fetchCases() async {
    final query = _rootRef.child(casesKey);
    final isKeepSynced = await shouldFetchFromServer(casesUpdatedAtKey);
    if (isKeepSynced) await query.keepSynced(true);
    final snapshot = await query.once();
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

  @override
  Future<int> fetchLogValue(String key) async {
    final query = _rootRef.child('$logsKey/$key');
    await query.keepSynced(true);
    final snapshot = await query.once();

    return snapshot.value;
  }
}
