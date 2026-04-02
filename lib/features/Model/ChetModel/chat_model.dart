// lib/features/Model/ChetModel/chat_model.dart

// ─────────────────────────────────────────────────────────
//  ChatMessage  — a single message in a session
// ─────────────────────────────────────────────────────────
class ChatMessage {
  final int id;
  final int session;
  final String sender; // "USER" or "AI"
  final String message;
  final String? image;
  final String? audio;
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.session,
    required this.sender,
    required this.message,
    this.image,
    this.audio,
    required this.createdAt,
  });

  bool get isUser => sender == "USER";
  bool get isAi => sender == "AI";

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["id"] as int,
      session: json["session"] as int,
      sender: json["sender"] as String,
      message: json["message"] as String,
      image: json["image"] as String?,
      audio: json["audio"] as String?,
      createdAt: json["created_at"] as String,
    );
  }
}

// ─────────────────────────────────────────────────────────
//  ChatSession
// ─────────────────────────────────────────────────────────
class ChatSession {
  final int id;
  final int? user; // ✅ optional — list API তে "user" field নেই
  final String? title;
  final String createdAt;
  final String updatedAt;

  const ChatSession({
    required this.id,
    this.user, // ✅ optional
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json["id"] as int,
      user: json["user"] as int?, // ✅ null-safe
      title: json["title"] as String?,
      createdAt: json["created_at"] as String,
      updatedAt: json["updated_at"] as String,
    );
  }
}

// ─────────────────────────────────────────────────────────
//  ChatRound  — one user + AI round-trip
// ─────────────────────────────────────────────────────────
class ChatRound {
  final ChatMessage userMessage;
  final ChatMessage aiResponse;

  const ChatRound({required this.userMessage, required this.aiResponse});

  factory ChatRound.fromJson(Map<String, dynamic> json) {
    return ChatRound(
      userMessage: ChatMessage.fromJson(
          json["user_message"] as Map<String, dynamic>),
      aiResponse: ChatMessage.fromJson(
          json["ai_response"] as Map<String, dynamic>),
    );
  }
}