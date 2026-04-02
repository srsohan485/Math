// lib/features/Controller/ChatController/chat_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/AuthService/auth_service.dart'; // ✅
import '../../../core/services/ChatService/chat_service.dart';
import '../../../core/storege/storage_service.dart';
import '../../Model/ChetModel/chat_model.dart';
import '../../View/AuthScreen/singin_screen.dart';

class ChatController extends GetxController {
  final inputController  = TextEditingController();
  final _player          = AudioPlayer();
  File? selectedImage;
  File? selectedAudio;

  final messages          = <ChatMessage>[].obs;
  final sessions          = <ChatSession>[].obs;
  final isLoading         = false.obs;
  final isInitializing    = true.obs;
  final isLoadingSessions = false.obs;
  final isLoggingOut      = false.obs; // ✅ NEW
  final sessionId         = 0.obs;
  final isRecording       = false.obs;
  final playingAudioId    = (-1).obs;

  final _chatService     = ChatService();
  final _recorder        = AudioRecorder();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    _player.dispose();
    _recorder.dispose();
    super.onClose();
  }

  // ════════════════════════════════════════════════════
  //  Bootstrap
  // ════════════════════════════════════════════════════
  Future<void> _bootstrap() async {
    isInitializing.value = true;
    try {
      await loadSessions();
      if (sessions.isNotEmpty) {
        await loadSession(sessions.first.id);
      } else {
        await _createSession();
      }
    } catch (e) {
      debugPrint("_bootstrap error: $e");
      await _createSession();
    } finally {
      isInitializing.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Load session list
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

  // ════════════════════════════════════════════════════
  //  Load a session's messages
  // ════════════════════════════════════════════════════
  Future<void> loadSession(int id) async {
    isLoading.value = true;
    messages.clear();
    try {
      final msgs = await _chatService.fetchSessionMessages(id);
      sessionId.value = id;
      messages.assignAll(msgs);
      _scrollToBottom();
    } catch (e) {
      debugPrint("loadSession error: $e");
      _showError("Chat history load হয়নি।");
      sessionId.value = id;
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  New Chat
  // ════════════════════════════════════════════════════
  Future<void> startNewSession() async {
    messages.clear();
    await _createSession();
    await loadSessions();
  }

  // ════════════════════════════════════════════════════
  //  Create Session
  // ════════════════════════════════════════════════════
  Future<void> _createSession() async {
    try {
      final id = await _chatService.createSession();
      sessionId.value = id;
      debugPrint("✅ New session created: $id");
    } catch (e) {
      debugPrint("_createSession error: $e");
      _showError("Chat session শুরু হয়নি।");
    }
  }

  // ════════════════════════════════════════════════════
  //  Rename Session
  // ════════════════════════════════════════════════════
  Future<void> renameSession(int id, String newTitle) async {
    try {
      final updated = await _chatService.renameSession(id, newTitle);
      final idx = sessions.indexWhere((s) => s.id == id);
      if (idx != -1) {
        sessions[idx] = updated;
        sessions.refresh();
      }
    } catch (e) {
      debugPrint("renameSession error: $e");
      _showError("Rename করা যায়নি।");
    }
  }

  // ════════════════════════════════════════════════════
  //  Delete Session
  // ════════════════════════════════════════════════════
  Future<void> deleteSession(int id) async {
    try {
      await _chatService.deleteSession(id);
      sessions.removeWhere((s) => s.id == id);
      if (sessionId.value == id) {
        messages.clear();
        if (sessions.isNotEmpty) {
          await loadSession(sessions.first.id);
        } else {
          await _createSession();
        }
      }
    } catch (e) {
      debugPrint("deleteSession error: $e");
      _showError("Delete করা যায়নি।");
    }
  }

  // ════════════════════════════════════════════════════
  //  LOGOUT ✅ NEW
  //  AuthService.logout() → static method
  //  POST /api/users/logout/ body: { "refresh": "..." }
  // ════════════════════════════════════════════════════
  Future<void> logout() async {
    isLoggingOut.value = true;
    try {
      // ✅ AuthService.logout() এখন API call করে তারপর
      //    StorageService.logout() call করে Get.offAll() করে
      await AuthService.logout();
    } catch (e) {
      debugPrint("logout error: $e");
      // ✅ যেকোনো error এ force logout
      await StorageService.logout();
      Get.offAll(() => const SignInScreen());
    } finally {
      isLoggingOut.value = false;
    }
  }

  // ════════════════════════════════════════════════════
  //  Pick Image
  // ════════════════════════════════════════════════════
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage = File(picked.path);
      Get.snackbar(
        "Image Selected",
        "এখন আপনার প্রশ্ন লিখুন এবং Send করুন",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      update();
    }
  }

  // ════════════════════════════════════════════════════
  //  Voice Recording
  // ════════════════════════════════════════════════════
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showError("Microphone permission denied");
      return;
    }
    try {
      final dir  = await getTemporaryDirectory();
      final path =
          "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      isRecording.value = true;
      Get.snackbar(
        "Recording...",
        "আবার Mic চাপুন থামাতে",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _showError("Recording শুরু হয়নি: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();
      isRecording.value = false;
      if (path != null) {
        selectedAudio = File(path);
        update();
        await sendMessage();
      }
    } catch (e) {
      isRecording.value = false;
      _showError("Recording বন্ধ হয়নি: $e");
    }
  }

  // ════════════════════════════════════════════════════
  //  Send Message
  // ════════════════════════════════════════════════════
  Future<void> sendMessage() async {
    final text = inputController.text.trim();

    if ((text.isEmpty && selectedImage == null && selectedAudio == null) ||
        isLoading.value) return;

    if (sessionId.value == 0) {
      await _createSession();
      if (sessionId.value == 0) {
        _showError("Session ready নেই। আবার চেষ্টা করুন।");
        return;
      }
    }

    // ✅ UNIQUE ID (IMPORTANT FIX)
    final tempId = DateTime.now().millisecondsSinceEpoch;

    final optimisticUser = ChatMessage(
      id: tempId, // 🔥 FIXED (was -1)
      session: sessionId.value,
      sender: "USER",
      message: text,
      image: selectedImage?.path,
      audio: selectedAudio?.path,
      createdAt: DateTime.now().toIso8601String(),
    );

    messages.add(optimisticUser);
    inputController.clear();
    isLoading.value = true;
    _scrollToBottom();

    final imgToSend = selectedImage;
    final audToSend = selectedAudio;

    selectedImage = null;
    selectedAudio = null;
    update();

    try {
      final round = await _chatService.sendMessage(
        sessionId: sessionId.value,
        message: text.isEmpty ? null : text,
        imageFile: imgToSend,
        audioFile: audToSend,
      );

      // ✅ FIX: specific message replace using tempId
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) {
        messages[idx] = round.userMessage;
      }

      messages.add(round.aiResponse);
      _scrollToBottom();
      loadSessions();

    } catch (e) {
      debugPrint("sendMessage error: $e");

      // ✅ remove only this message
      messages.removeWhere((m) => m.id == tempId);

      inputController.text = text;
      selectedImage = imgToSend;
      selectedAudio = audToSend;
      update();

      _showError("Message পাঠানো যায়নি।");
    } finally {
      isLoading.value = false;
      _scrollToBottom();
    }
  }

  // ════════════════════════════════════════════════════
  //  Play Audio
  // ════════════════════════════════════════════════════
  Future<void> playAudio(int messageId, String audioPath) async {
    try {
      // 🔁 যদি same audio tap করা হয় → stop
      if (playingAudioId.value == messageId) {
        await _player.stop();
        playingAudioId.value = -1;
        return;
      }

      // 🔴 আগের audio stop করো (IMPORTANT)
      await _player.stop();

      playingAudioId.value = messageId;

      if (audioPath.startsWith('/data/') ||
          audioPath.startsWith('/storage/')) {

        final file = File(audioPath);

        if (await file.exists()) {
          await _player.setFilePath(file.path);
        } else {
          _showError("Audio file পাওয়া যায়নি");
          playingAudioId.value = -1;
          return;
        }

      } else {
        final fullUrl = audioPath.startsWith('http')
            ? audioPath
            : "https://mathapi.dsrt321.online$audioPath";

        final token = StorageService.accessToken;

        final response = await http.get(
          Uri.parse(fullUrl),
          headers: {
            if (token != null && token.isNotEmpty)
              "Authorization": "Bearer $token",
          },
        );

        if (response.statusCode == 200) {
          final dir = await getTemporaryDirectory();
          final file = File("${dir.path}/play_$messageId.m4a");

          await file.writeAsBytes(response.bodyBytes);

          await _player.setFilePath(file.path);
        } else {
          _showError("Audio load হয়নি: ${response.statusCode}");
          playingAudioId.value = -1;
          return;
        }
      }

      // 🔊 VERY IMPORTANT (volume fix)
      await _player.setVolume(1.0); // full volume

      // ▶️ play
      await _player.play();

      // ✅ FIX: listener leak remove
      _player.playerStateStream.firstWhere(
            (state) => state.processingState == ProcessingState.completed,
      ).then((_) {
        playingAudioId.value = -1;
      });

    } catch (e) {
      playingAudioId.value = -1;
      _showError("Audio play হয়নি: $e");
    }
  }

  // ════════════════════════════════════════════════════
  //  Helpers
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