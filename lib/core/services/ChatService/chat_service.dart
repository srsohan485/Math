import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../features/Model/ChetModel/chat_model.dart';
import '../../storege/storage_service.dart';
import '../api_service.dart';

class ChatService {
  static const String _baseUrl = "https://mathapi.dsrt321.online";
  final ApiServices _api;
  ChatService() : _api = ApiServices(baseUrl: _baseUrl);

  // ── Auth header ─────────────────────────────────────
  Future<Map<String, String>> _authHeader() async {
    final token = StorageService.accessToken;
    return token != null && token.isNotEmpty
        ? {"Authorization": "Bearer $token"}
        : {};
  }

  // ════════════════════════════════════════════════════
  //  Create a new chat session → returns session id
  // ════════════════════════════════════════════════════
  Future<int> createSession() async {
    final token = StorageService.accessToken;

    final response = await http.post(
      Uri.parse("$_baseUrl/api/chat/sessions/"),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({}),
    );

    final data = jsonDecode(response.body);
    return data["id"] as int;
  }

  // ════════════════════════════════════════════════════
  //  Send a message — image + audio দুটোই যাবে
  // ════════════════════════════════════════════════════
  Future<ChatRound> sendMessage({
    required int sessionId,
    String? message,
    File? imageFile,
    File? audioFile,
  }) async {
    final headers = await _authHeader();

    final data = await _api.postMultipart(
      endpoint: "/api/chat/sessions/$sessionId/send/",
      headers: headers,
      fields: {
        if (message != null) "message": message,
      },
      file: imageFile,
      fileField: "image",
      audioFile: audioFile,  // ← এটা যোগ করুন
      audioField: "audio",   // ← এটা যোগ করুন
    );

    print("🔥 API RESPONSE: $data");
    return ChatRound.fromJson(data as Map<String, dynamic>);
  }
}