import 'package:nsw_covid_tracker/home/repo/models/models.dart';
import 'package:nsw_covid_tracker/home/repo/src/home_repo.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<DateTime> fetchDataUpdatedAt() async {
    DateTime updatedAt;
    final event = await _db.ref('$logsKey/$dataUpdatedAtKey').once('value');
    final value = event.snapshot.val();

    if (value != null) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }

    return updatedAt;
  }

  @override
  Future<List<Suburb>> fetchSuburbs() async {
    final shouldFetch = await shouldFetchFromServer(suburbsUpdatedAtKey);
    var suburbs = <Suburb>[];

    if (shouldFetch) {
      suburbs = await _fetchFromServer(suburbsKey, parseSuburbs);
    } else {
      final mapFunc = (String string) => Suburb.fromString(string);
      suburbs = await _fetchFromCache(suburbsKey, parseSuburbs, mapFunc);
    }

    return suburbs;
  }

  @override
  Future<List<Case>> fetchCases() async {
    final shouldFetch = await shouldFetchFromServer(casesUpdatedAtKey);
    var cases = <Case>[];

    if (shouldFetch) {
      cases = await _fetchFromServer(casesKey, parseCases);
    } else {
      final mapFunc = (String string) => Case.fromString(string);
      cases = await _fetchFromCache(casesKey, parseCases, mapFunc);
    }

    return cases;
  }

  @override
  Future<int> fetchLogValue(String key) async {
    final event = await _db.ref('$logsKey/$key').once('value');

    return event.snapshot.val();
  }

  Future<List> _fetchFromServer(String key, ParseFunc parseFunc) async {
    final event = await _db.ref(key).once('value');
    final results = parseFunc(event.snapshot.val());

    final prefs = await SharedPreferences.getInstance();
    final stringList = results.map((e) => e.toString()).toList();
    await prefs.setStringList(key, stringList);

    return results;
  }

  Future<List> _fetchFromCache(
      String key, ParseFunc parseFunc, MapFunc mapFunc) async {
    var results = [];
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(key);

    if (stringList != null) {
      results = stringList.map((e) => mapFunc(e)).toList();
    } else {
      results = await _fetchFromServer(key, parseFunc);
    }

    return results;
  }
}
