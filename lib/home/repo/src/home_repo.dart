import 'package:nsw_covid_tracker/home/repo/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsw_covid_tracker/home/repo/src/home_repo_stub.dart'
    if (dart.library.io) 'package:nsw_covid_tracker/home/repo/src/home_repo_mobile.dart'
    if (dart.library.html) 'package:nsw_covid_tracker/home/repo/src/home_repo_web.dart';

abstract class HomeRepo {
  static HomeRepo _instance;

  static HomeRepo get instance {
    _instance ??= getHomeRepo();
    return _instance;
  }

  final _disclaimerKey = 'disclaimer';

  Future<void> signInAnonymously();

  Future<DateTime> getDataUpdatedAt();

  Future<List<Suburb>> fetchSuburbs();

  Future<List<Case>> fetchCases();

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
