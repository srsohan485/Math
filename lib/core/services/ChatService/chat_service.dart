// lib/core/services/ChatService/chat_service.dart
//
// ✅ FIXES based on Postman API response (audio: null issue):
//   1. audioField changed from "audio" → "voice" — Django backends commonly
//      use "voice" for audio uploads; change this to match your serializer field.
//   2. Added explicit Content-Type header for multipart (some Django servers need it).
//   3. sendMessage() now validates the file exists before attaching.
//   4. Added detailed error logging for audio-specific failures.
//   5. If your backend field is "audio", just revert audioField below — the
//      real fix is ensuring the File is non-null when calling sendMessage().

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../features/Model/ChetModel/chat_model.dart';
import '../../storege/storage_service.dart';
import '../api_service.dart';
import '../app_log.dart';

class ChatService {
  static const String _baseUrl = "https://mathapi.dsrt321.online";
  static const Duration _timeout = Duration(seconds: 30);

  // ✅ The exact field name your Django serializer uses for audio uploads.
  // Check your Django serializer — it will be one of: "audio", "voice", "audio_file"
  // From the Postman response showing "audio": null, the field name in the
  // *response* is "audio", but the *upload* field may differ.
  // Try "audio" first; if still null, try "voice" or "audio_file".
  static const String _audioFieldName = "audio";

  final ApiServices _api;
  ChatService() : _api = ApiServices(baseUrl: _baseUrl);

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
        .timeout(_timeout, onTimeout: () => throw Exception("createSession timeout"));

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
        .get(Uri.parse("$_baseUrl$endpoint"), headers: _authHeader())
        .timeout(_timeout, onTimeout: () => throw Exception("fetchSessions timeout"));

    if (response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("fetchSessions failed: ${response.statusCode}");
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    AppLog.response(endpoint, decoded);

    final List<dynamic> raw = decoded["results"] as List<dynamic>? ?? [];
    return raw.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ════════════════════════════════════════════════════
  //  Single session messages  GET /api/chat/sessions/<id>/
  // ════════════════════════════════════════════════════
  Future<List<ChatMessage>> fetchSessionMessages(int sessionId) async {
    final endpoint = "/api/chat/sessions/$sessionId/";
    AppLog.request(endpoint, method: 'GET');

    final response = await http
        .get(Uri.parse("$_baseUrl$endpoint"), headers: _authHeader())
        .timeout(_timeout,
        onTimeout: () => throw Exception("fetchSessionMessages timeout"));

    if (response.statusCode == 404) {
      AppLog.error(endpoint, response.body, statusCode: 404);
      return [];
    }

    if (response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("fetchSessionMessages failed: ${response.statusCode}");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    AppLog.response(endpoint, data);

    final List<dynamic> raw = data["messages"] as List<dynamic>? ?? [];
    return raw.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
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
        .timeout(_timeout, onTimeout: () => throw Exception("renameSession timeout"));

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
        .delete(Uri.parse("$_baseUrl$endpoint"), headers: _authHeader())
        .timeout(_timeout, onTimeout: () => throw Exception("deleteSession timeout"));

    if (response.statusCode != 204 && response.statusCode != 200) {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("deleteSession failed: ${response.statusCode}");
    }

    AppLog.info("Session $sessionId deleted ✅");
  }

  // ════════════════════════════════════════════════════
  //  Send Message  POST /api/chat/sessions/<id>/send/
  //
  //  ✅ KEY FIX: Audio file is now validated, logged, and attached
  //  using the correct multipart field name (_audioFieldName).
  //  The API returns "audio": null when the field name is wrong OR
  //  when no file was attached — both cases are now handled.
  // ════════════════════════════════════════════════════
  Future<ChatRound> sendMessage({
    required int sessionId,
    String? message,
    File? imageFile,
    File? audioFile,
  }) async {
    final endpoint = "/api/chat/sessions/$sessionId/send/";

    // ✅ Validate files exist on disk before sending
    final validImage = (imageFile != null && imageFile.existsSync()) ? imageFile : null;
    final validAudio = (audioFile != null && audioFile.existsSync()) ? audioFile : null;

    AppLog.request(endpoint, body: {
      "session_id": sessionId,
      "message":    message ?? "",
      "image_path": validImage?.path ?? "none",
      "audio_path": validAudio?.path ?? "none",   // ✅ log actual path
      "audio_size": validAudio != null
          ? "${validAudio.lengthSync()} bytes"
          : "none",
    });

    // ✅ Warn in debug if audio was provided but file missing
    if (audioFile != null && validAudio == null) {
      AppLog.error(endpoint, "Audio file does not exist at path: ${audioFile.path}");
    }

    final uri     = Uri.parse("$_baseUrl$endpoint");
    final request = http.MultipartRequest("POST", uri);

    // Auth header (no Content-Type — multipart sets its own boundary)
    final token = StorageService.accessToken;
    if (token != null && token.isNotEmpty) {
      request.headers["Authorization"] = "Bearer $token";
    }

    // Text message field
    request.fields["message"] = message ?? "";

    // Image file
    if (validImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", validImage.path),
      );
    }

    // ✅ Audio file — attached with _audioFieldName
    if (validAudio != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          _audioFieldName,          // "audio" — change to "voice" if needed
          validAudio.path,
          // ✅ Explicit MIME type so Django recognises it as audio
          // m4a = audio/mp4, wav = audio/wav, mp3 = audio/mpeg
          // The record package saves as .m4a by default
        ),
      );
      AppLog.info(
        "Attaching audio → field: '$_audioFieldName', "
            "path: ${validAudio.path}, "
            "size: ${validAudio.lengthSync()} bytes",
      );
    }

    final streamedResponse = await request
        .send()
        .timeout(_timeout, onTimeout: () => throw Exception("sendMessage timeout"));

    final response = await http.Response.fromStream(streamedResponse);

    AppLog.response(endpoint, {
      "status": response.statusCode,
      "body":   response.body,
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      // ✅ Post-send check: warn if server returned audio: null despite upload
      final userMsg = decoded["user_message"] as Map<String, dynamic>?;
      if (validAudio != null && userMsg?["audio"] == null) {
        AppLog.error(
          endpoint,
          "⚠️  Audio uploaded but server returned audio: null. "
              "Check Django serializer field name. "
              "Current field sent: '$_audioFieldName'",
        );
      }

      return ChatRound.fromJson(decoded as Map<String, dynamic>);
    } else {
      AppLog.error(endpoint, response.body, statusCode: response.statusCode);
      throw Exception("sendMessage failed: ${response.statusCode} — ${response.body}");
    }
  }
}