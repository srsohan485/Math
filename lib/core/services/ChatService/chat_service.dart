// lib/core/services/ChatService/chat_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../features/Model/ChetModel/chat_model.dart';
import '../../storege/storage_service.dart';
import '../api_service.dart';
import '../app_log.dart';

class ChatService {
  static const String _baseUrl = "https://mathapi.dsrt321.online";
  static const Duration _timeout = Duration(seconds: 30); // ✅ NEW

  final ApiServices _api;
  ChatService() : _api = ApiServices(baseUrl: _baseUrl);

  // ✅ async সরানো হয়েছে — কোনো await ছিল না
  Map<String, String> _authHeader() {
    final token = StorageService.accessToken;
    return token != null && token.isNotEmpty
        ? {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }
        : {"Content-Type": "application/json"};
  }

  Map<String, String> _authHeaderOnly() {
    final token = StorageService.accessToken;
    return token != null && token.isNotEmpty
        ? {"Authorization": "Bearer $token"}
        : {};
  }

  // ════════════════════════════════════════════════════
  //  Create Session  POST /api/chat/sessions/
  // ════════════════════════════════════════════════════
  Future<int> createSession() async {
    const endpoint = "/api/chat/sessions/";

    AppLog.request(endpoint, body: {}, method: 'POST');

    final response = await http
        .post(
      Uri.parse("$_baseUrl$endpoint"),
      headers: _authHeader(),
      body: jsonEncode({}),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw Exception("createSession timeout"),
    );

    AppLog.response(endpoint, {"status": response.statusCode, "body": response.body});

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data["id"] as int;
    } else {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("createSession failed: ${response.statusCode} — ${response.body}");
    }
  }

  // ════════════════════════════════════════════════════
  //  List all sessions  GET /api/chat/sessions/
  // ════════════════════════════════════════════════════
  Future<List<ChatSession>> fetchSessions() async {
    const endpoint = "/api/chat/sessions/";

    AppLog.request(endpoint, method: 'GET');

    final response = await http
        .get(
      Uri.parse("$_baseUrl$endpoint"),
      headers: _authHeader(),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw Exception("fetchSessions timeout"),
    );

    if (response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("fetchSessions failed: ${response.statusCode}");
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    AppLog.response(endpoint, decoded);

    final List<dynamic> raw = decoded["results"] as List<dynamic>? ?? [];
    return raw
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ════════════════════════════════════════════════════
  //  Single session messages  GET /api/chat/sessions/<id>/
  // ════════════════════════════════════════════════════
  Future<List<ChatMessage>> fetchSessionMessages(int sessionId) async {
    final endpoint = "/api/chat/sessions/$sessionId/";

    AppLog.request(endpoint, method: 'GET');

    final response = await http
        .get(
      Uri.parse("$_baseUrl$endpoint"),
      headers: _authHeader(),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw Exception("fetchSessionMessages timeout"),
    );

    if (response.statusCode == 404) {
      AppLog.error(endpoint, response.body, statusCode: 404);
      return []; // ✅ 404 হলে empty list — crash হবে না
    }

    if (response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("fetchSessionMessages failed: ${response.statusCode}");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    AppLog.response(endpoint, data);

    final List<dynamic> raw = data["messages"] as List<dynamic>? ?? [];
    return raw
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ════════════════════════════════════════════════════
  //  Rename session  PUT /api/chat/sessions/<id>/
  // ════════════════════════════════════════════════════
  Future<ChatSession> renameSession(int sessionId, String title) async {
    final endpoint = "/api/chat/sessions/$sessionId/";

    AppLog.request(endpoint, body: {"title": title}, method: 'PUT');

    final response = await http
        .put(
      Uri.parse("$_baseUrl$endpoint"),
      headers: _authHeader(),
      body: jsonEncode({"title": title}),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw Exception("renameSession timeout"),
    );

    if (response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("renameSession failed: ${response.statusCode}");
    }

    final data = jsonDecode(response.body);
    AppLog.response(endpoint, data);
    return ChatSession.fromJson(data as Map<String, dynamic>);
  }

  // ════════════════════════════════════════════════════
  //  Delete session  DELETE /api/chat/sessions/<id>/
  // ════════════════════════════════════════════════════
  Future<void> deleteSession(int sessionId) async {
    final endpoint = "/api/chat/sessions/$sessionId/";

    AppLog.request(endpoint, method: 'DELETE');

    final response = await http
        .delete(
      Uri.parse("$_baseUrl$endpoint"),
      headers: _authHeader(),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw Exception("deleteSession timeout"),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("deleteSession failed: ${response.statusCode}");
    }

    AppLog.info("Session $sessionId deleted ✅");
  }

  // ════════════════════════════════════════════════════
  //  Send Message  POST /api/chat/sessions/<id>/send/
  // ════════════════════════════════════════════════════
  Future<ChatRound> sendMessage({
    required int sessionId,
    String? message,
    File? imageFile,
    File? audioFile,
  }) async {
    final endpoint = "/api/chat/sessions/$sessionId/send/";

    AppLog.request(endpoint, body: {
      "session_id": sessionId,
      "message": message ?? "",
      "has_image": imageFile != null,
      "has_audio": audioFile != null,
    });

    // ✅ message null বা empty হলেও "message" field পাঠানো হচ্ছে
    final data = await _api.postMultipart(
      endpoint: endpoint,
      headers: _authHeaderOnly(),
      fields: {
        "message": message ?? "", // ✅ FIXED: আগে empty হলে skip হতো
      },
      file: imageFile,
      fileField: "image",
      audioFile: audioFile,
      audioField: "audio",
    );

    AppLog.response(endpoint, data);
    return ChatRound.fromJson(data as Map<String, dynamic>);
  }
}