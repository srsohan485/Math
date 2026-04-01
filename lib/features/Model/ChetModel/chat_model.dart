// lib/features/model/chat_message.dart

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
  bool get isAi   => sender == "AI";

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id:        json["id"]         as int,
      session:   json["session"]    as int,
      sender:    json["sender"]     as String,
      message:   json["message"]    as String,
      image:     json["image"]      as String?,
      audio:     json["audio"]      as String?,
      createdAt: json["created_at"] as String,
    );
  }
}

/// Wraps one round-trip: the user turn + the AI reply.
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