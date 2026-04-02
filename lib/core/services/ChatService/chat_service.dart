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
  final ApiServices _api;
  ChatService() : _api = ApiServices(baseUrl: _baseUrl);

  Future<Map<String, String>> _authHeader() async {
    final token = StorageService.accessToken;
    return token != null && token.isNotEmpty
        ? {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    }
        : {"Content-Type": "application/json"};
  }

  // ════════════════════════════════════════════════════
  //  Create Session  POST /api/chat/sessions/
  // ════════════════════════════════════════════════════
  Future<int> createSession() async {
    const endpoint = "/api/chat/sessions/";
    final token = StorageService.accessToken;

    AppLog.request(endpoint, body: {}, method: 'POST');

    final response = await http.post(
      Uri.parse("$_baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
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
  //  Response: { "count": N, "results": [...] }
  //  ⚠️ NOTE: list response এ "user" field নেই — model এ optional করা হয়েছে
  // ════════════════════════════════════════════════════
  Future<List<ChatSession>> fetchSessions() async {
    const endpoint = "/api/chat/sessions/";
    final headers = await _authHeader();

    AppLog.request(endpoint, method: 'GET');

    final response = await http.get(
      Uri.parse("$_baseUrl$endpoint"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("fetchSessions failed: ${response.statusCode}");
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    AppLog.response(endpoint, decoded);

    // ✅ "results" key থেকে নেওয়া হচ্ছে
    final List<dynamic> raw = decoded["results"] as List<dynamic>? ?? [];
    return raw
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ════════════════════════════════════════════════════
  //  Single session messages  GET /api/chat/sessions/<id>/
  //  ⚠️ শুধু আপনার নিজের session এর id দিতে হবে
  //     অন্য user এর session হলে 404 "Session not found" আসবে
  // ════════════════════════════════════════════════════
  Future<List<ChatMessage>> fetchSessionMessages(int sessionId) async {
    final endpoint = "/api/chat/sessions/$sessionId/";
    final headers = await _authHeader();

    AppLog.request(endpoint, method: 'GET');

    final response = await http.get(
      Uri.parse("$_baseUrl$endpoint"),
      headers: headers,
    );

    if (response.statusCode == 404) {
      AppLog.error(endpoint, response.body, statusCode: 404);
      // ✅ 404 হলে empty list return — crash হবে না
      return [];
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
    final token = StorageService.accessToken;

    AppLog.request(endpoint, body: {"title": title}, method: 'PUT');

    final response = await http.put(
      Uri.parse("$_baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
      body: jsonEncode({"title": title}),
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
  //  Response: 204 No Content
  // ════════════════════════════════════════════════════
  Future<void> deleteSession(int sessionId) async {
    final endpoint = "/api/chat/sessions/$sessionId/";
    final token = StorageService.accessToken;

    AppLog.request(endpoint, method: 'DELETE');

    final response = await http.delete(
      Uri.parse("$_baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("deleteSession failed: ${response.statusCode}");
    }

    AppLog.info("Session $sessionId deleted ✅");
  }

  // ════════════════════════════════════════════════════
  //  Send Message  POST /api/chat/sessions/<id>/send/
  //  ⚠️ session id অবশ্যই আপনার নিজের হতে হবে
  // ════════════════════════════════════════════════════
  Future<ChatRound> sendMessage({
    required int sessionId,
    String? message,
    File? imageFile,
    File? audioFile,
  }) async {
    final endpoint = "/api/chat/sessions/$sessionId/send/";
    final token = StorageService.accessToken;

    AppLog.request(endpoint, body: {
      "session_id": sessionId,
      "message": message ?? "",
      "has_image": imageFile != null,
      "has_audio": audioFile != null,
    });

    final headers = <String, String>{
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };

    final data = await _api.postMultipart(
      endpoint: endpoint,
      headers: headers,
      fields: {
        if (message != null && message.isNotEmpty) "message": message,
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