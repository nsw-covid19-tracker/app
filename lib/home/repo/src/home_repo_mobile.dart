import 'package:firebase_auth/firebase_auth.dart';
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
  Future<DateTime?> fetchDataUpdatedAt() async {
    DateTime? updatedAt;
    final query = _rootRef.child('$logsKey/$dataUpdatedAtKey');
    final snapshot = await query.once();

    if (snapshot.value != null) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(
        snapshot.value,
        isUtc: true,
      );
    }

    return updatedAt;
  }

  @override
  Future<int> fetchLogValue(String key) async {
    final query = _rootRef.child('$logsKey/$key');
    final snapshot = await query.once();

    return snapshot.value;
  }

  @override
  Future<List<T>> fetchFromServer<T>(String key, ParseFunc<T> parseFunc) async {
    final query = _rootRef.child(key);
    final snapshot = await query.once();
    final results = parseFunc(snapshot.value);
    await cacheListResults(key, results);

    return results;
  }
}
