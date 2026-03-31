import 'dart:convert';
import 'package:http/http.dart' as http;

/// Central API client.
/// Change [baseUrl] to match your backend's address:
///   - Android emulator → http://10.0.2.2:8000
///   - Physical device on same WiFi → http://<YOUR_PC_LAN_IP>:8000
///   - Web (Chrome, desktop) → http://localhost:8000
class ApiService {
  // ── Change this one line to switch environments ──────────────────────────
  static const String baseUrl = 'http://192.168.31.53:8000';
  // ─────────────────────────────────────────────────────────────────────────

  static const Duration _timeout = Duration(seconds: 15);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── Health check ─────────────────────────────────────────────────────────
  static Future<bool> isBackendAlive() async {
    try {
      final res = await http.get(Uri.parse(baseUrl)).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Register a new user. Returns the user map or throws [ApiException].
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String disability,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/api/users/register'),
          headers: _headers,
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'role': role,
            'disability': disability,
          }),
        )
        .timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 201) return body as Map<String, dynamic>;
    throw ApiException(body['detail'] ?? 'Registration failed (${res.statusCode})');
  }

  /// Login. Returns the user map or throws [ApiException].
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/api/users/login'),
          headers: _headers,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException(body['detail'] ?? 'Login failed (${res.statusCode})');
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  /// Send a message to the AI and get a reply.
  static Future<String> sendChatMessage({
    required int userId,
    required String userName,
    required String message,
    required String disabilityMode,
    String targetLanguage = 'en-IN',
    String context = '',
  }) async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/api/chat/'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'user_name': userName,
            'message': message,
            'disability_mode': disabilityMode,
            'target_language': targetLanguage,
            'context': context,
          }),
        )
        .timeout(_timeout);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body['reply'] as String;
    throw ApiException(body['detail'] ?? 'Chat error (${res.statusCode})');
  }

  /// Fetch chat history for a user.
  static Future<List<Map<String, dynamic>>> getChatHistory(int userId) async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/chat/history/$userId'))
        .timeout(_timeout);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['history']);
    }
    return [];
  }

  // ── Documents ────────────────────────────────────────────────────────────

  /// Upload a file (bytes) and get extracted text chunks back.
  static Future<Map<String, dynamic>> uploadDocument({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/docs/upload_and_read'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    final streamed = await request.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);

    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body as Map<String, dynamic>;
    throw ApiException(body['detail'] ?? 'Upload failed (${res.statusCode})');
  }

  // ── Quiz ─────────────────────────────────────────────────────────────────

  /// Fetch a manual quiz from the backend.
  static Future<Map<String, dynamic>> getManualQuiz() async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/quiz/manual-quiz'))
        .timeout(_timeout);

    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw ApiException('Quiz fetch failed (${res.statusCode})');
  }

  /// Submit a quiz result to the backend.
  static Future<void> submitQuizResult({
    required int userId,
    required int score,
    required int total,
    String topic = 'General',
  }) async {
    await http
        .post(
          Uri.parse('$baseUrl/api/quiz/submit-result'),
          headers: _headers,
          body: jsonEncode({
            'user_id': userId,
            'score': score,
            'total': total,
            'topic': topic,
          }),
        )
        .timeout(_timeout);
  }

  /// Fetch all quiz results for a user.
  static Future<List<Map<String, dynamic>>> getQuizResults(int userId) async {
    final res = await http
        .get(Uri.parse('$baseUrl/api/quiz/results/$userId'))
        .timeout(_timeout);

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(body['results']);
    }
    return [];
  }
}

/// Thrown when the backend returns a non-success response.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
