import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/ChatService/chat_service.dart';
import '../../../core/storege/storage_service.dart';
import '../../Model/ChetModel/chat_model.dart';

class ChatController extends GetxController {
  // ─── Text Controller ─────────────────────────────────
  final inputController = TextEditingController();
  final _player = AudioPlayer();
  File? selectedImage;
  File? selectedAudio;

  // ─── Observables ─────────────────────────────────────
  final messages       = <ChatMessage>[].obs;
  final isLoading      = false.obs;
  final isInitializing = true.obs;
  final sessionId      = 0.obs;
  final isRecording    = false.obs; // ← recording state
  // Audio player
  final playingAudioId = (-1).obs;

  // ─── Internal ────────────────────────────────────────
  final _chatService     = ChatService();
  final _recorder        = AudioRecorder();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _createSession();
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
  //  Create Session
  // ════════════════════════════════════════════════════
  Future<void> _createSession() async {
    isInitializing.value = true;
    try {
      final id = await _chatService.createSession();
      sessionId.value = id;
    } catch (e) {
      _showError("Failed to start chat session. Please try again.");
    } finally {
      isInitializing.value = false;
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
  //  Voice Recording — Toggle
  // ════════════════════════════════════════════════════
  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    // Permission check
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showError("Microphone permission denied");
      return;
    }

    try {
      final dir  = await getTemporaryDirectory();
      final path = "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";

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

        // ← record বন্ধ হলে সাথে সাথে send করুন
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
      _showError("Session not ready.");
      return;
    }

    final optimisticUser = ChatMessage(
      id: -1,
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

    try {
      final round = await _chatService.sendMessage(
        sessionId: sessionId.value,
        message: text.isEmpty ? null : text,
        imageFile: selectedImage,
        audioFile: selectedAudio,
      );

      final idx = messages.indexWhere((m) => m.id == -1 && m.sender == "USER");
      if (idx != -1) messages[idx] = round.userMessage;

      messages.add(round.aiResponse);
      _scrollToBottom();

      selectedImage = null;
      selectedAudio = null;
      update();

    } catch (e) {
      messages.removeWhere((m) => m.id == -1);
      inputController.text = text;
      _showError("Failed to send");
    } finally {
      isLoading.value = false;
      _scrollToBottom();
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

  // ════════════════════════════════════════════════════
  //  Play Audio
  // ════════════════════════════════════════════════════
  Future<void> playAudio(int messageId, String audioPath) async {
    print("🎵 playAudio called: id=$messageId, path=$audioPath");
    try {
      if (playingAudioId.value == messageId) {
        await _player.stop();
        playingAudioId.value = -1;
        return;
      }

      playingAudioId.value = messageId;

      // local temp file
      if (audioPath.startsWith('/data/') || audioPath.startsWith('/storage/')) {
        final file = File(audioPath);
        if (await file.exists()) {
          await _player.setFilePath(audioPath);
        } else {
          _showError("Audio file পাওয়া যায়নি");
          playingAudioId.value = -1;
          return;
        }
      } else {
        // server path → token সহ download করে temp file এ save করো
        final fullUrl = audioPath.startsWith('http')
            ? audioPath
            : "https://mathapi.dsrt321.online$audioPath";

        print("🌐 Downloading: $fullUrl");

        final token = StorageService.accessToken;
        final response = await http.get(
          Uri.parse(fullUrl),
          headers: {
            if (token != null) "Authorization": "Bearer $token",
          },
        );

        print("📥 Download status: ${response.statusCode}");

        if (response.statusCode == 200) {
          // temp file এ save করো
          final dir  = await getTemporaryDirectory();
          final file = File("${dir.path}/play_${messageId}.m4a");
          await file.writeAsBytes(response.bodyBytes);
          print("💾 Saved to: ${file.path}");
          await _player.setFilePath(file.path);
        } else {
          _showError("Audio load হয়নি: ${response.statusCode}");
          playingAudioId.value = -1;
          return;
        }
      }

      await _player.play();
      print("▶️ Playing...");

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          playingAudioId.value = -1;
        }
      });
    } catch (e) {
      print("❌ Audio error: $e");
      playingAudioId.value = -1;
      _showError("Audio play হয়নি: $e");
    }
  }

}
