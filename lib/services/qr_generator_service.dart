import 'dart:convert';
import 'package:crypto/crypto.dart';

class QrGeneratorService {
  // Config keys converted exactly from Python's bytes literals
  static final List<int> _hmacSecretKey = utf8.encode("B4_02_xNexus");
  static final List<int> _xorKey = utf8.encode("UTr0tM32Schv+KUVxtuPW18CoQenlliC");

  /// Replicates Python's byte-by-byte repeating XOR function
  static List<int> _xorData(List<int> dataBytes, List<int> key) {
    return List<int>.generate(
      dataBytes.length,
          (i) => dataBytes[i] ^ key[i % key.length],
    );
  }

  /// Generates the absolute identical student QR payload data structure as the backend script
  static String generateQrData(String studentId) {
    // 1. Dynamic unix timestamp in seconds
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 2. Format payload string: "student_id|timestamp"
    final String payloadStr = "$studentId|$timestamp";
    final List<int> payloadBytes = utf8.encode(payloadStr);

    // 3. Generate HMAC-SHA256 Signature
    final Hmac hmacSha256 = Hmac(sha256, _hmacSecretKey);
    final Digest signature = hmacSha256.convert(payloadBytes);

    // --- FIXED: Truncate to first 16 bytes to match Python's .digest()[:16] ---
    final List<int> truncatedSignatureBytes = signature.bytes.sublist(0, 16);

    // 4. Combine: payloadBytes + '|' + truncatedSignatureBytes
    final List<int> pipeByte = utf8.encode("|");
    final List<int> fullPackage = [
      ...payloadBytes,
      ...pipeByte,
      ...truncatedSignatureBytes,
    ];

    // 5. Apply XOR Obfuscation
    final List<int> obfuscatedBytes = _xorData(fullPackage, _xorKey);

    // 6. Encode into URL-safe Base64 String
    String base64Str = base64UrlEncode(obfuscatedBytes);

    return base64Str;
  }

  static String EmpgenerateQrData(String studentId) {
    // 1. Dynamic unix timestamp in seconds
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // 2. Format payload string: "student_id|timestamp"
    final String payloadStr = "$studentId|$timestamp";
    final List<int> payloadBytes = utf8.encode(payloadStr);

    // 3. Generate HMAC-SHA256 Signature
    final Hmac hmacSha256 = Hmac(sha256, _hmacSecretKey);
    final Digest signature = hmacSha256.convert(payloadBytes);

    // --- FIXED: Truncate to first 16 bytes to match Python's .digest()[:8] ---
    final List<int> truncatedSignatureBytes = signature.bytes.sublist(0, 8);

    // 4. Combine: payloadBytes + '|' + truncatedSignatureBytes
    final List<int> pipeByte = utf8.encode("|");
    final List<int> fullPackage = [
      ...payloadBytes,
      ...pipeByte,
      ...truncatedSignatureBytes,
    ];

    // 5. Apply XOR Obfuscation
    final List<int> obfuscatedBytes = _xorData(fullPackage, _xorKey);

    // 6. Encode into URL-safe Base64 String
    String base64Str = base64UrlEncode(obfuscatedBytes);

    return base64Str;
  }
}