import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal local "auth" (no backend yet). Accounts are stored in
/// SharedPreferences as { email: {name, password} }.
/// Replace the internals with real FastAPI calls later; the method
/// names can stay the same so the screens don't change.
class AuthStore {
  static const _usersKey = 'registered_users';
  static const _sessionKey = 'user_email';

  static Future<Map<String, Map<String, String>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final result = <String, Map<String, String>>{};
    decoded.forEach((email, value) {
      if (value is String) {
        // Older format stored only the password; fall back to the email prefix as name.
        result[email] = {'name': email.split('@').first, 'password': value};
      } else if (value is Map) {
        result[email] = {
          'name': (value['name'] ?? '').toString(),
          'password': (value['password'] ?? '').toString(),
        };
      }
    });
    return result;
  }

  static Future<void> _saveUsers(Map<String, Map<String, String>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  /// Returns null on success, or an error message.
  static Future<String?> register(
    String name,
    String email,
    String password,
  ) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      return 'Please fill in all fields.';
    }
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (users.containsKey(key)) {
      return 'An account with this email already exists — try logging in.';
    }
    users[key] = {'name': name.trim(), 'password': password};
    await _saveUsers(users);
    return null;
  }

  /// Returns null on success, or an error message.
  static Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return 'Please enter both email and password.';
    }
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (!users.containsKey(key)) {
      return 'No account found for this email. Please sign up first.';
    }
    if (users[key]!['password'] != password) {
      return 'Incorrect password.';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, key);
    return null;
  }

  static Future<String?> currentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  static Future<String?> currentUserName() async {
    final email = await currentUserEmail();
    if (email == null) return null;
    final users = await _loadUsers();
    final name = users[email]?['name'];
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Returns null on success, or an error message.
  static Future<String?> updateName(String newName) async {
    if (newName.trim().isEmpty) return 'Name can\'t be empty.';
    final email = await currentUserEmail();
    if (email == null) return 'You are not signed in.';
    final users = await _loadUsers();
    if (!users.containsKey(email)) return 'Account not found.';
    users[email]!['name'] = newName.trim();
    await _saveUsers(users);
    return null;
  }

  /// Returns null on success, or an error message.
  static Future<String?> changePassword(String current, String next) async {
    final email = await currentUserEmail();
    if (email == null) return 'You are not signed in.';
    final users = await _loadUsers();
    if (!users.containsKey(email)) return 'Account not found.';
    if (users[email]!['password'] != current)
      return 'Current password is incorrect.';
    if (next.length < 6) return 'New password must be at least 6 characters.';
    users[email]!['password'] = next;
    await _saveUsers(users);
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
