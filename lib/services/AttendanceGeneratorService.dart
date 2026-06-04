import 'dart:convert';
import 'package:crypto/crypto.dart';

class AttendanceGeneratorService {
  // Config keys converted exactly from Python's bytes literals
  static final List<int> _hmacSecretKey = utf8.encode("B4_02_xNexus");

  /// Generates the QR payload data structure signed with HMAC but without XOR obfuscation
  static String generateAttendanceData(String userId) {
    // 1. Dynamic unix timestamp in seconds
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 2. Format payload string: "user_id|timestamp"
    final String payloadStr = "$userId|$timestamp";
    final List<int> payloadBytes = utf8.encode(payloadStr);

    // 3. Generate HMAC-SHA256 Signature
    final Hmac hmacSha256 = Hmac(sha256, _hmacSecretKey);
    final Digest signature = hmacSha256.convert(payloadBytes);
    final List<int> signatureBytes = signature.bytes;

    // 4. Combine: payloadBytes + '|' + signatureBytes
    final List<int> pipeByte = utf8.encode("|");
    final List<int> fullPackage = [
      ...payloadBytes,
      ...pipeByte,
      ...signatureBytes,
    ];

    // 5. Encode the signed package directly into a URL-safe Base64 String
    String base64Str = base64UrlEncode(fullPackage);

    return base64Str;
  }
}