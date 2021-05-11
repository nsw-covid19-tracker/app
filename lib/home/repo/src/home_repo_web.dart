import 'package:nsw_covid_tracker/home/repo/src/home_repo.dart';
import 'package:firebase/firebase.dart' as fb;

typedef ParseFunc = List Function(Map json);
typedef MapFunc = dynamic Function(String string);

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
  Future<DateTime?> fetchDataUpdatedAt() async {
    DateTime? updatedAt;
    final event = await _db.ref('$logsKey/$dataUpdatedAtKey').once('value');
    final value = event.snapshot.val();

    if (value != null) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }

    return updatedAt;
  }

  @override
  Future<int> fetchLogValue(String key) async {
    final event = await _db.ref('$logsKey/$key').once('value');

    return event.snapshot.val();
  }

  @override
  Future<List<T>> fetchFromServer<T>(String key, parseFunc) async {
    final event = await _db.ref(key).once('value');
    final results = parseFunc(event.snapshot.val());
    await cacheListResults(key, results);

    return results;
  }
}
