import 'dart:convert';
import 'package:crypto/crypto.dart';

class AttendanceGeneratorService {
  // Config key matching Python's bytes literal: b"B4_02_xNexus"
  static final List<int> _hmacSecretKey = utf8.encode("B4_02_xNexus");

  /// Replicates Python's generate_session_qr function exactly.
  /// Expects `rawContextString` to be "courseId_sessionType_duration_instructorId"
  static String generateAttendanceData(String rawContextString) {
    // 1. Get current unix timestamp in seconds
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 2. Format payload string: "courseId_sessionType_duration_instructorId_timestamp"
    final String payloadStr = "${rawContextString}_$timestamp";
    final List<int> payloadBytes = utf8.encode(payloadStr);

    // 3. Generate HMAC-SHA256 Signature
    final Hmac hmacSha256 = Hmac(sha256, _hmacSecretKey);
    final Digest signatureDigest = hmacSha256.convert(payloadBytes);

    // 4. Convert signature to hex string and grab the first 8 characters -> [:8]
    final String fullHexSignature = signatureDigest.toString();
    final String truncatedSignature = fullHexSignature.substring(0, 8);

    // 5. Combine payload and truncated hex signature with an underscore separator
    return "${payloadStr}_$truncatedSignature";
  }
}