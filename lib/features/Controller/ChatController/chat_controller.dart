// lib/features/Controller/ChatController/chat_controller.dart
//
// ✅ তিনটা feature একসাথে:
//   1. 🎤 Audio পাঠানো   → WAV format, multipart upload
//   2. 🔊 Audio শোনা     → local file + server URL দুটোই
//   3. 🤖 AI কী বুঝল    → ai_response.message UI তে দেখানো

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/services/AuthService/auth_service.dart';
import '../../../core/services/ChatService/chat_service.dart';
import '../../Model/ChetModel/chat_model.dart';

class ChatController extends GetxController {
  // ─── Services ────────────────────────────────────────
  final _chatService   = ChatService();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer   = AudioPlayer();

  // ─── Input ───────────────────────────────────────────
  final inputController  = TextEditingController();
  final scrollController = ScrollController();

  // ─── Observables ─────────────────────────────────────
  final messages           = <ChatMessage>[].obs;
  final sessions           = <ChatSession>[].obs;
  final sessionId          = (-1).obs;
  final isLoading          = false.obs;
  final isLoadingSessions  = false.obs;
  final isLoggingOut       = false.obs;
  final isRecording        = false.obs;
  final playingAudioId     = (-1).obs;

  // ✅ নতুন: recording এর duration দেখানোর জন্য
  final recordingSeconds   = 0.obs;

  // ─── Non-observable ───────────────────────────────────
  File?   selectedImage;
  File?   selectedAudio;
  String? _recordingPath;

  // ════════════════════════════════════════════════════
  //  LIFECYCLE
  // ════════════════════════════════════════════════════
  @override
  void onInit() {
    super.onInit();
    _resetState();
    loadSessions();

    // Audio শেষ হলে playing state reset
    _audioPlayer.onPlayerComplete.listen((_) {
      playingAudioId.value = -1;
    });
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.onClose();
  }

