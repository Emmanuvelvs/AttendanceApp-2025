import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {

  static Future<void> saveAuthToken(String token) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token );
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Get token
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    return prefs.containsKey('user_id'); // Returns true if user_id exists
  }

  
static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Remove token
    await prefs.remove('user_id'); // Remove user ID
  }
}