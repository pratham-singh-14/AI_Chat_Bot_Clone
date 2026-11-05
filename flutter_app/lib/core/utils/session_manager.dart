import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _clientIdKey = 'client_id_key';
  static const String _baseUrlKey = 'custom_base_url_key';

  static Future<String?> getClientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clientIdKey);
  }

  static Future<void> saveClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, clientId);
  }

  static Future<String?> getSavedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey);
  }

  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }
}
