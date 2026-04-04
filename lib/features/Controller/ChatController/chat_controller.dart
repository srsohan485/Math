// lib/features/Controller/ChatController/chat_controller.dart
//
// ✅ KEY FIX: onInit() এ messages, sessions, sessionId সব clear করা হয়
// যাতে নতুন user login করলে আগের user এর data না দেখায়

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/AuthService/auth_service.dart';
import '../../../core/services/ChatService/chat_service.dart';
import '../../Model/ChetModel/chat_model.dart';

class ChatController extends GetxController {
  // ─── Services ───────────────────────────────────
  final _chatService = ChatService();

  // ─── Input ──────────────────────────────────────
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  // ─── Observables ────────────────────────────────
  final messages           = <ChatMessage>[].obs;
  final sessions           = <ChatSession>[].obs;
  final sessionId          = (-1).obs;
  final isLoading          = false.obs;
  final isLoadingSessions  = false.obs;
  final isLoggingOut       = false.obs;
  final isRecording        = false.obs;
  final playingAudioId     = (-1).obs;

  // ─── Non-observable state ────────────────────────
  File? selectedImage;
  File? selectedAudio;

  // ════════════════════════════════════════════════════
  //  LIFECYCLE
  // ════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    // ✅ সবসময় fresh state দিয়ে শুরু করো
    // Get.delete করার পরে নতুন instance তৈরি হলে এটা automatically call হবে
    _resetState();
    loadSessions();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ════════════════════════════════════════════════════
  //  STATE RESET  ← নতুন user এর জন্য সব clear করো
  // ════════════════════════════════════════════════════
  void _resetState() {
    messages.clear();
    sessions.clear();
    sessionId.value = -1;
    isLoading.value = false;
    isLoadingSessions.value = false;
    isLoggingOut.value = false;
    isRecording.value = false;
    playingAudioId.value = -1;
    selectedImage = null;
    selectedAudio = null;
    inputController.clear();
  }

  // ════════════════════════════════════════════════════
  //  SESSIONS
  // ════════════════════════════════════════════════════

  Future<void> loadSessions() async {
    isLoadingSessions.value = true;
    try {
      final list = await _chatService.fetchSessions();
      sessions.assignAll(list);
    } catch (e) {
      debugPrint("loadSessions error: $e");
    } finally {
      isLoadingSessions.value = false;
    }
  }

  Future<void> startNewSession() async {
    try {
      final id = await _chatService.createSession();
      sessionId.value = id;
      messages.clear();
      await loadSessions();
    } catch (e) {
      debugPrint("startNewSession error: $e");
      _showError("New chat শুরু করতে সমস্যা হয়েছে");
    }
  }

  Future<void> loadSession(int id) async {
    sessionId.value = id;
    isLoading.value = true;
    messages.clear();
    try {
      final msgs = await _chatService.fetchSessionMessages(id);
      messages.assignAll(msgs);
      _scrollToBottom();
    } catch (e) {
      debugPrint("loadSession error: $e");
      _showError("Chat load করতে সমস্যা হয়েছে");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renameSession(int id, String title) async {
    try {
      final updated = await _chatService.renameSession(id, title);
      final idx = sessions.indexWhere((s) => s.id == id);
      if (idx != -1) sessions[idx] = updated;
    } catch (e) {
      debugPrint("renameSession error: $e");
      _showError("Rename করতে সমস্যা হয়েছে");
    }
  }

  Future<void> deleteSession(int id) async {
    try {
      await _chatService.deleteSession(id);
      sessions.removeWhere((s) => s.id == id);
      if (sessionId.value == id) {
        sessionId.value = -1;
        messages.clear();
      }
    } catch (e) {
      debugPrint("deleteSession error: $e");
      _showError("Delete করতে সমস্যা হয়েছে");
    }
  }

  // ════════════════════════════════════════════════════
  //  SEND MESSAGE
  // ════════════════════════════════════════════════════
  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    final image = selectedImage;
    final audio = selectedAudio;

    if (text.isEmpty && image == null && audio == null) return;
    if (isLoading.value) return;

    // ── নতুন session না থাকলে তৈরি করো ──────────────
    if (sessionId.value == -1) {
      try {
        final id = await _chatService.createSession();
        sessionId.value = id;
        await loadSessions();
      } catch (e) {
        _showError("Session তৈরি করতে সমস্যা হয়েছে");
        return;
      }
    }

    inputController.clear();
    selectedImage = null;
    selectedAudio = null;
    update(); // image preview সরাও

    isLoading.value = true;
    try {
      final round = await _chatService.sendMessage(
        sessionId: sessionId.value,
        message: text.isEmpty ? null : text,
        imageFile: image,
        audioFile: audio,
      );
      messages.add(round.userMessage);
      messages.add(round.aiResponse);
      _scrollToBottom();

      // ── Session title auto-update ─────────────────
      final idx = sessions.indexWhere((s) => s.id == sessionId.value);
      if (idx != -1 && (sessions[idx].title == null || sessions[idx].title!.isEmpty)) {
        await loadSessions();
      }
    } catch (e) {
      debugPrint("sendMessage error: $e");
      _showError("Message পাঠাতে সমস্যা হয়েছে");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  IMAGE PICKER
  // ════════════════════════════════════════════════════
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      selectedImage = File(picked.path);
      update();
    }
  }

  // ════════════════════════════════════════════════════
  //  AUDIO RECORDING
  // ════════════════════════════════════════════════════
  Future<void> toggleRecording() async {
    // TODO: তোমার recording implementation এখানে যোগ করো
    isRecording.value = !isRecording.value;
  }

  // ════════════════════════════════════════════════════
  //  AUDIO PLAYBACK
  // ════════════════════════════════════════════════════
  Future<void> playAudio(int msgId, String audioUrl) async {
    // TODO: তোমার audio player implementation এখানে যোগ করো
    if (playingAudioId.value == msgId) {
      playingAudioId.value = -1;
    } else {
      playingAudioId.value = msgId;
    }
  }

  // ════════════════════════════════════════════════════
  //  LOGOUT  ← ChatController এর logout method
  // ════════════════════════════════════════════════════
  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      // AuthService.logout() → API call + StorageService.logout() + navigation
      await AuthService.logout();
      // ✅ Note: AuthService.logout() শেষে Get.offAll(SignInScreen) call করে
      // তাই এখানে আর navigation দরকার নেই
    } catch (e) {
      debugPrint("logout error: $e");
    } finally {
      isLoggingOut.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      duration: const Duration(seconds: 3),
    );
  }
}