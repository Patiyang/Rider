import 'package:shared_preferences/shared_preferences.dart';

// Future<bool> saveIntroBool(bool checkOnboarding) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setBool('checkOnboarding', checkOnboarding);
//   return checkOnboarding;
// }


  Future<bool> getIsOnline() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') == null) {
      await prefs.setBool('isLoggedIn', false);
    }
    return prefs.getBool('isLoggedIn');
  }

  Future setIsOnline(bool isFirstTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', isFirstTime);
  }