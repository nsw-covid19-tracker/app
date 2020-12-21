import 'package:collection/collection.dart';
import 'package:nsw_covid_tracker/home/repo/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsw_covid_tracker/home/repo/src/home_repo_stub.dart'
    if (dart.library.io) 'package:nsw_covid_tracker/home/repo/src/home_repo_mobile.dart'
    if (dart.library.html) 'package:nsw_covid_tracker/home/repo/src/home_repo_web.dart';

typedef ParseFunc = List Function(Map json);
typedef MapFunc = dynamic Function(String string);

abstract class HomeRepo {
  static HomeRepo _instance;

  static HomeRepo get instance {
    _instance ??= getHomeRepo();
    return _instance;
  }

  final suburbsKey = 'suburbs';
  final casesKey = 'cases';
  final logsKey = 'logs';
  final dataUpdatedAtKey = 'dataUpdatedAt';
  final suburbsUpdatedAtKey = 'suburbsUpdatedAt';
  final casesUpdatedAtKey = 'casesUpdatedAt';
  final _disclaimerKey = 'disclaimer';

  Future<void> signInAnonymously();

  Future<DateTime> fetchDataUpdatedAt();

  Future<int> fetchLogValue(String key);

  Future<List> fetchFromServer(String key, ParseFunc parseFunc);

  Future<bool> shouldFetchFromServer(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final epoch = prefs.getInt(key);
    DateTime localUpdatedAt, serverUpdatedAt;

    if (epoch != null) {
      localUpdatedAt = DateTime.fromMillisecondsSinceEpoch(epoch);
      final value = await fetchLogValue(key);

      if (value != null) {
        serverUpdatedAt =
            DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
    }

    final result = localUpdatedAt == null ||
        (serverUpdatedAt != null && localUpdatedAt.isBefore(serverUpdatedAt));
    if (result) await prefs.setInt(key, DateTime.now().millisecondsSinceEpoch);

    return result;
  }

  Future<List<Suburb>> fetchSuburbs() async {
    final shouldFetch = await shouldFetchFromServer(suburbsUpdatedAtKey);
    var suburbs = <Suburb>[];

    if (shouldFetch) {
      suburbs = await fetchFromServer(suburbsKey, parseSuburbs);
    } else {
      final mapFunc = (String string) => Suburb.fromString(string);
      suburbs = await fetchFromCache<Suburb>(suburbsKey, parseSuburbs, mapFunc);
      ;
    }

    return suburbs;
  }

  Future<List<Case>> fetchCases() async {
    final shouldFetch = await shouldFetchFromServer(casesUpdatedAtKey);
    var cases = <Case>[];

    if (shouldFetch) {
      cases = await fetchFromServer(casesKey, parseCases);
    } else {
      final mapFunc = (String string) => Case.fromString(string);
      cases = await fetchFromCache<Case>(casesKey, parseCases, mapFunc);
      ;
    }

    return cases;
  }

  Future<List<T>> fetchFromCache<T>(
    String key,
    ParseFunc parseFunc,
    MapFunc mapFunc,
  ) async {
    var results = <T>[];
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(key);

    if (stringList != null) {
      results = stringList.map<T>((e) => mapFunc(e)).toList();
    } else {
      results = await fetchFromServer(key, parseFunc);
    }

    return results;
  }

  Future<void> cacheListResults(String key, List results) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = results.map((e) => e.toString()).toList();
    await prefs.setStringList(key, stringList);
  }

  List<Suburb> parseSuburbs(Map json) {
    final queue = PriorityQueue<Suburb>(
      (Suburb a, Suburb b) => a.name.compareTo(b.name),
    );

    if (json != null) {
      for (final value in json.values) {
        final data = Map<String, dynamic>.from(value);
        queue.add(Suburb.fromJson(data));
      }
    }

    return queue.toList();
  }

  List<Case> parseCases(Map json) {
    final queue = PriorityQueue<Case>(
      (Case a, Case b) => a.venue.compareTo(b.venue),
    );

    if (json != null) {
      for (final value in json.values) {
        final data = Map<String, dynamic>.from(value);
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
}
