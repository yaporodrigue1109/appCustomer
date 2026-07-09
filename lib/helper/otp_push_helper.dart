import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPushHelper {
  static const String _pendingOtpKey = 'pending_otp_from_push';
  static final StreamController<String> _otpStreamController =
      StreamController<String>.broadcast();

  static Stream<String> get otpStream => _otpStreamController.stream;

  static bool isOtpMessage(Map<String, dynamic> data) {
    final String type = (data['type']?.toString() ?? '').toUpperCase();
    final String status = (data['status']?.toString() ?? '').toLowerCase();
    final String action = (data['action']?.toString() ?? '').toLowerCase();
    final String notificationType =
        (data['notification_type']?.toString() ?? '').toLowerCase();

    return type == 'OTP_VERIFICATION' ||
        status == 'otp_verification' ||
        action == 'otp_verification' ||
        notificationType == 'otp_verification';
  }

  static Future<void> captureRemoteMessage(RemoteMessage message) async {
    debugPrint('[OTP_TRACE][push] captureRemoteMessage data=${message.data} notification_title=${message.notification?.title} notification_body=${message.notification?.body}');
    final Map<String, dynamic> payload =
        Map<String, dynamic>.from(message.data);

    // Certains providers envoient l'OTP dans notification.body au lieu de data.
    payload.putIfAbsent('body', () => message.notification?.body ?? '');
    payload.putIfAbsent('message', () => message.notification?.body ?? '');
    payload.putIfAbsent('title', () => message.notification?.title ?? '');

    await captureData(payload);
  }

  static Future<void> captureData(Map<String, dynamic> data) async {
    debugPrint('[OTP_TRACE][push] captureData start action=${data['action']} type=${data['type']} status=${data['status']} notification_type=${data['notification_type']}');
    final String rawText =
        '${data['body']?.toString() ?? ''} ${data['message']?.toString() ?? ''} ${data['title']?.toString() ?? ''}';
    final bool hasOtpKeyword = rawText.toLowerCase().contains('otp');
    debugPrint('[OTP_TRACE][push] raw_has_otp_keyword=$hasOtpKeyword raw="$rawText"');

    if (!isOtpMessage(data) && !hasOtpKeyword) {
      debugPrint('[OTP_TRACE][push] ignored: not an otp message');
      return;
    }

    final String otpCode = _extractOtpCode(data);
    debugPrint('[OTP_TRACE][push] extracted_code="$otpCode" length=${otpCode.length}');
    if (otpCode.length != 6) {
      debugPrint('[OTP_TRACE][push] ignored: invalid otp length');
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingOtpKey, otpCode);
    debugPrint('[OTP_TRACE][push] stored pending otp and emitted stream');
    _otpStreamController.add(otpCode);
  }

  static Future<String?> getPendingOtp() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_pendingOtpKey);
  }

  static Future<void> clearPendingOtp() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingOtpKey);
  }

  static String _extractOtpCode(Map<String, dynamic> data) {
    final List<String> candidates = [
      (data['code']?.toString() ?? '').trim(),
      (data['otp']?.toString() ?? '').trim(),
      (data['body']?.toString() ?? '').trim(),
      (data['description']?.toString() ?? '').trim(),
      (data['message']?.toString() ?? '').trim(),
    ];

    for (final String value in candidates) {
      final RegExpMatch? match = RegExp(r'\b\d{6}\b').firstMatch(value);
      if (match != null) {
        return match.group(0) ?? '';
      }
    }

    return '';
  }
}