  // ════════════════════════════════════════════════════
  //  STATE RESET
  // ════════════════════════════════════════════════════
  void _resetState() {
    messages.clear();
    sessions.clear();
    sessionId.value         = -1;
    isLoading.value         = false;
    isLoadingSessions.value = false;
    isLoggingOut.value      = false;
    isRecording.value       = false;
    playingAudioId.value    = -1;
    recordingSeconds.value  = 0;
    selectedImage           = null;
    selectedAudio           = null;
    _recordingPath          = null;
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
      _showError("Delete করতে সমস্যা হয়েছে");
    }
  }

  // ════════════════════════════════════════════════════
  //  SEND MESSAGE (text + image + audio)
  // ════════════════════════════════════════════════════
  Future<void> sendMessage() async {
    final text  = inputController.text.trim();
    final image = selectedImage;
    final audio = selectedAudio;

    if (text.isEmpty && image == null && audio == null) return;
    if (isLoading.value) return;

    // Session না থাকলে বানাও
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
    update();

    isLoading.value = true;
    try {
      final round = await _chatService.sendMessage(
        sessionId: sessionId.value,
        message:   text.isEmpty ? null : text,
        imageFile: image,
        audioFile: audio,
      );

      messages.add(round.userMessage);
      messages.add(round.aiResponse);
      _scrollToBottom();

      // Session title auto-update
      final idx = sessions.indexWhere((s) => s.id == sessionId.value);
      if (idx != -1 &&
          (sessions[idx].title == null || sessions[idx].title!.isEmpty)) {
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
  //  🎤 AUDIO RECORDING
  //
  //  Format: WAV, 16kHz, mono
  //  এই format টা সব STT engine বোঝে।
  //  Timer দিয়ে recording duration দেখানো হচ্ছে।
  // ════════════════════════════════════════════════════
  Future<bool> _startRecording() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      _showError("Microphone permission দেওয়া হয়নি");
      return false;
    }

    final dir  = await getTemporaryDirectory();
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
    _recordingPath = path;

    await _audioRecorder.start(
      const RecordConfig(
        encoder:     AudioEncoder.wav,
        sampleRate:  16000,   // STT standard
        numChannels: 1,       // mono
      ),
      path: path,
    );

    // ✅ Recording duration counter
    recordingSeconds.value = 0;
    _startDurationTimer();

    debugPrint("🎙️ Recording started → $path");
    return true;
  }

  // Duration timer — প্রতি সেকেন্ডে বাড়ে
  void _startDurationTimer() async {
    while (isRecording.value) {
      await Future.delayed(const Duration(seconds: 1));
      if (isRecording.value) recordingSeconds.value++;
    }
  }

  Future<void> _stopRecording() async {
    recordingSeconds.value = 0;
    final path = await _audioRecorder.stop();

    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync() && file.lengthSync() > 0) {
        selectedAudio = file;
        debugPrint("🎙️ Saved → $path (${file.lengthSync()} bytes)");
        update();
      } else {
        _showError("Recording সেভ হয়নি, আবার চেষ্টা করুন");
      }
    } else {
      _showError("Recording সেভ হয়নি, আবার চেষ্টা করুন");
    }
    _recordingPath = null;
  }

  // Mic বাটনে tap করলে এটা call হয়
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      // ── Stop ──────────────────────────────────────
      isRecording.value = false;
      await _stopRecording();
    } else {
      // ── Start ─────────────────────────────────────
      // Audio চলছে থাকলে আগে বন্ধ করো
      await _audioPlayer.stop();
      playingAudioId.value = -1;

      final started = await _startRecording();
      if (started) isRecording.value = true;
    }
  }

  // ════════════════════════════════════════════════════
  //  🔊 AUDIO PLAYBACK
  //
  //  তিন ধরনের URL handle করে:
  //  1. https://...        → UrlSource (server file)
  //  2. /data/user/...     → DeviceFileSource (local recording)
  //  3. /media/chat_audio/ → base URL + relative path (API response)
  // ════════════════════════════════════════════════════
  Future<void> playAudio(int msgId, String audioUrl) async {
    // Same message tap → stop
    if (playingAudioId.value == msgId) {
      await _audioPlayer.stop();
      playingAudioId.value = -1;
      return;
    }

    // অন্য কিছু চলছে থাকলে বন্ধ করো
    await _audioPlayer.stop();
    playingAudioId.value = -1;

    // Recording চলছে থাকলে play করা যাবে না
    if (isRecording.value) {
      _showError("Recording চলছে, আগে বন্ধ করুন");
      return;
    }

    try {
      final Source source = _resolveAudioSource(audioUrl);
      playingAudioId.value = msgId;
      await _audioPlayer.play(source);
      debugPrint("🔊 Playing: $audioUrl");
    } catch (e) {
      debugPrint("playAudio error: $e");
      playingAudioId.value = -1;
      _showError("Audio play করতে সমস্যা হয়েছে");
    }
  }

  // URL type বুঝে সঠিক Source বানায়
  Source _resolveAudioSource(String audioUrl) {
    if (audioUrl.startsWith('http://') || audioUrl.startsWith('https://')) {
      // পুরো URL — সরাসরি play
      return UrlSource(audioUrl);
    } else if (audioUrl.startsWith('/data') || audioUrl.startsWith('/storage')) {
      // Local device file path
      return DeviceFileSource(audioUrl);
    } else {
      // API থেকে আসা relative path যেমন: /media/chat_audio/voice_xxx.wav
      // → https://mathapi.dsrt321.online/media/chat_audio/voice_xxx.wav
      const baseUrl = "https://mathapi.dsrt321.online";
      return UrlSource("$baseUrl$audioUrl");
    }
  }

  // ════════════════════════════════════════════════════
  //  LOGOUT
  // ════════════════════════════════════════════════════
  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      await AuthService.logout();
    } catch (e) {
      debugPrint("logout error: $e");
    } finally {
      isLoggingOut.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════

  // Recording duration কে "0:05" format এ দেখায়
  String get recordingDuration {
    final m = recordingSeconds.value ~/ 60;
    final s = recordingSeconds.value % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

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