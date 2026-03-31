import 'dart:convert';

import 'package:flutter/material.dart';

class AppLog {
  AppLog._();

  static void request(String endpoint, {dynamic body, String method = 'POST'}) {
    assert(() {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🚀 $method → $endpoint');
      if (body != null) debugPrint('│ 📦 Body: ${jsonEncode(body)}');
      debugPrint('└─────────────────────────────────────────');
      return true;
    }());
  }

  static void response(String endpoint, dynamic response) {
    assert(() {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ ✅ RESPONSE ← $endpoint');
      debugPrint('│ 📬 ${jsonEncode(response)}');
      debugPrint('└─────────────────────────────────────────');
      return true;
    }());
  }

  static void error(String endpoint, dynamic error, {int? statusCode}) {
    assert(() {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ ❌ ERROR ← $endpoint');
      if (statusCode != null) debugPrint('│ 🔴 Status: $statusCode');
      debugPrint('│ 💬 $error');
      debugPrint('└─────────────────────────────────────────');
      return true;
    }());
  }

  static void info(String message) {
    assert(() {
      debugPrint('ℹ️  $message');
      return true;
    }());
  }
}