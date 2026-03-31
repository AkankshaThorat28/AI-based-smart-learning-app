import 'package:shared_preferences/shared_preferences.dart';

/// Stores the currently logged-in user's session in SharedPreferences
/// so it survives app restarts.
class AuthService {
  static const _keyId         = 'user_id';
  static const _keyName       = 'user_name';
  static const _keyEmail      = 'user_email';
  static const _keyRole       = 'user_role';
  static const _keyDisability = 'user_disability';

  // ── Save session after login / register ──────────────────────────────────
  static Future<void> saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt   (_keyId,         user['id']         as int);
    await prefs.setString(_keyName,       user['name']       as String);
    await prefs.setString(_keyEmail,      user['email']      as String);
    await prefs.setString(_keyRole,       user['role']       as String);
    await prefs.setString(_keyDisability, user['disability'] as String);
  }

  // ── Read session ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyId);
    if (id == null) return null;
    return {
      'id':         id,
      'name':       prefs.getString(_keyName)       ?? 'User',
      'email':      prefs.getString(_keyEmail)      ?? '',
      'role':       prefs.getString(_keyRole)       ?? 'student',
      'disability': prefs.getString(_keyDisability) ?? 'none',
    };
  }

  // ── Convenience getters (sync after prefs loaded) ─────────────────────────
  static Future<int>    getUserId()         async => (await getSession())?['id']         ?? 0;
  static Future<String> getUserName()       async => (await getSession())?['name']       ?? 'User';
  static Future<String> getUserEmail()      async => (await getSession())?['email']      ?? '';
  static Future<String> getUserRole()       async => (await getSession())?['role']       ?? 'student';
  static Future<String> getUserDisability() async {
    final raw = (await getSession())?['disability'] ?? 'none';
    return raw.toString().split('|').first;
  }
  
  static Future<String> getUserBoard() async {
    final raw = (await getSession())?['disability'] ?? 'none|CBSE';
    final parts = raw.toString().split('|');
    if (parts.length > 1) return parts[1];
    return 'CBSE';
  }

  // ── Check if logged in ───────────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyId) != null;
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyDisability);
  }
}
